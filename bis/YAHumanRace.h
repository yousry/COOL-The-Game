//
//  YAHumanRace.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 25.04.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YAAlienRace.h"
#import "YAImpersonatorMover.h"
#import <Foundation/Foundation.h>
@class YARenderLoop;

@interface YAHumanRace : YAAlienRace

- (id) initInWorld: (YARenderLoop*) world PlayerId: (int) id;
@end
