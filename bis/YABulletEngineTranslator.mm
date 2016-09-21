//
//  YABulletEngineTranslator.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 19.10.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#include "btBulletDynamicsCommon.h"
#include "BulletSoftBody/btSoftRigidDynamicsWorld.h"
#include "BulletSoftBody/btSoftBodyRigidBodyCollisionConfiguration.h"
#include "BulletSoftBody/btSoftBodyHelpers.h"
#include "BulletSoftBody/btSoftBody.h"

#import "YAPreferences.h"
#import "YALog.h"
#import "YABulletEngineCollisionProtocol.h"
#import "YAPhysicProtocol.h"
#import "YARenderLoop.h"
#import "YAVector3f.h"
#import "YAQuaternion.h"
#import "YAIngredient.h"
#import "YAImpGroup.h"
#import "YAImpersonator+Physic.h"
#import "YABulletEngineTranslator.h"

#define async(cmds) dispatch_async(dispatch_get_main_queue(), ^{ cmds });
static const NSString* TAG = @"YABulletEngineTranslator";
static const NSString* MODEL_DIRECTORY_NAME = @"model";

@interface YABulletEngineTranslator()
{
@private
    bool setupDone;
}

@end


@implementation YABulletEngineTranslator {
    btDefaultCollisionConfiguration* collisionConfiguration;
    btCollisionDispatcher* dispatcher;
    btAxisSweep3* broadPhase;
    btSequentialImpulseConstraintSolver* solver;
    btSoftRigidDynamicsWorld* dynamicsWorld;
    btAlignedObjectArray<btCollisionShape*> collisionShapes;
    btSoftBodyWorldInfo softBodyWorldInfo; // Magic: struct to cache data?
}

@synthesize groundImp, physicImps;

static const NSString* OF_TYPE = @"YCH"; // Convex Hull suffixes

struct collision : public btCollisionWorld::ContactResultCallback
{
    
    collision(YAImpersonator* imp, id <YABulletEngineCollisionProtocol> listener)
    : btCollisionWorld::ContactResultCallback(),
    _imp(imp),
    _listener(listener)
    { }
    
    YAImpersonator* _imp;
    id _listener;
    
	virtual	btScalar addSingleResult(btManifoldPoint& cp,
                                     const btCollisionObjectWrapper* colObj0Wrap,
                                     int partId0,
                                     int index0,
                                     const btCollisionObjectWrapper* colObj1Wrap,
                                     int partId1,
                                     int index1)
	{
        [_listener setCollisionImp:_imp];
        return 0;
	}
};


- (id) initIn: (YARenderLoop*) world
{
    self = [super init];
    if (self) {
        // NSLog(@"Bullet Engine Init");
        _updateLock = [[NSLock alloc] init];

        setupDone = false; // check for ropes / can only be added after setup

        // YAOgl part
        _world = world;
        groundImp = nil;
        physicImps = [[NSMutableArray alloc] initWithCapacity:10];
        
        // BE part
        collisionConfiguration = new btSoftBodyRigidBodyCollisionConfiguration();
        dispatcher = new btCollisionDispatcher(collisionConfiguration);
        
        btVector3 worldAabbMin(-1000,-1000,-1000);
        btVector3 worldAabbMax(1000,1000,1000);
        float maxProxies = 1024;
        broadPhase =  new btAxisSweep3(worldAabbMin,worldAabbMax,maxProxies);
        
        solver = new btSequentialImpulseConstraintSolver();
        dynamicsWorld = new btSoftRigidDynamicsWorld(dispatcher,broadPhase,solver,collisionConfiguration);

        dynamicsWorld->setGravity(btVector3(0,-10,0));
        
        // setup soft body info
        softBodyWorldInfo.m_broadphase = broadPhase;
        softBodyWorldInfo.m_dispatcher = dispatcher;
        softBodyWorldInfo.m_gravity.setValue(0,-10,0);
        softBodyWorldInfo.m_sparsesdf.Initialize();
    }

    return self;
}

-(void) restart {        
    // NSLog(@"Bullet Engine Restart");
    [_updateLock lock];
    [self destroyBulletEngine];
    
    collisionConfiguration = new btSoftBodyRigidBodyCollisionConfiguration();
    dispatcher = new btCollisionDispatcher(collisionConfiguration);
    
    btVector3 worldAabbMin(-1000,-1000,-1000);
    btVector3 worldAabbMax(1000,1000,1000);
    float maxProxies = 1024;
    broadPhase =  new btAxisSweep3(worldAabbMin,worldAabbMax,maxProxies);
    
    solver = new btSequentialImpulseConstraintSolver();
    dynamicsWorld = new btSoftRigidDynamicsWorld(dispatcher,broadPhase,solver,collisionConfiguration);
    
    dynamicsWorld->setGravity(btVector3(0,-10,0));
    
    // setup soft body info
    softBodyWorldInfo.m_broadphase = broadPhase;
    softBodyWorldInfo.m_dispatcher = dispatcher;
    softBodyWorldInfo.m_gravity.setValue(0,-10,0);
    softBodyWorldInfo.m_sparsesdf.Initialize();
    
    setupDone = false;
    [self setupScene];

    [_updateLock unlock];        
}



-(void) destroyBulletEngine
{
    // NSLog(@"Bullet Engine Destroy");

    for (int i=dynamicsWorld->getNumCollisionObjects()-1; i>=0 ;i--) {
		btCollisionObject* obj = dynamicsWorld->getCollisionObjectArray()[i];
		btRigidBody* body = btRigidBody::upcast(obj);
		if (body && body->getMotionState())
			delete body->getMotionState();
		dynamicsWorld->removeCollisionObject( obj );
		delete obj;
	}
    for (int j=0;j<collisionShapes.size();j++)
	{
		btCollisionShape* shape = collisionShapes[j];
		collisionShapes[j] = 0;
		delete shape;
	}
    
    delete dynamicsWorld;
    delete solver;
    delete broadPhase;
    collisionShapes.clear();
}

- (void)dealloc
{
    [self destroyBulletEngine];
}

-(void) fromConvexHulls: (id<YAPhysicProtocol>) pImp
{
    [YALog debug:TAG message:@"fromConvexHulls"];
    btCompoundShape* compoundShape = new btCompoundShape();
    
    for(NSString* filename in pImp.hulls) {
        
        YAPreferences* prefs = [[YAPreferences alloc] init];
        NSString* path = [NSString stringWithFormat:@"%@/%@/%@.%@", prefs.resourceDir, MODEL_DIRECTORY_NAME,filename,OF_TYPE ];
        [YALog debug:TAG message:[NSString stringWithFormat:@"Try loading: %@", path]];

        
        // NSInputStream* iStream = [[NSInputStream alloc] initWithFileAtPath:path];
        // [iStream open];
        
        NSData* iData = [NSData dataWithContentsOfFile:path];
        // NSLog(@"Length: %ld", iData.length);

        NSError *error = nil;
        // NSDictionary* convexHullJson = [NSJSONSerialization JSONObjectWithStream:iStream options:NSJSONReadingMutableLeaves error:&error];
        NSDictionary* convexHullJson = [NSJSONSerialization JSONObjectWithData:iData options:NSJSONReadingMutableLeaves error:&error];
  
        if(error != nil) {
            // NSLog(@"Error in YCH file: %@", error);
            return;
        }
        
        // [iStream close];
        
        NSArray* chVertices = [convexHullJson objectForKey:@"Vertices"];
        
        // create convex hull from json hull data
        NSMutableData* hullScalars = [[NSMutableData alloc] init];
        for(NSDictionary* chVertice in chVertices) {
            NSArray* scalars = [chVertice objectForKey:@"Vertice"];
            for(NSNumber* scalarN in scalars) {
                float scalar = scalarN.floatValue;
                [hullScalars appendBytes:&scalar length:sizeof(float)];
            }
            
        }
        
        btConvexHullShape* hullShape = new btConvexHullShape(
                                                             (const btScalar*)[hullScalars bytes],
                                                             (int)chVertices.count
                                                             ,3*sizeof(float));
        
        // set values witout any transformation
        btTransform trans;
        trans.setIdentity();
        compoundShape->addChildShape(trans,hullShape);
        float subMass = pImp.mass.floatValue / (float)pImp.hulls.count;
        
        btRigidBody* body;
        btVector3 localInertia(0,0,0);
        if(subMass != 0)
            hullShape->calculateLocalInertia(subMass ,localInertia);
        
        btDefaultMotionState* myMotionState = new btDefaultMotionState(trans);
        btRigidBody::btRigidBodyConstructionInfo cInfo(subMass,myMotionState,hullShape,localInertia);
        body = new btRigidBody(cInfo);
        body->setContactProcessingThreshold(BT_LARGE_FLOAT); // avoid interial checks

        
    } // compund shape is now created
    
    collisionShapes.push_back(compoundShape);
    
    btTransform impTransform;
    impTransform.setIdentity();
    
    btScalar mass(pImp.mass.floatValue);
    
    btVector3 localInertia(0,0,0);
    bool isDynamic = (mass != 0.0f);
    if (isDynamic)
        compoundShape->calculateLocalInertia(mass,localInertia);


    btVector3 impOrigin = btVector3(btScalar(pImp.translation.x + pImp.boxOffset.x * pImp.size.x),
                                    btScalar(pImp.translation.y + pImp.boxOffset.y * pImp.size.y),
                                    btScalar(pImp.translation.z + pImp.boxOffset.z * pImp.size.z));
    
    btQuaternion impRot = btQuaternion(btScalar(pImp.rotationQuaternion.x),
                                       btScalar(pImp.rotationQuaternion.y),
                                       btScalar(pImp.rotationQuaternion.z),
                                       btScalar(pImp.rotationQuaternion.w));
    
    impTransform.setOrigin(impOrigin);
    impTransform.setRotation(impRot);
    
    btDefaultMotionState* myMotionState = new btDefaultMotionState(impTransform);
    btRigidBody::btRigidBodyConstructionInfo rbInfo(mass,myMotionState,compoundShape,localInertia);
    
    rbInfo.m_friction = btScalar(pImp.friction.floatValue);
    rbInfo.m_restitution = btScalar(pImp.restitution.floatValue);
    
    btRigidBody* body = new btRigidBody(rbInfo);
    
    if(pImp.gravity != nil)
        body->setGravity(btVector3(pImp.gravity.x,pImp.gravity.y,pImp.gravity.z));
    
    dynamicsWorld->addRigidBody(body);

}


- (void) fromBoxHalfExtents: (id<YAPhysicProtocol>) pImp
{
    // data received from blender mesh size + object resize
    YAVector3f* orgBoxExt = [pImp boxHalfExtents];
    
    btVector3 impBoxHalfExtents = btVector3(btScalar(orgBoxExt.x * pImp.size.x),
                                            btScalar(orgBoxExt.y * pImp.size.y),
                                            btScalar(orgBoxExt.z * pImp.size.z));
    
    btCollisionShape* impShape = new btBoxShape(impBoxHalfExtents);
    collisionShapes.push_back(impShape);
    
    btTransform impTransform;
    impTransform.setIdentity();
    
    
    btScalar mass(pImp.mass.floatValue);
    
    
    btVector3 localInertia(0,0,0);
    bool isDynamic = (mass != 0.0f);
    if (isDynamic)
        impShape->calculateLocalInertia(mass,localInertia);
    
    btVector3 impOrigin = btVector3(btScalar(pImp.translation.x + pImp.boxOffset.x * pImp.size.x),
                                    btScalar(pImp.translation.y + pImp.boxOffset.y * pImp.size.y),
                                    btScalar(pImp.translation.z + pImp.boxOffset.z * pImp.size.z));
    
    btQuaternion impRot = btQuaternion(btScalar(pImp.rotationQuaternion.x),
                                       btScalar(pImp.rotationQuaternion.y),
                                       btScalar(pImp.rotationQuaternion.z),
                                       btScalar(pImp.rotationQuaternion.w));
    
    impTransform.setOrigin(impOrigin);
    impTransform.setRotation(impRot);
    
    btDefaultMotionState* myMotionState = new btDefaultMotionState(impTransform);
    btRigidBody::btRigidBodyConstructionInfo rbInfo(mass,myMotionState,impShape,localInertia);
    
    rbInfo.m_friction = btScalar(pImp.friction.floatValue);
    rbInfo.m_restitution = btScalar(pImp.restitution.floatValue);
    
    btRigidBody* body = new btRigidBody(rbInfo);
    
    if(pImp.gravity != nil)
        body->setGravity(btVector3(pImp.gravity.x,pImp.gravity.y,pImp.gravity.z));
    
    dynamicsWorld->addRigidBody(body);
}

- (void) fromCylinderHalfExtents: (id<YAPhysicProtocol>) pImp
{
    // data received from blender mesh size + object resize
    YAVector3f* orgCylinderExt = [pImp cylinderHalfExtents];
    
    btVector3 impCylinderHalfExtents = btVector3(btScalar(orgCylinderExt.x * pImp.size.x),
                                                 btScalar(orgCylinderExt.y * pImp.size.y),
                                                btScalar(orgCylinderExt.z * pImp.size.z));
    
    btCollisionShape* impShape = new btCylinderShapeZ(impCylinderHalfExtents);
    collisionShapes.push_back(impShape);
    
    btTransform impTransform;
    impTransform.setIdentity();
    
    
    btScalar mass(pImp.mass.floatValue);
    
    
    btVector3 localInertia(0,0,0);
    bool isDynamic = (mass != 0.0f);
    if (isDynamic)
        impShape->calculateLocalInertia(mass,localInertia);
    
    btVector3 impOrigin = btVector3(btScalar(pImp.translation.x + pImp.cylinderOffset.x * pImp.size.x),
                                    btScalar(pImp.translation.y + pImp.cylinderOffset.y * pImp.size.y),
                                    btScalar(pImp.translation.z + pImp.cylinderOffset.z * pImp.size.z));
    
    btQuaternion impRot = btQuaternion(btScalar(pImp.rotationQuaternion.x),
                                       btScalar(pImp.rotationQuaternion.y),
                                       btScalar(pImp.rotationQuaternion.z),
                                       btScalar(pImp.rotationQuaternion.w));
    
    impTransform.setOrigin(impOrigin);
    impTransform.setRotation(impRot);
    
    btDefaultMotionState* myMotionState = new btDefaultMotionState(impTransform);
    btRigidBody::btRigidBodyConstructionInfo rbInfo(mass,myMotionState,impShape,localInertia);
    
    rbInfo.m_friction = btScalar(pImp.friction.floatValue);
    rbInfo.m_restitution = btScalar(pImp.restitution.floatValue);
    
    btRigidBody* body = new btRigidBody(rbInfo);
    
    if(pImp.gravity != nil)
        body->setGravity(btVector3(pImp.gravity.x,pImp.gravity.y,pImp.gravity.z));
    
    dynamicsWorld->addRigidBody(body);
}


-(bool) setupScene
{
    if (setupDone) {
        return NO;
    }
    
    // NSLog(@"Bullet Engine start setup");

    assert(groundImp != nil);
    assert(physicImps != nil);

    // imps lookup
    NSMutableDictionary *mapTemp = [[NSMutableDictionary alloc] init];


    // setup ground
    
    // data received from blender mesh size + object resize
    btVector3 groundBoxHalfExtents = btVector3(btScalar(20.0f * groundImp.size.x * 0.5),
                                               btScalar(1.0f * groundImp.size.y * 0.5),
                                               btScalar(20.0f * groundImp.size.z * 0.5));
    
    

    btCollisionShape* groundShape = new btBoxShape(groundBoxHalfExtents);
    collisionShapes.push_back(groundShape);

    btTransform groundTransform;
	groundTransform.setIdentity();
	groundTransform.setOrigin(btVector3(0,-0.5 * groundImp.size.y,0));
   


    btScalar mass(0.0f);
    bool isDynamic = (mass != 0.0f);
    btVector3 localInertia(0,0,0);
    if (isDynamic)
        groundShape->calculateLocalInertia(mass,localInertia);

    btDefaultMotionState* myMotionState = new btDefaultMotionState(groundTransform);
    btRigidBody::btRigidBodyConstructionInfo rbInfo(mass,myMotionState,groundShape,localInertia);
    btRigidBody* body = new btRigidBody(rbInfo);

    dynamicsWorld->addRigidBody(body);

    // setup imps
    int cSId = 1;
    for(id<YAPhysicProtocol> pImp in physicImps) {
        
        if([pImp respondsToSelector:@selector(hulls)] && pImp.hulls != nil) {
            [self fromConvexHulls:pImp];
        } else if(pImp.boxHalfExtents != nil)
            [self fromBoxHalfExtents:pImp];
        else if(pImp.cylinderHalfExtents != nil)
            [self fromCylinderHalfExtents:pImp];

        [mapTemp setObject:[NSNumber numberWithInt:cSId++] forKey:[NSNumber numberWithInt:pImp.identifier]];
    }

    // maps imps to bulletObjects
    impIdToBtId = [[NSDictionary alloc] initWithDictionary:mapTemp];

    // NSLog(@"Bullet Engine setup done.");
    setupDone = true;
    
    return YES;
}

-(void) addRopeFor: (int) pImpId top: (YAVector3f*) from anchor: (YAVector3f*) to
{
    assert(setupDone); // start setup first
    
    btVector3 _from(from.x,from.y,from.z);
    btVector3 _to(to.x,to.y,to.z);
    
    btSoftBody* rope=btSoftBodyHelpers::CreateRope(softBodyWorldInfo,_from,_to,5,1);
    
    rope->setTotalMass(1);
    rope->m_cfg.piterations = 10;
    rope->m_cfg.citerations = 10;
    rope->m_cfg.diterations = 10;
    rope->m_cfg.viterations = 10;
    
    dynamicsWorld->addSoftBody(rope);
    
    int csId = [[impIdToBtId objectForKey:[NSNumber numberWithInt:pImpId]] intValue];
    btCollisionObject* obj = dynamicsWorld->getCollisionObjectArray()[csId];
    btRigidBody* body = btRigidBody::upcast(obj);
    rope->appendAnchor(rope->m_nodes.size()-1,body);
}


-(void) nextStep: (float) timeSinceLastCall
{
    if(!setupDone)
        return;

    if(!_updateLock.tryLock)
        return;
    
    dynamicsWorld->stepSimulation(timeSinceLastCall,7);
    
    id <YAPhysicProtocol> imp;
    YAVector3f* impPosition = nil;
    YAVector3f* impSize = nil;
    YAVector3f* impOffset = [[YAVector3f alloc] init];
    YAQuaternion* impRot = nil;
    
    for (int i=1; i <= dynamicsWorld->getNumCollisionObjects()-1; i++)
    {
        if(i - 1 >= physicImps.count)
            break;

        btCollisionObject* obj = dynamicsWorld->getCollisionObjectArray()[i];
        btRigidBody* body = btRigidBody::upcast(obj);
        
        if ( body && body->getMotionState() ) {
            
            btTransform trans;
            body->getMotionState()->getWorldTransform(trans);
            
            btVector3 orig = trans.getOrigin();
            btQuaternion rot =  trans.getRotation();
            
            imp = [physicImps objectAtIndex:i-1];
            
            impPosition = imp.translation;
            impSize = imp.size;
            
            if(imp.boxOffset)
                [impOffset setVector:imp.boxOffset];
            else if (imp.cylinderOffset)
                [impOffset setVector:imp.cylinderOffset];
            else
                [impOffset setValues:0 :0 :0];
            
            [impOffset setValues: impOffset.x * impSize.x
                                : impOffset.y * impSize.y
                                : impOffset.z * impSize.z];
            
            [impPosition setValues:orig.getX() - impOffset.x
                                  :orig.getY() - impOffset.y
                                  :orig.getZ() + impOffset.z];

            impRot = imp.rotationQuaternion;
            
            [impRot setValues:rot.getX()
                             :rot.getY()
                             :rot.getZ()
                             :rot.getW()];
            
        }
    }
    
    [_updateLock unlock];
}

-(void) syncImp: (int) pImpId
{
    if(!setupDone)
        return;
    
    int csId = [[impIdToBtId objectForKey:[NSNumber numberWithInt:pImpId]] intValue];
    
    id <YAPhysicProtocol> pImp = nil;
    @try {
        pImp = [physicImps objectAtIndex:csId - 1];
    } @catch (NSException *exception) {
        // NSLog(@"%@", exception.reason);
    }

    if(pImp == nil)
        return;

    btCollisionObject* obj = dynamicsWorld->getCollisionObjectArray()[csId];
    btRigidBody* body = btRigidBody::upcast(obj);
    
    if (body && body->getMotionState()) {
        
        YAVector3f* pos = [[YAVector3f alloc] initCopy:pImp.translation];
        
        // From Imp to rigidBobdy
        YAVector3f* beOffset = [[YAVector3f alloc] init];
        
        if(pImp.boxOffset)
           [beOffset setVector:[pImp boxOffset]];
        else if(pImp.cylinderOffset)
            [beOffset setVector:[pImp cylinderOffset]];

        
        YAVector3f* beSize = [[YAVector3f alloc] initCopy:[pImp size]];
        
        [beOffset setValues: beOffset.x * beSize.x
                           : beOffset.y * beSize.y
                           : beOffset.z * beSize.z];
        
        [pos setValues:pos.x + beOffset.x
                      :pos.y + beOffset.y
                      :pos.z - beOffset.z];
        
        body->getWorldTransform().setOrigin(btVector3(pos.x,pos.y,pos.z));
        
        // rotation
        YAQuaternion* rot = [[YAQuaternion alloc] initCopy:pImp.rotationQuaternion];
        body->getWorldTransform().setRotation(btQuaternion(rot.x, rot.y, rot.z, rot.w));
        
        if(pImp.gravity != nil)
            body->setGravity(btVector3(pImp.gravity.x,pImp.gravity.y,pImp.gravity.z));
        
        body->setDamping(100, 100);
        body->setLinearVelocity(btVector3(0,0,0));
        body->setAngularVelocity(btVector3(0,0,0));
        
        body->setActivationState(ACTIVE_TAG);
    }
}

-(YAVector3f*) getLinearVelocityFor: (int) pImpId
{
    YAVector3f* result = nil;
    int csId = [[impIdToBtId objectForKey:[NSNumber numberWithInt:pImpId]] intValue];
    
    btCollisionObject* obj = dynamicsWorld->getCollisionObjectArray()[csId];
    btRigidBody* body = btRigidBody::upcast(obj);

    if (body && body->getMotionState()) {
        btTransform trans;
        body->getMotionState()->getWorldTransform(trans);

        btVector3 vel = body->getLinearVelocity();
        result = [[YAVector3f alloc] initVals:vel.getX() :vel.getY() :vel.getZ()];
    }

    return result;
}

-(void) setLinearVelocity: (YAVector3f*) velocity For: (int) pImpId
{
    int csId = [[impIdToBtId objectForKey:[NSNumber numberWithInt:pImpId]] intValue];
    btCollisionObject* obj = dynamicsWorld->getCollisionObjectArray()[csId];
    btRigidBody* body = btRigidBody::upcast(obj);

    if (body && body->getMotionState()) {
        body->setLinearVelocity(btVector3(velocity.x, velocity.y, velocity.z));
        body->setActivationState(ACTIVE_TAG);
    }
}

-(YAVector3f*) getAngularVelocityFor: (int) pImpId
{
    YAVector3f* result = nil;
    int csId = [[impIdToBtId objectForKey:[NSNumber numberWithInt:pImpId]] intValue];
    
    btCollisionObject* obj = dynamicsWorld->getCollisionObjectArray()[csId];
    btRigidBody* body = btRigidBody::upcast(obj);
    
    if (body && body->getMotionState()) {
        btTransform trans;
        body->getMotionState()->getWorldTransform(trans);
        
        btVector3 vel = body->getAngularVelocity();
        result = [[YAVector3f alloc] initVals:vel.getX() :vel.getY() :vel.getZ()];
    }
    
    return result;
}
-(void) setAngularVelocity: (YAVector3f*) velocity For: (int) pImpId
{
    int csId = [[impIdToBtId objectForKey:[NSNumber numberWithInt:pImpId]] intValue];
    btCollisionObject* obj = dynamicsWorld->getCollisionObjectArray()[csId];
    btRigidBody* body = btRigidBody::upcast(obj);
    
    if (body && body->getMotionState()) {
        body->setAngularVelocity(btVector3(velocity.x, velocity.y, velocity.z));
        body->setActivationState(ACTIVE_TAG);
    }
}

-(void) checkCollision: (YAImpersonator*) sourceImp
               Targets: (NSArray*) destinationImps
     CollisionListener: (id<YABulletEngineCollisionProtocol>) listener
{
    NSAssert(setupDone, @"Check Collision called before correct setup.");

    int csId = [[impIdToBtId objectForKey:[NSNumber numberWithInt:sourceImp.identifier]] intValue];
    btCollisionObject* objSrc = dynamicsWorld->getCollisionObjectArray()[csId];
    
    for(YAImpersonator* imp in destinationImps) {
        int csIdDest = [[impIdToBtId objectForKey:[NSNumber numberWithInt:imp.identifier]] intValue];
        btCollisionObject* objDst = dynamicsWorld->getCollisionObjectArray()[csIdDest];
        
        collision collisionCallback(imp, listener);
        dynamicsWorld->contactPairTest(objSrc, objDst, collisionCallback);
    }
    
}

-(NSArray*) ropeDescriptions
{
    NSArray* result = [[NSArray alloc] init];
    NSArray* rope;
    
    btSoftBodyArray& softbodies(dynamicsWorld->getSoftBodyArray());
    
    for(int i=0; i<softbodies.size(); ++i) {
        rope = [[NSArray alloc] init];
        
        btSoftBody* softbody(softbodies[i]);
        btSoftBody::tNodeArray& nodes(softbody->m_nodes);
        
        for(int j=0;j<nodes.size();++j) {
            btVector3 nodeBT = nodes[j].m_x;
            YAVector3f* nodeYA = [[YAVector3f alloc] initVals:nodeBT.getX() :nodeBT.getY() :nodeBT.getZ()];
            rope = [rope arrayByAddingObject:nodeYA];
        }
        
        result = [result arrayByAddingObject:rope];
    }
    
    return [[NSArray alloc] initWithArray:result];
}


@end
