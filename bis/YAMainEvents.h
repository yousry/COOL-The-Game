//
//  YAMainEvents.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 29.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YAEvaluable.h"


@interface YAMainEvents : NSObject

- (ListenerEvent) standByEvent;
- (ListenerEvent) setupStoreEvent;
- (ListenerEvent) spaceshipLandEvent;
- (ListenerEvent) spaceshipStartEvent;
- (ListenerEvent) showScoreBoardEvent;

@end
