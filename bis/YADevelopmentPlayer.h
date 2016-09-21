//
//  YADevelopmentPlayer.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 05.03.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YADevelopmentPlayer <NSObject>

@required
-(id) initInfo: (NSDictionary*) info;

@property(weak, readwrite) NSDictionary* info;
@property(assign, readwrite) bool finished;

- (void) play: (int) playerId;

@end
