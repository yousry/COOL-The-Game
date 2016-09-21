//
//  YAProbability.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 06.03.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#include <bsd/stdlib.h>
#import <math.h>
#import "YAProbability.h"

@implementation YAProbability

+ (float) linearProb: (float) sample
{
    NSAssert((sample >= 0 && sample <=1), @"Sample not in range between 0..1");
    return sample;
}

+ (float) sinPowProb: (float) sample
{
    NSAssert((sample >= 0 && sample <=1), @"Sample not in range between 0..1");
    return sinf(powf(sample,2) * M_PI * 0.5);
    
}

+ (float) sinSqrtProb: (float) sample
{
    NSAssert((sample >= 0 && sample <=1), @"Sample not in range between 0..1");
    return sinf(sqrtf(sample) * M_PI * 0.5);
}

+ (bool) dice: (float) probability
{
    NSAssert((probability >= 0 && probability <=1), @"Probability not in range between 0..1");
    
    if(probability == 0)
        return false;
    else if(probability == 1)
        return true;
    
    float rand = ((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX);
    
    if(rand <= probability)
        return true;
    else
        return false;
}

+ (float) mapToProbRange: (float) element From: (float) start To: (float) end
{
    const float dist = end - start;
    const float eDst = element - start;
    return (eDst / dist);
}

+ (bool) isInRange: (float) element From: (float) start To: (float) end
{
    return element >= start && element <= end;
}


+ (float) random
{
    return((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX);
}


// helper function for randomSelect
+ (float) changeEventProbability: (float) change Index: (int) index In: (NSArray*) elements;
{
    NSMutableArray* element = [elements objectAtIndex:index];
    float actual = [[element objectAtIndex:1] floatValue];
    actual += change;
    [element replaceObjectAtIndex:1 withObject:[NSNumber numberWithFloat:actual]];
    return actual;
}

// event = mutableArray (id, probability)
+ (id) randomSelect: (NSArray*) events
{
    // calculate range
    float end = 0;
    for(NSArray* event in events) {
        end += [[event objectAtIndex:1] floatValue];
    }
        
    float rand = [YAProbability random];

    id result = nil;
    
    float lowerBarrier = 0.0f;
    for(NSArray* event in events) {
        const float prob = [[event objectAtIndex:1] floatValue];
        const float probMap = [YAProbability mapToProbRange:prob From:0 To:end];
        
        const float upperBarrier = lowerBarrier + probMap;
        
        if(rand >= lowerBarrier && rand <= upperBarrier) {
            result = [event objectAtIndex: 0];
            break;
        }
        lowerBarrier = upperBarrier;
    }
    
    return result;
}


+ (id) sampleSelect: (NSArray*) events Sample: (float) sample
{
    NSAssert((sample >= 0 && sample <= 1), @"Sample not in range.");
    
    // calculate range
    float end = 0;
    for(NSArray* event in events) {
        end += [[event objectAtIndex:1] floatValue];
    }
    
    
    id result = nil;
    
    float lowerBarrier = 0.0f;
    for(NSArray* event in events) {
        const float prob = [[event objectAtIndex:1] floatValue];
        const float probMap = [YAProbability mapToProbRange:prob From:0 To:end];
        
        const float upperBarrier = lowerBarrier + probMap;
        
        if(sample >= lowerBarrier && sample <= upperBarrier) {
            result = [event objectAtIndex: 0];
            break;
        }
        lowerBarrier = upperBarrier;
    }
    
    return result;
}

+ (id) randomSelectArray: (NSArray *) array
{
    if(!array || array.count == 0)
        return nil;

    int choise = [YAProbability selectOneOutOf:(int)array.count];
    return [array objectAtIndex:choise];
}


+ (int) selectOneOutOf: (int) tally;
{
    const float random = [YAProbability random];
    return roundf((random * (float)tally) - 0.5f);
}



@end

