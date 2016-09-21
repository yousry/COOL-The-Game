//
//  YASocketEvents.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 21.01.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YAEvaluable.h"

@interface YASocketEvents : NSObject

- (ListenerEvent) setupFab;
- (ListenerEvent) plotAssayEvent;

@end
