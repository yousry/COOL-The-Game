//
//  YAEventChain.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 26.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//


#import "YACondition.h"
#import "YAEvent.h"
#import "YATimerTrigger.h"
#import "YAEventChain.h"

@implementation YAEventChain
@synthesize eventInfo;

- (id) init
{
    self = [super init];
    
    if(self) {
        _events = [[NSMutableDictionary alloc] init];
        // _queue =  dispatch_queue_create("eventQueue", NULL);
        _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _chainRun = false;
    }
    
    return self;
}


- (void) dealloc
{
    if(_queue)
        _queue = nil;
    
    if(_scheduleTimer)
        [_scheduleTimer invalidate];
}



-(void) updateEventState: (YAEvent*) event
{
    NSMutableDictionary* tempState;
    if(eventInfo)
        tempState = [NSMutableDictionary dictionaryWithDictionary:eventInfo];
    else
        tempState = [[NSMutableDictionary alloc] init];
    
    NSDictionary* privateState =[NSDictionary dictionaryWithObjectsAndKeys:
                                 self, @"EVENTCHAIN",
                                 event.name, @"NAME",
                                 nil];
    
    [tempState addEntriesFromDictionary:privateState];
    event.state = [NSDictionary dictionaryWithDictionary:tempState];
}

- (YAEvent*) addEvent: (NSString*) name {
    
    YAEvent* event = [_events objectForKey:name];
    
    if(!event) {
        event = [[YAEvent alloc] initWithName:name];
        [_events setObject:event forKey:name];
    } else {
        
        // NSLog(@"Warning: Reusing existing event.");
    }
    
    return event;
}

- (YAEvent*) getEvent: (NSString*) name
{
    YAEvent* event = [_events objectForKey:name];
    return event;
    
}

- (void) addEvents: (NSArray*) names
{
    for(NSString* name in names)
        [self addEvent:name];
}


-(void) resetEvents: (NSArray*) events
{
    for(NSString* name in events) {
        YAEvent* event = [_events objectForKey:name];
        [event setValid:false];
    }
    
    for(YATrigger* trigger in _triggers) {
        NSString* triggerEventName = trigger.event.name;
        
        if([events indexOfObject:triggerEventName] != NSNotFound) {
            [trigger validateEvent];
        }
    }
}

- (void) startEvent: (NSString*) name
{
    [self startEvent:name At:0];
}

- (void) startEvent: (NSString*) name At:(float) time {
    
    YAEvent* event = [_events objectForKey:name];
    if(event) {
        YATimerTrigger* trigger = [[YATimerTrigger alloc] initTriggerForEvent:event];
        [trigger setDelay:time];
        [trigger setQueue:_queue];
        
        if(!_triggers)
            _triggers = [NSArray arrayWithObject:trigger];
        else
            _triggers = [_triggers arrayByAddingObject:trigger];
        
        if(_chainRun)
           [trigger validateEvent];

    }
    
}


- (void) startEvent: (NSString*) name If:(YACondition*) condition {
    YAEvent* event = [_events objectForKey:name];
    if(event) {
        YATrigger* trigger = [[YATrigger alloc] initTriggerForEvent:event];
        NSArray* element = [NSArray arrayWithObjects:condition, trigger, nil];
        
        if(!_conditions)
            _conditions = [NSArray arrayWithObject:element];
        else
            _conditions = [_conditions arrayByAddingObject:element];
        
        
        if(_chainRun)
            [trigger validateEvent];

        
    }
}

-(void) onSchedule: (NSTimer*) timer
{
    for (NSArray* element in _conditions) {
        YACondition* condition = [element objectAtIndex:0];

        if(condition.valid) {
            YATrigger* trigger = [element objectAtIndex:1];
            [trigger validateEvent];
        }
    }

}


-(void) stop
{
    if(_queue)
        _queue = nil;
    
    if(_scheduleTimer)
        [_scheduleTimer invalidate];
}


-(void) start {
    // NSLog(@"Start Event Chain");
    
    for(YAEvent* event in [_events allValues])
        [self updateEventState:event];
    
    _chainRun = true;
    
    for(YATrigger* trigger in _triggers)
        [trigger validateEvent];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _scheduleTimer = [NSTimer scheduledTimerWithTimeInterval:1.f/25.f
                                                 target:self
                                               selector:@selector(onSchedule:)
                                               userInfo:nil
                                                repeats:YES];
       [[NSRunLoop currentRunLoop] run];
    });
}

-(void) onStartBridge: (NSTimer*) timer
{
    [self start];
}


-(void) startWithDelay: (float)  time {
    _delayTimer = [NSTimer scheduledTimerWithTimeInterval:time
                                                  target:self
                                                selector:@selector(onStartBridge:)
                                                userInfo:nil
                                                 repeats:NO];
}


// Helper
- (void) startEvent: (NSString*) name following: (NSString*) waitFor WithDelay: (float) time {

    YACondition* condition = [[YACondition alloc] init];
    YAEvent* waitForEvent = [_events objectForKey:waitFor];

    NSArray* conditionValues = [NSArray arrayWithObject:waitForEvent];
    [condition setValues:conditionValues];
    [condition setTestOperator:TEST_AND];

    YAEvent* event = [_events objectForKey:name];

    if(event) {

        YATimerTrigger* trigger = [[YATimerTrigger alloc] initTriggerForEvent:event];
        [trigger setDelay:time];
        [trigger setQueue:_queue];
        
        NSArray* element = [NSArray arrayWithObjects:condition, trigger, nil];

        if(!_conditions)
            _conditions = [NSArray arrayWithObject:element];
        else
            _conditions = [_conditions arrayByAddingObject:element];
        
    }
}

- (void) startEvent: (NSString*) name following: (NSString*) waitFor
{
    YACondition* condition = [[YACondition alloc] init];
    YAEvent* waitForEvent = [_events objectForKey:waitFor];
    [condition setValues:[NSArray arrayWithObject:waitForEvent]];
    [condition setTestOperator:TEST_AND];
    [self startEvent:name If:condition];
}


@end
