//
//  YAEventChain.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 26.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <dispatch/dispatch.h>
#import <Foundation/Foundation.h>
@class YAEvent, YACondition;

@interface YAEventChain : NSObject {
    NSMutableDictionary* _events;
    dispatch_queue_t _queue;
    NSArray* _triggers;

    // element of _conditions consist of a condition + trigger
    NSArray* _conditions;
    NSTimer* _scheduleTimer;
    NSTimer* _delayTimer;


@private
    bool _chainRun;

}

@property (strong, readwrite) NSDictionary* eventInfo;

- (YAEvent*) addEvent: (NSString*) name;
- (void) addEvents: (NSArray*) names;

- (YAEvent*) getEvent: (NSString*) name;

- (void) startEvent: (NSString*) name; // without Trigger
- (void) startEvent: (NSString*) name At:(float) time;
- (void) startEvent: (NSString*) name If:(YACondition*) condition;

-(void) start;
-(void) stop;

-(void) startWithDelay: (float)  time;
-(void) resetEvents: (NSArray*) events;

// Helper
- (void) startEvent: (NSString*) name following: (NSString*) waitFor;
- (void) startEvent: (NSString*) name following: (NSString*) waitFor WithDelay: (float) time;

-(void) onSchedule: (NSTimer*) timer;

@end
