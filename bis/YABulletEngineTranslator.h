//
//  YABulletEngineTranslator.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 19.10.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YABulletEngineCollisionProtocol.h"
#import <Foundation/Foundation.h>
@class YAImpersonator, YARenderLoop, YAVector3f;

@interface YABulletEngineTranslator : NSObject {
    YARenderLoop* _world;
    
    NSDictionary* impIdToBtId;
    
    volatile NSLock* _updateLock;
    
}

@property (strong, readwrite) YAImpersonator* groundImp;
@property (strong, readwrite) NSMutableArray* physicImps;

- (id) initIn: (YARenderLoop*) world;

-(bool) setupScene;
-(void) nextStep: (float) timeSinceLastCall;

-(YAVector3f*) getLinearVelocityFor: (int) pImpId;
-(void) setLinearVelocity: (YAVector3f*) velocity For: (int) pImpId;

-(YAVector3f*) getAngularVelocityFor: (int) pImpId;
-(void) setAngularVelocity: (YAVector3f*) velocity For: (int) pImpId;

-(void) syncImp: (int) pImpId;

-(void) addRopeFor: (int) pImpId top: (YAVector3f*) from anchor: (YAVector3f*) to;

// Array of arrays or rope segments
-(NSArray*) ropeDescriptions;

-(void) checkCollision: (YAImpersonator*) sourceImp
               Targets: (NSArray*) destinationImps
     CollisionListener: (id<YABulletEngineCollisionProtocol>) listener;


-(void) restart;

@end
