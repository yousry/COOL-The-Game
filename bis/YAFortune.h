//
//  YAFortune.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 04.03.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YASceneUtils, YAImpCollector, YARenderLoop, YAColonyMap, YAGameContext, YAStore, YASoundCollector;

@interface YAFortune : NSObject

@property (weak, readwrite) NSArray* players;
@property (weak, readwrite) YASceneUtils* sceneUtils;
@property (weak, readwrite) YAImpCollector* impCollector;
@property (weak, readwrite) YARenderLoop* world;
@property (weak, readwrite) YAColonyMap* colonyMap;
@property (weak, readwrite) YAGameContext* gameContext;
@property (weak, readwrite) YAStore* store;
@property (weak, readwrite) YASoundCollector* soundCollector;



- (float) fortuneFor: (int) playerId;
- (float) gambleFor: (int) playerId usedTime: (float) timeInPercent At: (float) myTime;

- (float) globalFortune;

@end
