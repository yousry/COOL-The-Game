//
//  YABlocksAnimator.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 31.10.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import "YABasicAnimator.h"
#import "YABlockAnimator.h"

@implementation YABlockAnimator : YABasicAnimator
@synthesize oneExecution;
@synthesize asyncProcessing =_asyncProcessing;

- (id)initAt: (float) now
{
    self = [super initAt: now];

    if (self) {
        oneExecution = NO;
        _asyncProcessing = YES;
    }

    return self;
}

- (void) addListener: (ListenerBlock) listener
{
    [listeners addObject: [listener copy]];
}



- (void) update: (float) now
{
    const float delayedStart = now - delay - starttime;
    if (delayedStart < 0)
        return;

    float spanPos = fmodf(delayedStart, interval) / interval;
    
    if(oneExecution == true)
        deleteme = true;

    if(once) {
        spanPos = delayedStart / interval;
        if(spanPos > 1) {
            spanPos = 1;
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
    
    @try {
        for(ListenerBlock listener in listeners) {
            listener(spanPos, event, message);
        }

    } @catch (id e) {
        // NSLog(@"%@", e);
    }
    
}

@end
