//
//  YADromedarMover.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 14.06.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YAImpersonatorMover.h"
@class YAImpersonator, YARenderLoop, YAKinematic, YABlockAnimator;
@class YAQuaternion;

@interface YADromedarMover : NSObject <YAImpersonatorMover> {
@private 
    
    NSMutableArray* upperArmL, *lowerArmL, *footL;
    NSMutableArray* upperArmR, *lowerArmR, *footR;
    NSMutableArray* upperLegL, *lowerLegL, *handL;
    NSMutableArray* upperLegR, *lowerLegR, *handR;
    
    YAImpersonator* _impersonator;
    YARenderLoop* _world;
    YAKinematic* kinematic;
    YABlockAnimator* animators[6];    
}

// @property (assign, readwrite) AnimState active;

- (void) cleanup;
- (id) initWithImp: (YAImpersonator*) impersonator inWorld: (YARenderLoop*) world;
- (void) reset;

@end
