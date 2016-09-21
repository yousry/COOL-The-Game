//
//  YAGroupListener.h
//  YAWorld
//
//  Created by Yousry Abdallah on 20.06.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YAGroupListener <NSObject>

@property (strong,readwrite) YAVector3f* translation;
@property (strong,readwrite) YAVector3f* rotation;
@property (assign,readwrite) bool useQuaternionRotation;
@property (strong, readwrite) YAQuaternion* rotationQuaternion;
@property (strong,readwrite) YAVector3f* size;

// @property (strong,readwrite) YAVector3f* visible;
@property (assign, readwrite) bool visible;

@property (strong, readwrite) NSMutableArray* states;
@property (strong, readwrite) NSString* state;

@end
