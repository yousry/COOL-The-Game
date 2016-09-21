//
//  YATrigger.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 26.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YAEvent, YAEventChain;

@interface YATrigger : NSObject {
@protected
    YAEvent* _event;
}

- (id) initTriggerForEvent: (YAEvent*) event;

@property (strong, readwrite) YAEvent* event;

- (void) validateEvent;

@end
