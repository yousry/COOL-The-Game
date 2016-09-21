//
//  YAImpersonator+Physic.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 23.10.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <objc/runtime.h>

#import "YAVector3f.h"
#import "YAImpersonator+Physic.h"

static char const * const MassKey = "mass";
static char const * const FrictionKey = "friction";
static char const * const RestitutionKey = "restitution";
static char const * const GravityKey = "gravity";

static char const * const BoxHalfExtentsKey = "boxHalfExtents";
static char const * const BoxOffsetKey = "boxOffset";

static char const * const HullsKey = "hulls";

static char const * const CylinderHalfExtentsKey = "cylinderHalfExtents";
static char const * const CylinderOffsetKey = "cylinderOffset";

static char const * const CollisionNameKey = "collisionName";


@implementation YAImpersonator (Physic)
@dynamic mass,friction,restitution, gravity;
@dynamic size,translation,rotationQuaternion;
@dynamic boxHalfExtents, boxOffset;
@dynamic cylinderHalfExtents,cylinderOffset;
@dynamic hulls;
@dynamic identifier;
@dynamic collisionName;


// --------------------- Mass

- (NSNumber*) mass
{
    NSNumber* result = objc_getAssociatedObject(self, (void*)MassKey);
    result = result == nil ? [NSNumber numberWithFloat:0] : result;
    return result;
}

- (void) setMass: (NSNumber*) val
{
    objc_setAssociatedObject(self, (void*)MassKey, val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// --------------------- Friction


- (NSNumber*) friction
{
    NSNumber* result = objc_getAssociatedObject(self, (void*)FrictionKey);
    result = result == nil ? [NSNumber numberWithFloat:0.5f] : result;
    return result;
}

- (void) setFriction: (NSNumber*) val
{
    objc_setAssociatedObject(self, (void*)FrictionKey, val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// --------------------- Restitution


- (NSNumber*) restitution
{
    NSNumber* result = objc_getAssociatedObject(self, (void*)RestitutionKey);
    result = result == nil ? [NSNumber numberWithFloat:0.0f] : result;
    return result;
}

- (void) setRestitution: (NSNumber*) val
{
    objc_setAssociatedObject(self, (void*)RestitutionKey, val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// --------------------- BoxHalfExtents


- (YAVector3f*) boxHalfExtents
{
    YAVector3f* result = objc_getAssociatedObject(self, (void*)BoxHalfExtentsKey);
    return result;
}

- (void) setBoxHalfExtents: (YAVector3f*) val
{
    objc_setAssociatedObject(self, (void*)BoxHalfExtentsKey, val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// --------------------- BoxOffset


- (YAVector3f*) boxOffset
{
    YAVector3f* result = objc_getAssociatedObject(self, (void*)BoxOffsetKey);
    return result;
}

- (void) setBoxOffset: (YAVector3f*) val
{
    objc_setAssociatedObject(self, (void*)BoxOffsetKey, val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// --------------------- Gravity


- (YAVector3f*) gravity
{
    YAVector3f* result = objc_getAssociatedObject(self, (void*)GravityKey);
    return result;
}

- (void) setGravity: (YAVector3f*) val
{
    objc_setAssociatedObject(self, (void*)GravityKey, val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// --------------------- Hulls


- (NSArray*) hulls
{
    NSArray* result = objc_getAssociatedObject(self, (void*)HullsKey);
    return result;
}

- (void) setHulls: (NSArray*) val
{
    objc_setAssociatedObject(self, (void*)HullsKey, val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// --------------------- CylinderHalfExtents


- (YAVector3f*) cylinderHalfExtents
{
    YAVector3f* result = objc_getAssociatedObject(self, (void*)CylinderHalfExtentsKey);
    return result;
}

- (void) setCylinderHalfExtents: (YAVector3f*) val
{
    objc_setAssociatedObject(self, (void*)CylinderHalfExtentsKey, val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// --------------------- CylinderOffset


- (YAVector3f*) cylinderOffset
{
    YAVector3f* result = objc_getAssociatedObject(self, (void*)CylinderOffsetKey);
    return result;
}

- (void) setCylinderOffset: (YAVector3f*) val
{
    objc_setAssociatedObject(self, (void*)CylinderOffsetKey, val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// --------------------- CollisionName


- (NSString*) collisionName
{
    NSString* result = objc_getAssociatedObject(self, (void*)CollisionNameKey);
    return result;
}

- (void) setCollisionName: (NSString*) val
{
    objc_setAssociatedObject(self, (void*)CollisionNameKey, val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
