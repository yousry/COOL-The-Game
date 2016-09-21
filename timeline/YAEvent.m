//
//  YAEvent.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 26.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YAEvent.h"

@implementation YAEvent
@synthesize valid, state, name = _name;


- (id) initWithName: (NSString*) name
{
    self = [super init];
    
    if(self) {
        _name = name;
    }
    
    return self;
}

- (void) addListener: (ListenerEvent) listener
{
    if(!_listeners)
        _listeners = [NSArray arrayWithObject:listener];
    else
        [_listeners arrayByAddingObject:listener];
    
}

- (void) start
{
    
    @try {
        for(ListenerEvent listener in _listeners) {
            listener(state);
        }
    }
    @catch (NSException *exception) {
        // NSLog(@"Exception raised: %@", exception);
    }
}


@end
