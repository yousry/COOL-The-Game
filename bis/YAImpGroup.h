//
//  YAImpGroup.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 20.06.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YAPhysicProtocol.h"

@class YAVector3f, YAImpersonator, YAQuaternion;

// Group impersonators dependent to a state.

@interface YAImpGroup : NSObject  <YAPhysicProtocol> {
@private
    NSMutableArray* _observers;
    NSArray* transferredKeys;
}


@property (strong, readwrite) NSMutableArray* observers;
@property (assign, readwrite) bool visible;
@property (strong,readwrite) YAVector3f* translation;
@property (strong,readwrite) YAVector3f* rotation;
@property (assign,readwrite) bool useQuaternionRotation;
@property (strong, readwrite) YAQuaternion* rotationQuaternion;
@property (nonatomic, retain) YAVector3f* size;
@property (strong, readwrite, atomic) __block volatile NSString* state;
@property (strong, readwrite, atomic) __block volatile NSArray* states;


- (void) addImp: (NSObject*) impersonator;
- (void) addModifier: (NSString*) forState Impersonator: (int) impId  Modifier: (NSString*) modifier Value: (id) value;
- (NSMutableArray*) allImps;

@property (assign, readwrite) int identifier;

// for physics
// @property (nonatomic, retain) NSNumber* mass; // ATTENTION: retain == strong
// @property (nonatomic, retain) NSNumber* friction;
// @property (nonatomic, retain) NSNumber* restitution;

// @property (nonatomic, retain) YAVector3f* boxHalfExtents;
// @property (nonatomic, retain) YAVector3f* boxOffset;

// for collision identification
@property (nonatomic, retain) NSString* collisionName;

@end
