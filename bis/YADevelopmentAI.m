//
//  YADevelopmentAI.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 05.03.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import "YALog.h"
#import "YAFortune.h"
#import "YAMaterial.h"
#import "YAStore.h"
#import "YAProbability.h"
#import "YAVector2i.h"
#import "YAVector3f.h"
#import "YAImpersonator.h"
#import "YAImpCollector.h"
#import "YASoundCollector.h"
#import "YAMapManagement.h"
#import "YABlockAnimator.h"
#import "YAGameContext.h"
#import "YASceneUtils.h"
#import "YARenderLoop.h"
#import "YAColonyMap.h"

#import "YADevelopmentAI.h"

@implementation YADevelopmentAI {
    YAGameContext* gameContext;
    YASceneUtils* sceneUtils;
    YARenderLoop* world;
    YAColonyMap* colonyMap;
    YABlockAnimator* dummy;
    
    YAMapManagement* mapManagement;
    YASoundCollector* soundCollector;
    YAImpCollector* impCollector;
    YAStore* store;
    
    float restoreHeight;
    
    YAVector2i* storedCursorPos;
}

@synthesize info = _info;
@synthesize finished = _finished;

-(id) initInfo: (NSDictionary*) info
{
    self = [super init];
    
    if(self) {
        _info = info;
        _finished = false;
        [self setupGlobals:info];
        
        mapManagement = [[YAMapManagement alloc] init];
        mapManagement.gameContext = gameContext;
        mapManagement.colonyMap = colonyMap;
        mapManagement.sceneUtils = sceneUtils;
        mapManagement.world = world;
        mapManagement.cursorInnerImp = impCollector.cursorInnerImp;
        mapManagement.cursorOuterImp = impCollector.cursorOuterImp;
        mapManagement.soundCollector = soundCollector;
        
        mapManagement.terrainImp = impCollector.terrainImp;
        mapManagement.terrain = [info objectForKey:@"TERRAIN"];
        
        
    }
    return self;

}

- (int) chooseFabX: (int)x Z: (int) z Player: (YAAlienRace*) player;
{
    float height = [colonyMap heightX:x Z:z];

    if([colonyMap plotSamplesX:x Z:z] && [colonyMap plotCrystaliteX:x Z:z] >= 0.9f)
        return HOUSE_CRYSTALYTE;
    
    if(height < 0) // below sea level
        height = 0;
    
    float pHeigh = [YAProbability mapToProbRange:height From:0 To:255];

    NSArray* elements = [NSArray arrayWithObjects:
                        [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:HOUSE_FARM], @1.0f, nil],
                        [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:HOUSE_ENERGY], @1.0f, nil],
                        [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:HOUSE_SMITHORE], @1.0f, nil],
                        nil];
    
    
    if(pHeigh <= 0.14)
        [YAProbability changeEventProbability:+1 Index:0 In:elements];
    else if(pHeigh <= 0.21)
        [YAProbability changeEventProbability:+1 Index:1 In:elements];
    else
        [YAProbability changeEventProbability:+1 Index:2 In:elements];

    const float availableSmithore = (float)store.smithoreStock + (float)player.smithoreUnits;
    if(availableSmithore <= 10) {
        float smithoreProb = 1.0f - [YAProbability mapToProbRange:availableSmithore From:0 To:10];
        smithoreProb = [YAProbability sinPowProb:smithoreProb];
        [YAProbability changeEventProbability:smithoreProb Index:2 In:elements];
    }
    
    const float availableFood = (float)store.foodStock + (float)player.foodUnits;
    if(availableFood <= 10) {
        float foodProb = 1.0f - [YAProbability mapToProbRange:availableFood From:0 To:10];
        foodProb = [YAProbability sinPowProb:foodProb];
        [YAProbability changeEventProbability:foodProb Index:0 In:elements];
    }

    const float availableEnergy = (float)store.energyStock + (float)player.energyUnits;
    if(availableEnergy <= 10) {
        float energyProb = 1.0f - [YAProbability mapToProbRange:availableEnergy From:0 To:10];
        energyProb = [YAProbability sinPowProb:energyProb];
        [YAProbability changeEventProbability:energyProb Index:1 In:elements];
    }
    
    house_type result = (house_type)[[YAProbability randomSelect:elements] intValue];
    
    return result;
}


- (float) moveCursor: (YAVector2i*) colMapPos startTime: (float) myTime
{
    YAVector2i* curPos = [[YAVector2i alloc] initVals:colMapPos.x :6 - colMapPos.y];
    float distance = storedCursorPos == nil ? 0 : [curPos distanceTo:storedCursorPos];
    storedCursorPos = [[YAVector2i alloc] initCopy:curPos];
    return [mapManagement moveCursor:myTime Position:curPos withCamera:false Distance:distance];
}

- (void) play: (int) playerId
{
    // NSLog(@"Bot %d is playing", playerId);
    YAAlienRace* player = [gameContext playerDataForId:playerId];

    int availableActivities = player.foodUnits; // too take food shortage into account
    if(availableActivities == 0)
        availableActivities = 1;
    
    restoreHeight = impCollector.cursorInnerImp.translation.y;
    impCollector.cursorInnerImp.visible = YES;
    impCollector.cursorOuterImp.visible = YES;
    
    impCollector.cursorInnerImp.translation.x = 0;
    impCollector.cursorInnerImp.translation.z = 0;
    impCollector.cursorOuterImp.translation.x = 0;
    impCollector.cursorOuterImp.translation.z = 0;
    
    
    float myTime = [self moveCursor:[[YAVector2i alloc] initVals:3 :3] startTime:0];

    
    NSArray* emptyPlots = [colonyMap getEmptyPlots:playerId];

    
    // manage empty plots
    for(YAVector2i* pos in emptyPlots) {
        
        house_type myFab = [self chooseFabX:pos.x Z:pos.y Player:player];
        
        int bill = 0;
        bill += store.camelPrice;
        
        switch (myFab) {
            case HOUSE_SMITHORE:
                bill += store.smithoreFabPrice;
                break;
            case HOUSE_CRYSTALYTE:
                bill += store.crystaliteFabPrice;
                break;
            case HOUSE_FARM:
                bill += store.farmFabPrice;
                break;
            case HOUSE_ENERGY:
                bill += store.energyFabPrice;
                break;
            default:
                break;
        }

        if(player.money > bill && store.camelsAvailable > 0 && availableActivities > 0) { // buy
            myTime = [self moveCursor:pos startTime:myTime + 1];
            myTime += 0.5f;
            player.money -= bill;
            store.camelsAvailable -=1;
            availableActivities -= 1;
            [colonyMap setFab:myFab X:pos.x Z:pos.y At:myTime];
        }
        
        myTime += 2.0f;
    }

    // search for crystalite
    int curiosity = [YAProbability selectOneOutOf:3];
    
    if(colonyMap.foundCrystalHerds > 2 || colonyMap.vacantPlots < 1 || gameContext.gameDifficulty < 2)
        curiosity = 0;
    
    for(int i = 0; i < curiosity;  i++) {
        YAVector2i* vacantPlot = [colonyMap randomVacantPlot];
        
        if(![colonyMap plotSamplesX:vacantPlot.x Z:vacantPlot.y] && player.money > store.assayPrice && availableActivities > 0) {
            float crystaliteConcentration = [colonyMap plotCrystaliteX:vacantPlot.x Z:vacantPlot.y];
            
            player.money -= store.assayPrice;
            availableActivities -= 1;
            
            NSArray* elements = [NSArray arrayWithObjects:
                                 [NSMutableArray arrayWithObjects:[YALog decode:@"noCrystalite"], @1.0f, nil],
                                 [NSMutableArray arrayWithObjects:[YALog decode:@"lowCrystalite"], @1.0f, nil],
                                 [NSMutableArray arrayWithObjects:[YALog decode:@"mediumCrystalite"], @1.0f, nil],
                                 [NSMutableArray arrayWithObjects:[YALog decode:@"highCrystalite"], @1.0f, nil],
                                 nil];
            
            NSString* crystaliteScore = [YAProbability sampleSelect:elements Sample:crystaliteConcentration];
            
            YAImpersonator* infoTextImp = [sceneUtils genText:crystaliteScore];
            [[[infoTextImp material] phongAmbientReflectivity] setVector:sceneUtils.color_red];
            [infoTextImp setVisible: NO];
            [infoTextImp resize:0.15];
            [[infoTextImp translation] setVector:[[YAVector3f alloc] initVals:-1.2 :-1.0 :5]];
            [[infoTextImp material] setEta:0.5];
            [sceneUtils alignToCam:infoTextImp];
            
            myTime = [self moveCursor:vacantPlot startTime:myTime + 1];
            
            [sceneUtils showImp:infoTextImp atTime:myTime];
            
            myTime += 2;
            [sceneUtils removeImp:infoTextImp atTime:myTime];
        }
    }

    // gambling
    myTime = [self moveCursor:[[YAVector2i alloc] initVals:3 :3] startTime:myTime + 1];
    
    
    float usedTime = fminf((player.foodUnits - availableActivities) / 5.0f, 1.0f);
    myTime = [_fortune gambleFor: playerId usedTime:usedTime At:myTime];

    dummy = [world createBlockAnimator];
    dummy.oneExecution = YES;
    dummy.delay = myTime + 1;
    __weak YADevelopmentAI* selfW = self;
    
    [dummy addListener:^(float sp, NSNumber *event, int message) {
        // NSLog(@"Switching to finished");
        [selfW cleanup];
        selfW.finished = YES;
    }];
}

- (void) cleanup {
    impCollector.cursorInnerImp.visible = NO;
    impCollector.cursorOuterImp.visible = NO;
}

-(void) setupGlobals: (NSDictionary*) info
{
    gameContext = [info objectForKey:@"GAMECONTEXT"];
    sceneUtils = [info objectForKey:@"SCENEUTILS"];
    world = [info objectForKey:@"WORLD"];
    colonyMap = [info objectForKey:@"COLONYMAP"];
    
    soundCollector = [info objectForKey:@"SOUNDCOLLECTOR"];
    impCollector = [info objectForKey:@"IMPCOLLECTOR"];
    
    store = [info objectForKey:@"STORE"];

}


@end
