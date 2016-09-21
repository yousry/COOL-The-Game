//
//  YACondition.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 26.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YAEvaluable.h"
#import "YACondition.h"

@implementation YACondition
@synthesize values, testOperator;


- (bool) valid
{
    bool result = true;
    
    if(testOperator == TEST_OR || testOperator == TEST_OR_NOT)
        result = false;

    for(id <YAEvaluable> vId in values) {

        switch (testOperator) {
            case TEST_AND:
                result = result && vId.valid;
                break;
            case TEST_AND_NOT:
                result = result && !vId.valid;
                break;
            case TEST_OR:
                result = result || vId.valid;
                break;
            case TEST_OR_NOT:
                result = result || !vId.valid;
                break;
        }
    }

    return result;
}


- (void) setValid:(bool)valid
{
    NSAssert(false, @"Validity is Calculated");
}

@end
