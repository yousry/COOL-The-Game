//
//  YAImpersonator+Physic.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 23.10.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YAPhysicProtocol.h"
#import "YAImpersonator.h"

@interface YAImpersonator (Physic) <YAPhysicProtocol>

@property (assign, readwrite) int identifier;

@property (nonatomic, retain) NSNumber* mass;
@property (nonatomic, retain) NSNumber* friction;
@property (nonatomic, retain) NSNumber* restitution;
@property (nonatomic, retain) YAVector3f* gravity;


@property (nonatomic, retain) YAVector3f* size;
@property (readonly) YAVector3f* translation;
@property (readonly) YAQuaternion* rotationQuaternion;

@property (nonatomic, retain) YAVector3f* boxHalfExtents;
@property (nonatomic, retain) YAVector3f* boxOffset;

// or

@property (nonatomic, retain) NSArray* hulls;

// or

@property (nonatomic, retain) YAVector3f* cylinderHalfExtents;
@property (nonatomic, retain) YAVector3f* cylinderOffset;

// for collision identification
@property (nonatomic, retain) NSString* collisionName;

@end
