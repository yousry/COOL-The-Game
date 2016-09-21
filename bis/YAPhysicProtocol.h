//
//  YAPhysicProtocol.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 23.10.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YAVector3f, YAQuaternion;

@protocol YAPhysicProtocol <NSObject>

@required
@property (nonatomic, retain) NSNumber* mass; // ATTENTION: retain == strong
@property (nonatomic, retain) NSNumber* friction;
@property (nonatomic, retain) NSNumber* restitution;
@property (nonatomic, retain) YAVector3f* gravity;


@property (nonatomic, retain) YAVector3f* size;
@property (readonly) YAVector3f* translation;
@property (readonly) YAQuaternion* rotationQuaternion;

@property (nonatomic, retain) YAVector3f* boxHalfExtents;
@property (nonatomic, retain) YAVector3f* boxOffset;

@property (assign, readwrite) int identifier;


@optional
@property (nonatomic, retain) NSArray* hulls;

@property (nonatomic, retain) YAVector3f* cylinderHalfExtents;
@property (nonatomic, retain) YAVector3f* cylinderOffset;

@property (nonatomic, retain) NSString* collisionName;

@end
