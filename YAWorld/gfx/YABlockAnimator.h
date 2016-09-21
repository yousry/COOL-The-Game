//
//  YABlocksAnimator.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 31.10.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import "YABasicAnimator.h"

typedef void (^ListenerBlock)(float sp, NSNumber* event, int message);

@interface YABlockAnimator : YABasicAnimator 

- (void) addListener: (ListenerBlock) listener;

@property (assign, readwrite) bool oneExecution;

@end
