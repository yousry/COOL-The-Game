//
//  HIDReader.h
//
//  Created by Yousry Abdallah on 14.09.11.
//  Copyright 2013 yousry.de. All rights reserved.

#import <dispatch/dispatch.h>
#import <Foundation/Foundation.h>

@class YARenderLoop;

@interface HIDReader : NSObject {
	YARenderLoop* renderLoop;
    dispatch_queue_t q_default;
	dispatch_source_t timer[16];
}

- (id) initWithWorld: (YARenderLoop*) RL;

@property (strong, readwrite) NSArray* devices;
@property (strong, readwrite) NSMutableDictionary* lastCommands;

-(void) setupGamepad;

-(YARenderLoop*) getRenderLoop;

@end