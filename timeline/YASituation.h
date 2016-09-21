//
//  YASituation.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 26.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YAEvent.h"
@class YACondition;

@interface YASituation : YAEvent

@property (readwrite) YACondition* condition;

@end
