//
//  YAInterpolationAnimator.h
//  YAWorld
//
//  Created by Yousry Abdallah on 26.01.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YABasicAnimator.h"
@class YAVector3f;

@interface YAInterpolationAnimator : YABasicAnimator {
@private    
    NSArray* ipos;
    bool isFinished;
}

- (void) addListener: (YAVector3f*) listener;
- (void) addIpo: (YAVector3f*) rotation timeFrame: (float) timeFrame;

@end
