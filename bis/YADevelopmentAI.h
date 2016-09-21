//
//  YADevelopmentAI.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 05.03.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "YADevelopmentPlayer.h"
@class YAFortune, YAAlienRace;

@interface YADevelopmentAI : NSObject <YADevelopmentPlayer>

@property YAFortune* fortune;

- (int) chooseFabX: (int)x Z: (int) z Player: (YAAlienRace*) player;

@end
