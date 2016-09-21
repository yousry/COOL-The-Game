//
//  YAMechatronMover.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 05.06.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YAImpersonatorMover.h"
@class YAImpersonator, YARenderLoop, YAKinematic, YABlockAnimator;

@interface YAMechatronMover : NSObject <YAImpersonatorMover> {
@private    
    YAImpersonator* _impersonator;
    YARenderLoop* _world;
    __block YAKinematic* kinematic;
    YABlockAnimator* animators[3];
}


- (id) initWithImp: (YAImpersonator*) impersonator inWorld: (YARenderLoop*) world;
- (void) reset;

@end
