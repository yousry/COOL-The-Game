//
//  YAEvent.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 26.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YAEvaluable.h"

@interface YAEvent : NSObject <YAEvaluable> {
    NSString* _name;
    NSArray* _listeners;
}

- (id) initWithName: (NSString*) name;
- (void) start;
- (void) addListener: (ListenerEvent) listener;

@property (strong, readwrite) NSDictionary* state;
@property (strong, readonly) NSString* name;

@end
