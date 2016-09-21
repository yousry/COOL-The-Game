//
//  YATrigger.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 26.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YAEvent.h"
#import "YATrigger.h"

@implementation YATrigger
@synthesize event = _event;

- (id) initTriggerForEvent:(YAEvent *)event
{
    self = [super init];
    
    if(self) {
        _event = event;
    }
    return self;
}

- (void) validateEvent {
    if(!_event.valid) {
        [_event setValid:YES];
        [_event start];
    }
}

@end
