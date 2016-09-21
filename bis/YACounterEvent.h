//
//  YACounterEvent.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 11.01.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YAEvaluable.h"


@interface YACounterEvent : NSObject


@property (assign, readwrite) float roundTime;

- (ListenerEvent) fiveSecondsCountdownEvent;
- (ListenerEvent) roundTimeCountdownEvent;
- (ListenerEvent) GameTimerEvent;

@end
