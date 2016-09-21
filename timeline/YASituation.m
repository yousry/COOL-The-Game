//
//  YASituation.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 26.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YACondition.h"
#import "YASituation.h"

@implementation YASituation
@synthesize condition;

- (bool) valid
{
    return condition.valid;
}

- (void) setValid:(bool)valid
{
    NSAssert(false, @"Calidity is calculated by condition");
}

@end
