//
//  YAImpersonatorMover.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 04.06.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YAWorld, YAImpersonator;

typedef enum animstate  {
    none = 1,
    walk = 2,
    parade = 3
} AnimState;

@protocol YAImpersonatorMover <NSObject>

@property (assign, readwrite) AnimState active;

- (id) initWithImp: (YAImpersonator*) impersonator inWorld: (YAWorld*) world;
- (void) reset;

- (void) setupKinematik;

@end
