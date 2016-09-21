//
//  YAInterpolationAnimator.m
//  YAWorld
//
//  Created by Yousry Abdallah on 26.01.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YALog.h"
#import "YAVector3f.h"
#import "YAInterpolationAnimator.h"

@implementation YAInterpolationAnimator

const static NSString* TAG = @"YAInterpolationAnimator";

- (id)initAt: (float) now 
{
    self = [super initAt: now];
    if (self) {
        isFinished = false;
        self.asyncProcessing = YES;
        [YALog debug:TAG message:@"created."];
    }
    return self;
}


- (void) addIpo: (YAVector3f*) rotation timeFrame: (float) timeFrame {
    
    NSArray* ipo = [[NSArray alloc] initWithObjects: [NSNumber numberWithFloat:timeFrame]  ,rotation, nil];
    
    if(ipos == nil) {
        ipos = [[NSArray alloc] initWithObjects:ipo, nil];
    } else {
        ipos = [ipos arrayByAddingObject:ipo];
        
        ipos = [ipos sortedArrayUsingComparator:^NSComparisonResult(NSArray* ipo1, NSArray* ipo2) {
            
            const float timeFrameA = [[ipo1 objectAtIndex:0] floatValue];
            const float timeFrameB = [[ipo2 objectAtIndex:0] floatValue];

            if(timeFrameA > timeFrameB)
                return (NSComparisonResult)NSOrderedDescending;
            else if (timeFrameA  < timeFrameB )
                return (NSComparisonResult)NSOrderedAscending;
            else
                return (NSComparisonResult)NSOrderedSame;
        } ];
    }
}

- (void) addListener: (YAVector3f*) listener {
    [YALog debug:TAG message:@"New IpoListener"];
    [listeners addObject:listener];
}


- (void) update: (float) now
{
    
    if(isFinished) {
        deleteme = true;
        return;
    }
    
    const float timeProgress = now - delay - starttime;
    
    if(timeProgress < 0)
        return;
    
    NSArray* lastIpo = nil;
    NSArray* nextIpo = nil;
    
    for (NSArray* ipo in ipos) {
        float timeFrame = [[ipo objectAtIndex:0] floatValue];

        if (timeProgress > timeFrame) {
            lastIpo = ipo;
        } else {
            nextIpo = ipo;    
            break;
        }
    }
  
    if(lastIpo != nil && nextIpo != nil) {
       
        const float intervallStart = [[lastIpo objectAtIndex:0] floatValue];
        const float intervallEnd = [[nextIpo objectAtIndex:0] floatValue];
        
        const YAVector3f* rotationStart = [lastIpo objectAtIndex:1];
        const YAVector3f* rotationEnd = [nextIpo objectAtIndex:1];


        // calc percentage
        float intervalPercent = 1 -  (intervallEnd - timeProgress) / (intervallEnd - intervallStart);
        
        
        float x = [rotationStart x] + (([rotationEnd x] - [rotationStart x]) * intervalPercent);
        float y = [rotationStart y] + (([rotationEnd y] - [rotationStart y]) * intervalPercent);
        float z = [rotationStart z] + (([rotationEnd z] - [rotationStart z]) * intervalPercent);

        for(YAVector3f* elem in listeners) {
            [elem setX:x];
            [elem setY:y];
            [elem setZ:z];
        }
    } else if(nextIpo == nil) {
        isFinished = true;
        const YAVector3f* rotationStart = [lastIpo objectAtIndex:1];
        
        for(YAVector3f* elem in listeners) {
            [elem setX:[rotationStart x]];
            [elem setY:[rotationStart y]];
            [elem setZ:[rotationStart z]];
        }

        deleteme = true;
        [YALog debug:TAG message:@"Ipo Animator finished."];
    }
    
}

@end
