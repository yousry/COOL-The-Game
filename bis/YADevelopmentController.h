//
//  YADevelopmentController.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 05.03.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YADevelopmentPlayer.h"
@class YAFortune;

@interface YADevelopmentController : NSObject <YADevelopmentPlayer>

@property YAFortune* fortune;

@end
