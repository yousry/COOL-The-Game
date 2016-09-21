//
//  YAAlienRace.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 03.09.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YAColonyMap.h"
#import "YAStore.h"
#import "YAImpersonator.h"
#import "YAAlienRace.h"

@implementation YAAlienRace
@synthesize ingredient, impersonator;
@synthesize money;
@synthesize playerId;
@synthesize foodUnits,energyUnits,smithoreUnits,crystaliteUnits;
@synthesize store, colonyMap, gameContext;


- (id) init {
    self = [super init];
    
    if(self) {
        foodUnits = 5;
        energyUnits = 5;
        smithoreUnits = 0;
        crystaliteUnits = 0;
    }

    return self;
    
}

- (int) getLand
{
    NSAssert(store != nil, @"Store not accessible");
    NSAssert(colonyMap != nil, @"Colony Map not accessible");
    const int emptyPlots = (int)[[colonyMap getEmptyPlots:playerId] count];
    const int developedPlots = (int)[[colonyMap getAllPlots:playerId] count] - emptyPlots;
    return emptyPlots * store.plotUnitPriceEmpty + developedPlots * store.plotUnitPriceDeveloped;
}

//@property (assign, readonly) int goods;
-(int) getGoods
{
    NSAssert(store != nil, @"Store not accessible");
    NSAssert(colonyMap != nil, @"Colony Map not accessible");
    
    int result = 0;
    result += foodUnits * store.foodUnitPrice;
    result += energyUnits * store.energyUnitPrice;
    result += smithoreUnits * store.smithoreUnitPrice;
    result += crystaliteUnits * store.crystaliteUnitPrice;

    return result;
}

- (int) totalValue
{
    return money + [self getLand] + [self getGoods];
}


- (void) sizeNormal
{
    [impersonator resize:defaultSize];
}

- (void) sizeSmall
{
    [impersonator resize:defaultSize * 0.5];
}

- (void) sizeTiny
{
    [impersonator resize:defaultSize * 0.25];
}

- (void) sizeScoreboard
{
    [impersonator resize:defaultSize * 0.2];
}


- (void) sizeTitzyTiny
{
    [impersonator resize:defaultSize * 0.02];
}


- (id<YAImpersonatorMover>) impMover
{
    return mover;
}

- (void) restartMover
{
    [mover setupKinematik];
}


@end
