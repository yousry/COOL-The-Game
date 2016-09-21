//
//  YAEagleFlightEvents.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 01.01.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YAEvaluable.h"
@class YAEagleController;

@interface YAEagleFlightEvents : NSObject {
    YAEagleController* eac;
    __block volatile YAImpGroup* eagleGroup;

}

- (ListenerEvent) flyEvent;


@end
