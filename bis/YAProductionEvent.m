//
//  YAProductionEvent.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 08.03.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import "YALog.h"
#import "YAEvent.h"
#import "YAEventChain.h" 
#import "YABlockAnimator.h"
#import "YAProbability.h"
#import "YAMaterial.h"
#import "YAAvatar.h"
#import "YAVector2i.h"
#import "YAVector3f.h"
#import "YAVector4f.h"
#import "YAMaterial.h"
#import "YAChronograph.h"
#import "YAImpersonator.h"
#import "YABasicAnimator.h"
#import "YAImpCollector.h"
#import "YAGameContext.h"
#import "YASceneUtils.h"
#import "YARenderLoop.h"
#import "YAColonyMap.h"
#import "YAEventChain.h"
#import "YAProductionEvent.h"
#import "YAFortune.h"
#import "YASoundCollector.h"
#import "YAStore.h"

#define async(cmds) dispatch_async(dispatch_get_main_queue(), ^{ cmds });
#define sync(cmds) dispatch_sync(dispatch_get_main_queue(), ^{ cmds });

#define PRDUCTION_TICS 8

@implementation YAProductionEvent {
    NSDictionary* _info;
    
    YAGameContext* gameContext;
    YASceneUtils* sceneUtils;
    YARenderLoop* world;
    YAColonyMap* colonyMap;
    YAImpCollector* impCollector;
    YASoundCollector* soundCollector;
    YAEventChain* eventChain;
    YAStore* store;
    
    YAFortune* fortune;
    YAChronograph* chronograph;
    NSArray* players;
}


- (id) init
{
    self = [super init];
    if(self) {
        chronograph = [[YAChronograph alloc] init];
        _info = nil;
        fortune = [[YAFortune alloc] init];
    }
    return self;
}

- (ListenerEvent) productionEvent
{
    ListenerEvent listener = ^(NSDictionary *info) {
        // NSLog(@"Production Event Started");

        _info = info;
        [self setupGlobals:info];

        // recalculate Shop Prices
        if(gameContext.round > 1)
            [store updatePrices];
        
        // the probability is recalculated in each round
        [colonyMap clearProductivity];
        
        [sceneUtils setAvatarPositionTo:AVATAR_DEVELOPMENT];
        players = gameContext.playerGameData;
        fortune.sceneUtils = sceneUtils;
        fortune.players = players;
        fortune.impCollector = impCollector;
        fortune.world = world;
        fortune.colonyMap = colonyMap;
        fortune.gameContext = gameContext;
        fortune.store = store;
        fortune.soundCollector = soundCollector;

        // start with a global event
        float myTime = [fortune globalFortune];
        myTime += 0.5f; // be sure that all fortune kinematics are finished
        
        [chronograph wait:myTime];
        
        YAImpersonator* titleImp = [self createTitle];
        
        // gather all productiove plots
        NSArray* productivePlots = [colonyMap getAllProduction];

        // calcualte the productivity
        for(YAVector2i* plotPos in productivePlots)
            [self calcPlotProductivityAt:plotPos];

        // for each plot create text imp
        NSMutableArray* textImps = [[NSMutableArray alloc] init];
        
        
        // bonus calculation
        for(int playerId = 0; playerId < 4; playerId++) {
            
            for(NSNumber* houseN in [NSArray arrayWithObjects:
                                     [NSNumber numberWithInt:HOUSE_ENERGY],
                                     [NSNumber numberWithInt:HOUSE_FARM],
                                     [NSNumber numberWithInt:HOUSE_SMITHORE],
                                     nil]) {
                NSArray* plots = [colonyMap getAllPlots:playerId OfType:houseN.intValue];
                
                int adder = (int)plots.count / 3;
                
                for(YAVector2i* plot in plots) {
                    [colonyMap addProduction:plot Amount:adder];
                    
                    if([colonyMap sameNeighbour:plot] >= 2)
                        [colonyMap addProduction:plot Amount:1];
                }
            }
        }

        
        for(YAVector2i* plotPos in productivePlots) {
            YAImpersonator* imp = [self createTextImpAt:plotPos];
            [textImps addObject:imp];
        }

        // each production cycle consists of # ticks
        for(int tick = 0; tick < PRDUCTION_TICS; tick++) {

            for(YAVector2i* plotPos in productivePlots) {
                const float probabilaty = [colonyMap productivityProbability:plotPos];
                const bool isProduct = [YAProbability dice:probabilaty];
                if(isProduct && [colonyMap plotProduction:plotPos] < 8) {
                    [colonyMap addProduction:plotPos Amount:1];
                    const int products = [colonyMap plotProduction:plotPos];
                    if(products > 0) {
                        const NSUInteger plotIndex = [productivePlots indexOfObject:plotPos];
                        
                        if(plotIndex != NSNotFound) {

                            YAImpersonator* textImp = [textImps objectAtIndex:plotIndex];
                            if(textImp) {
                                
                                const float delay = (0.4 / (float)productivePlots.count) * plotIndex;
                                
                                NSString* productValue = [NSString stringWithFormat:@"%d",products];
                                YABlockAnimator* anim = [world createBlockAnimator];
                                anim.oneExecution = YES;
                                anim.delay = delay;
                                [anim addListener:^(float sp, NSNumber *event, int message) {
                                    [[[textImp material] phongAmbientReflectivity] setVector:sceneUtils.color_yellow];
                                    [world updateTextIngredient: productValue Impersomator:textImp];
                                    [soundCollector playForImp:textImp Sound:[soundCollector getSoundId:@"LaserC"]];
                                }];
                                
                            }
                        }
                    }
                }
            }
            [chronograph wait: 0.5];
        }
        
        // Wait for player Confirmation
        [self waitForPlayers];
        [sceneUtils removeImp:titleImp atTime:0];
        for(YAImpersonator* imp in textImps)
            [sceneUtils removeImp:imp atTime:0];
        
        
        // zero negative production
        for(YAVector2i* plotPos in productivePlots) {
            int amount = [colonyMap plotProduction:plotPos];
            if(amount < 0)
                [colonyMap addProduction:plotPos Amount:amount * -1];
        }

        // move to next state
        if([[eventChain getEvent:@"comoditiesAuction"] valid])
            [eventChain resetEvents:[NSArray arrayWithObject:@"comoditiesAuction"]];
        else
            [eventChain startEvent:@"comoditiesAuction"];
        
    };

    return listener;
}

- (YAImpersonator*) createTextImpAt: (YAVector2i*) plotPos
{
    
    int products = [colonyMap plotProduction:plotPos];

    if(products < 0)
        products = 0;
    
    NSString* productValue = [NSString stringWithFormat:@"%d", products];
    YAImpersonator* textImp = [sceneUtils genTextBlocked:productValue];
    [textImp resize:1];
    
    YAVector3f* impPos = [colonyMap calcWorldPosX:plotPos.x Z:plotPos.y];
    impPos.y = [colonyMap worldHeightX:plotPos.x Z:plotPos.y];
    impPos.y += 0.4;
    impPos.x -= 0.3 + 0.05 * plotPos.x;
    impPos.z -= 0.75;
    
    textImp.rotation.x = sceneUtils.avatar.headAtlas;
    [[[textImp material] phongAmbientReflectivity] setVector:sceneUtils.color_red];
    
    [[textImp translation] setVector: impPos];
    return textImp;
}

// add a productivity probability (0 = no production)
// the distance from the actual housetype to the ideal hight is calculated
- (void) calcPlotProductivityAt: (YAVector2i*) plotPos
{
    float height = [colonyMap heightX:plotPos.x Z:plotPos.y];
    house_type house = [colonyMap plotHouseAtX:plotPos.x Z:plotPos.y];

    float probability = 0;

    // map height to texture regions
    int region = 0; // food
    if(height > 0.14)
        region = 1; // energy
    if(height > 0.21)
        region = 2; // smithore
    
    if(house == HOUSE_FARM) {
        if(region == 0)
            probability = 0.5;
        else if(region == 1)
            probability = 0.25;
        else
            probability = 0.125;
    } else if(house == HOUSE_ENERGY) {
        if(region == 1)
            probability = 0.5;
        else
            probability = 0.25;
    } else if(house == HOUSE_SMITHORE) {
        if(region == 2)
            probability = 0.5;
        else if (region == 1)
            probability = 0.25;
        else
            probability = 0.125;
    } else if(house == HOUSE_CRYSTALYTE) {
        probability = [colonyMap plotCrystaliteX:plotPos.x Z:plotPos.y] * 0.5;
    } else {
        probability = 0;
    }

    [colonyMap setProductivityProbability:plotPos Probability:probability];
}

- (YAImpersonator*) createTitle
{
    int round = gameContext.round == 0 ? 1 : gameContext.round; // 0 if uninitialized
    NSString* developmentText = [NSString stringWithFormat:@"%@ %d", [YALog decode:@"production"], round];
    YAImpersonator* imp = [sceneUtils genTextBlocked:developmentText];
    [[[imp material] phongAmbientReflectivity] setVector:sceneUtils.color_yellow];
    [imp resize:0.20];
    [[imp translation] setVector:[[YAVector3f alloc] initVals:-0.8 :0.9 :5]];
    [[imp material] setEta:0.5];
    [sceneUtils alignToCam:imp];
    return imp;
}

-(void) setupGlobals: (NSDictionary*) info
{
    impCollector = [info objectForKey:@"IMPCOLLECTOR"];
    gameContext = [info objectForKey:@"GAMECONTEXT"];
    sceneUtils = [info objectForKey:@"SCENEUTILS"];
    world = [info objectForKey:@"WORLD"];
    colonyMap = [info objectForKey:@"COLONYMAP"];
    soundCollector = [info objectForKey:@"SOUNDCOLLECTOR"];
    eventChain = [info objectForKey:@"EVENTCHAIN"];
    store = [info objectForKey:@"STORE"];
}


- (void) waitForPlayers
{
    YAImpersonator* infoTextImp = [sceneUtils genTextBlocked:[YALog decode:@"GoOn"]];
    [[[infoTextImp material] phongAmbientReflectivity] setVector:sceneUtils.color_red];
    [infoTextImp resize:0.15];
    [[infoTextImp translation] setVector:[[YAVector3f alloc] initVals:-1.4 :-1.0 :5]];
    [[infoTextImp material] setEta:0.5];
    [sceneUtils alignToCam:infoTextImp];
    
    if(gameContext.playerNumber == 0) {
        [chronograph wait:1.5];
        [sceneUtils removeImp:infoTextImp atTime:0];
        return;
    }

    __block int pA = 0;
    __block int pB = 0;
    __block int pC = 0;
    __block int pD = 0;
    
    YABlockAnimator* waitForPlayers = [world createBlockAnimator];
    __weak YABlockAnimator* waitForPlayersW = waitForPlayers;
    
    [waitForPlayers addListener:^(float sp, NSNumber *event, int message) {
        const int evInt = event.intValue;
        
        int player = -1;
        
        if(evInt == MOUSE_DOWN) {
            for(int i = 0; i < gameContext.playerNumber; i++) {
                if([gameContext deviceIdforPlayer:i]  == 1000)
                    player = i;
            }
        } else if (evInt == GAMEPAD_BUTTON_OK) {
            const int device =(message >> 16);
            for(int i = 0; i < gameContext.playerNumber; i++) {
                if([gameContext deviceIdforPlayer:i]  == device)
                    player = i;
            }
        }
        
        if(player == 0)
            pA =1;
        else if(player == 1)
            pB = 1;
        else if(player == 2)
            pC = 1;
        else if(player == 3)
            pD = 1;
    
        if(pA + pB + pC + pD >= gameContext.playerNumber)
            waitForPlayersW.deleteme = YES;
    }];
    
    
    while(pA + pB + pC + pD < gameContext.playerNumber) {
        [chronograph wait:0.25];
    }
    
    [sceneUtils removeImp:infoTextImp atTime:0];
}

@end
