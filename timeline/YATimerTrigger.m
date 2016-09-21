//
//  YATimerTrigger.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 26.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YAEvent.h"
#import "YATimerTrigger.h"

@implementation YATimerTrigger
@synthesize queue, delay;

- (id) initTriggerForEvent:(YAEvent *)event
{
    self = [super initTriggerForEvent:event];
    
    if(self) {
        _willRun = false;
    }
    
    return self;
}

- (void) validateEvent
{
    NSAssert(queue, @"queue not initialized");
    
    if(!_event.valid && !_willRun) {

        _willRun = true;
        
        dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
        
        dispatch_after(startTime, queue, ^{
            [_event setValid:YES];
            [_event start];
            _willRun = false;
        });
    }
    
}

@end
