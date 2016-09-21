//
//  YACondition.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 26.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YAEvaluable.h"

typedef enum {
    TEST_AND,
    TEST_AND_NOT,
    TEST_OR,
    TEST_OR_NOT
} BOOL_OPERATOR;

@interface YACondition : NSObject <YAEvaluable>

@property (strong, readwrite) NSArray* values;
@property (assign, readwrite) BOOL_OPERATOR testOperator;

@end
