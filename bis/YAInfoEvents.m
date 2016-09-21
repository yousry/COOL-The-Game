//
//  YAInfoEvents.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 31.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YALog.h"
#import "YASoundCollector.h"
#import "YAAlienRace.h"
#import "YAStore.h"
#import "YAVector2i.h"
#import "YAGameContext.h"
#import "YATerrain.h"
#import "YAColonyMap.h"
#import "YARenderLoop.h"
#import "YAMaterial.h"
#import "YAVector3f.h"
#import "YABlockAnimator.h"
#import "YASceneUtils.h"
#import "YAEventChain.h"
#import "YAImpersonator.h"
#import "YAImpCollector.h"

#import "YAInfoEvents.h"

@implementation YAInfoEvents {
    YAImpersonator *roundLeftInfo, *tickerTextImp;
    
    YAColonyMap* colonyMap;
    YASceneUtils* sceneUtils;
    YAGameContext* gameContext;
    YARenderLoop* world;
    YAStore* store;
    YASoundCollector* soundCollector;
    YAImpCollector* impCollector;
}

- (ListenerEvent) roundsleftEvent
{
    
    ListenerEvent listener = ^(NSDictionary *info) {
        // NSLog(@"Rounds Left Info Event");
        
        float myTime = 0;
        
        sceneUtils = [info objectForKey:@"SCENEUTILS"];
        gameContext = [info objectForKey:@"GAMECONTEXT"];
        colonyMap = [info objectForKey:@"COLONYMAP"];
        store = [info objectForKey:@"STORE"];
        soundCollector = [info objectForKey:@"SOUNDCOLLECTOR"];
        impCollector = [info objectForKey:@"IMPCOLLECTOR"];

        NSString* tickerText = [self report];
        NSString* value = [NSString stringWithFormat:@"%@ %d", [YALog decode:@"roundsLeft"], 12 - gameContext.round];
        
        if(gameContext.round == 0) {
            value = [YALog decode:@"leavingInfo"];
        } else if(gameContext.gameOver) {
            int winnerId = -1;
            int winnerScore = -1;
            for(int playerId = 0; playerId <4; playerId++) {
                YAAlienRace* player = [gameContext playerDataForId:playerId];
                if(player.totalValue > winnerScore) {
                    winnerId = playerId;
                    winnerScore = player.totalValue;
                }
                value = [YALog decode:@"winnerInfo"];
                value = [value stringByReplacingOccurrencesOfString:@"_" withString:([NSString stringWithFormat:@"%d", winnerId + 1])];
            }
            
            int jingleId = [soundCollector getJingleId:@"melodyC"];
            [soundCollector stopJingle: jingleId];
        } else {
            int jingleId = [soundCollector getJingleId:@"melodyB"];
            [soundCollector stopJingle: jingleId];
        }
        
        // Update level Information
        gameContext.round += 1;
        
        roundLeftInfo = [sceneUtils genTextBlocked:value];
        [roundLeftInfo resize:0.25];
        roundLeftInfo.material.eta = 0.35;
        [[roundLeftInfo translation] setVector:[[YAVector3f alloc] initVals:-1.0 :0 :5]];
        
        [[[roundLeftInfo material] phongAmbientReflectivity] setVector:sceneUtils.color_yellow];
        [roundLeftInfo setClickable:false];
        [roundLeftInfo setVisible:false];
        
        [sceneUtils alignToCam:roundLeftInfo AtTime:myTime];
        [sceneUtils showImp:roundLeftInfo atTime:myTime];
        
        tickerTextImp = [sceneUtils genTextBlocked:tickerText];
        [[[tickerTextImp material] phongAmbientReflectivity] setVector:sceneUtils.color_white];
        [tickerTextImp resize:0.15];
        
        [[tickerTextImp translation] setVector:[[YAVector3f alloc] initVals:1.8 :-0.8 :5.5]];
        [[tickerTextImp material] setEta:0.5];
        [sceneUtils tickerText:tickerTextImp atTime:0 withLength:2.5 * (int)tickerText.length];

    };
    
    return listener;
}


// WARNING: Sideeffect set gameContext to Game Over
-(NSString*) report
{
    NSString* result = @"";

    int gameFarmFabs = 0;
    int gameEnergyFabs = 0;
    int gameFoodUnits = store.foodStock;
    int gameEnergyUnits = store.energyStock;
    int camels = store.camelsAvailable;
    int colonyTotal = 0;

    int  necessaryFood = 3 * 4;
    if (gameContext.round >= 5)
        necessaryFood = 4 * 4;
    else if(gameContext.round >= 9)
        necessaryFood = 5 * 4;
    
    int necessaryEnergy = 0;
    [colonyMap getAllProduction];
    for (YAVector2i* plot in [colonyMap getAllProduction]) {
        house_type house = [colonyMap plotHouseAtX:plot.x Z:plot.y];
        if(house != HOUSE_ENERGY && house != HOUSE_NONE)
            necessaryEnergy += 1.0f;
        
        if(house == HOUSE_ENERGY)
            gameEnergyFabs++;
        else if(house == HOUSE_FARM)
            gameFarmFabs++;
    }
    
    for(int playerId = 0; playerId < 4; playerId++) {
        YAAlienRace* player = [gameContext playerDataForId:playerId];
        gameFoodUnits += player.foodUnits;
        gameEnergyUnits += player.energyUnits;
        colonyTotal += player.totalValue;
    }
    
    bool gameOverFood = (gameFarmFabs == 0) && (gameFoodUnits == 0);
    bool gameOverEnergy = (gameEnergyFabs == 0) && (gameEnergyUnits == 0);
    
    bool camelShortage = camels < 14; // tournament values
    bool energyShortage = gameEnergyUnits < necessaryEnergy;
    bool foodShortage = gameFoodUnits < necessaryFood;
    
    bool gameOver = NO;
    
    if(gameContext.round >= gameContext.finalRound || gameOverFood || gameOverEnergy)
        gameOver = YES;
    
    gameContext.gameOver = gameOver;
    
    if(gameOverFood)
        result = [YALog decode:@"gameOverFood"];
    else if(gameOverEnergy)
        result = [YALog decode:@"gameOverEnergy"];
    else if(gameOver) {
        if(colonyTotal <= 2500)
            result = [YALog decode:@"colonyLevelA"];
        else if(colonyTotal <= 9000)
            result = [YALog decode:@"colonyLevelB"];
        else if(colonyTotal <= 15500)
            result = [YALog decode:@"colonyLevelC"];
        else if(colonyTotal <= 22000)
            result = [YALog decode:@"colonyLevelD"];
        else if(colonyTotal <= 28500)
            result = [YALog decode:@"colonyLevelE"];
        else if(colonyTotal <= 35000)
            result = [YALog decode:@"colonyLevelF"];
        else
            result = [YALog decode:@"colonyLevelG"];
    } else if(camelShortage || energyShortage || foodShortage) {
        if(camelShortage && !energyShortage && !foodShortage) {
            result = [YALog decode:@"ShopCamelShortage"];
        } else {
            NSString *shortages = @"";
            if(camelShortage)
                shortages = [YALog decode:@"CamelName"];
          
            if(energyShortage) {
                if(shortages.length > 0)
                    shortages = [NSString stringWithFormat:@"%@ %@", shortages, [YALog decode:@"AndName"]];
                shortages = [NSString stringWithFormat:@"%@ %@", shortages, [YALog decode:@"EnergyName"]];
            }
            
            if(foodShortage) {
                if(shortages.length > 0)
                    shortages = [NSString stringWithFormat:@"%@ %@", shortages, [YALog decode:@"AndName"]];
                shortages = [NSString stringWithFormat:@"%@ %@", shortages, [YALog decode:@"FoodName"]];
            }

            result = [YALog decode:@"ShortageList"];
            result = [result stringByReplacingOccurrencesOfString:@"_" withString:shortages];
        
        }
    }
        
    return result;
}

- (ListenerEvent) removeRoundsleftEvent
{
    
    ListenerEvent listener = ^(NSDictionary *info) {
        // NSLog(@"Remove Rounds Left Info Event");
        sceneUtils = [info objectForKey:@"SCENEUTILS"];
        [sceneUtils removeImp:roundLeftInfo atTime:0];
        [sceneUtils removeImp:tickerTextImp atTime:0];
        
        [soundCollector stopAllSounds];
        
    };
    
    return listener;
}



@end
