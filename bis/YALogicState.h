//
//  YALogicState.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 18.04.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YAGameContext;

@protocol YALogicState <NSObject>

@required
- (void) setupScene;
- (void) clearScene;

@property YAGameContext* gameContext;

@optional
// an array with model/shader dictionaries
@property NSArray* modelsWitShader;


@end
