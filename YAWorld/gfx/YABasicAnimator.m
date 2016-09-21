//
//  YABasicAnimator.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 27.10.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import "math.h"
#import "YALog.h"
#import "YAVector3f.h"
#import "YABasicAnimator.h"

@implementation YABasicAnimator

@synthesize event, message, deleteme, once, onceReset;
@synthesize influence, progress, interval, delay,  starttime;
@synthesize asyncProcessing =_asyncProcessing;

const static NSString* TAG = @"YABasicAnimator";

const static NSString* KEY_INIT = @"init";
const static NSString* KEY_LISTENER = @"listener";
const static NSString* KEY_FACTOR = @"factor";

- (id)initAt: (float) now 
{
    [YALog debug:TAG message:[NSString stringWithFormat:@"initAt: %f", now]];
    self = [super init];
    if (self) {
        listeners = [[NSMutableArray alloc] init];
        starttime = now;
        interval = 5.0f;
        progress = cyclic;
        delay = 0.0f;
        influence = X_AXE;
        deleteme = false;
        once = false;
        onceReset = true;
        _asyncProcessing = YES;
    }
    
    return self;
}


- (void) addListenerWithInitSituation: (YAVector3f*) listener factor: (float) factor situation: (YAVector3f*) situation 
{
    [YALog debug:TAG message:[NSString stringWithFormat:@"NewListener: %@ with factor: %f", listener, factor]];
    
    YAVector3f* initValue = [[YAVector3f alloc] initVals:[situation x] :[situation y] :[situation z]];
    
    
    NSNumber* factorNumber = [NSNumber numberWithFloat: factor];
    
    NSDictionary* elem = [NSDictionary dictionaryWithObjectsAndKeys:
                          initValue, KEY_INIT, 
                          listener, KEY_LISTENER, 
                          factorNumber, KEY_FACTOR, nil];
    [listeners addObject:elem];   
}


- (void) addListener: (YAVector3f*) listener factor: (float) factor;
{
    [YALog debug:TAG message:[NSString stringWithFormat:@"NewListener: %@ with factor: %f", listener, factor]];
    
    YAVector3f* initValue = [[YAVector3f alloc] initVals:[listener x] :[listener y] :[listener z]];
    
    
    NSNumber* factorNumber = [NSNumber numberWithFloat: factor];
    
    NSDictionary* elem = [NSDictionary dictionaryWithObjectsAndKeys:
                          initValue, KEY_INIT, 
                          listener, KEY_LISTENER, 
                          factorNumber, KEY_FACTOR, nil];
    [listeners addObject:elem];
}

- (void) update: (float) now
{
    const float delayedStart = now - delay - starttime;
    if (delayedStart < 0)
        return;
    
    float spanPos = fmodf(delayedStart, interval) / interval;
    
    if(once) {
        spanPos = delayedStart / interval;
        if(spanPos > 1) {
            if(onceReset)
                spanPos = 1.0f;
            else
                spanPos = 0.999f;
            deleteme = true;
        }
    }
    
    if(progress == zigzag) {
        if (spanPos <= 0.5f)
            spanPos *= 2.0f;
        else
            spanPos = 1 -  (spanPos - 0.5f) * 2.0f;
    } else if(progress == harmonic) {
        spanPos = sinf((2.0f * M_PI) * spanPos) / 2.0f;
    } else if(progress == damp) {
        spanPos = sinf((0.5f * M_PI) * spanPos);
    } else if(progress == accelerate) {
        spanPos = 1 - cosf((0.5f * M_PI) * spanPos);
    } else if (progress == PROGRESS_ACCELERATE_DECELERATE) {
        spanPos = sinf(spanPos * spanPos * M_PI * 0.5f);
    } else if (progress == PROGRESS_SLOW_ACCELERATE_DECELERATE) {
        spanPos = sinf(spanPos * spanPos * spanPos * M_PI * 0.5f);
    }
    
    for(NSDictionary* elem in listeners) {
        YAVector3f* initValue = [elem objectForKey:KEY_INIT];
        YAVector3f* listener = [elem objectForKey:KEY_LISTENER];
        NSNumber* factorNumber = [elem objectForKey:KEY_FACTOR];
        float factor = [factorNumber floatValue];
        
        switch (influence) {
            case X_AXE:
                [listener setX: [initValue x] + fmod((spanPos * factor), factor)];
                break;
            case Y_AXE:
                [listener setY: [initValue y] + fmod((spanPos * factor), factor)];
                break;
            case Z_AXE:
                [listener setZ: [initValue z] + fmod((spanPos * factor), factor)];
                break;
            default:
                [listener setX: [initValue x] + fmod((spanPos * factor), factor)];
                break;
        }
        
    }
    
}


@end
