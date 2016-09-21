//
//  YAMoonClockEvent.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 30.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YAEvaluable.h"


@interface YAMoonClockEvent : NSObject

- (ListenerEvent) setupEvent;
- (ListenerEvent) shutdownEvent;
- (ListenerEvent) showEvent;
- (ListenerEvent) hideEvent;

@end
