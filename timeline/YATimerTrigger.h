//
//  YATimerTrigger.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 26.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YATrigger.h"
#import <dispatch/dispatch.h>
#import <Foundation/Foundation.h>

@interface YATimerTrigger : YATrigger {
    bool _willRun;
}

@property (readwrite) dispatch_queue_t queue;
@property (readwrite) float delay;


@end
