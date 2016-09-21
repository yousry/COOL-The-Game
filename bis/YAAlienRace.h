//
//  YAAlienRace.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 03.09.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YAImpersonatorMover.h"
@class YAIngredient, YAImpersonator, YAStore, YAColonyMap, YAGameContext, YARenderLoop;

@interface YAAlienRace : NSObject {
@protected
    YARenderLoop* _world;
    id<YAImpersonatorMover> mover;
    int playerId;
    
    float defaultSize;
    YAImpersonator* impersonator;
    YAIngredient* ingredient;
    
}

@property (assign, readonly) int playerId;
@property (strong, readonly) YAIngredient* ingredient;
@property (strong, readonly) YAImpersonator* impersonator;

@property (assign, readwrite) int money;

//@property (assign, readonly) int land;
-(int) getLand;

//@property (assign, readonly) int goods;
-(int) getGoods;


@property (assign, readwrite) int foodUnits;
@property (assign, readwrite) int energyUnits;
@property (assign, readwrite) int crystaliteUnits;
@property (assign, readwrite) int smithoreUnits;

@property (weak, readwrite) YAStore* store;
@property (weak, readwrite) YAColonyMap* colonyMap;
@property (weak, readwrite) YAGameContext* gameContext; // TODO: Use game level

- (void) sizeNormal;
- (void) sizeSmall;
- (void) sizeTiny;
- (void) sizeScoreboard;
- (void) sizeTitzyTiny;
- (void) restartMover;

- (id<YAImpersonatorMover>) impMover;

- (int) totalValue;

@end
