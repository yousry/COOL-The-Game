//
//  YAEvaluable.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 26.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ListenerEvent)(NSDictionary* info);


@protocol YAEvaluable <NSObject>

@required
@property (atomic, readwrite) bool valid;

@end
