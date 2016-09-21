//
//  YAFortune.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 04.03.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import "YALog.h"
#import "YASoundCollector.h"
#import "YAQuaternion.h"
#import "YAKinematic.h"
#import "YAChronograph.h"
#import "YAStore.h"
#import "YAGameContext.h"
#import "YAVector2i.h"
#import "YAColonyMap.h"
#import "YARenderLoop.h"
#import "YABlockAnimator.h"
#import "YAImpCollector.h"
#import "YAProbability.h"
#import "YAAlienRace.h"
#import "YAVector3f.h"
#import "YAMaterial.h"
#import "YAImpersonator.h"
#import "YASceneUtils.h"
#import "YAFortune.h"

@implementation YAFortune {
    NSArray* individualFortunes;
    NSArray* globalFortunes;
}

- (id) init
{
    self = [super init];
    
    if(self) {
        individualFortunes = [[NSArray alloc] initWithObjects:
                              @"INFLUENCE_PACKAGE",
                              @"INFLUENCE_TRAVELER",
                              @"INFLUENCE_BUILD",
                              @"INFLUENCE_DROMEDARDANCE",
                              @"INFLUENCE_FOODPLOTS",
                              @"INFLUENCE_WARTWORM",
                              @"INFLUENCE_MUSEUM",
                              @"INFLUENCE_EELEATING",
                              @"INFLUENCE_CHARITY",
                              @"INFLUENCE_INVESTMENT",
                              @"INFLUENCE_HERITAGE",
                              @"INFLUENCE_DEADMOOSE",
                              @"INFLUENCE_DEVELOPMENT",
                              @"INFLUENCE_ELVES",
                              @"INFLUENCE_DROMEDARBOLT",
                              @"INFLUENCE_DROMEDARUSED",
                              @"INFLUENCE_DROMEDARDIRTY",
                              @"INFLUENCE_ZOMBIE",
                              @"INFLUENCE_BUGS",
                              @"INFLUENCE_BETTING",
                              @"INFLUENCE_LIZARD",
                              @"INFLUENCE_LOSTPLOT",
                              nil];
        
        globalFortunes = [[NSArray alloc] initWithObjects:
                          @"INFLUENCE_STORM",
                          @"INFLUECE_METEOR",
                          @"INFLUENCE_STORE",
                          @"INFLUENCE_QUAKE",
                          @"INFLUENCE_RADIATION",
                          @"INFLUENCE_PIRATE",
                          @"INFLUENCE_SUNSPOT",
                          @"INFLUENCE_PEST",
                          nil];
    }
    
    return self;
}

- (float) fortuneFor: (int) playerId
{
    NSAssert(_sceneUtils,@"Scene Utils not available");
    
    const int gameRound = _gameContext.round;
    int baseValue = 0;
    
    if(gameRound <= 3)
        baseValue = 25;
    else if (gameRound <= 7)
        baseValue = 50;
    else if (gameRound <= 11)
        baseValue = 75;
    else
        baseValue = 100;
    
    NSString* event = (NSString*)[YAProbability randomSelectArray:individualFortunes];

    YAAlienRace* activePlayer = nil;
    for(YAAlienRace* player in _players) {
        if(player.playerId == playerId)
            activePlayer = player;
    }
    
    int replaceValue = -1000;

    if([event isEqualToString:@"INFLUENCE_PACKAGE"]) {
        activePlayer.foodUnits += 3;
        activePlayer.energyUnits += 2;
    } else if([event isEqualToString:@"INFLUENCE_TRAVELER"]) {
        activePlayer.smithoreUnits += 2;
    } else if([event isEqualToString:@"INFLUENCE_BUILD"]) {
        replaceValue = 2 * baseValue;
        activePlayer.money += replaceValue;
    } else if([event isEqualToString:@"INFLUENCE_DROMEDARDANCE"]) {
        replaceValue = 4 * baseValue;
        activePlayer.money += replaceValue;
    } else if([event isEqualToString:@"INFLUENCE_FOODPLOTS"]) {
        NSArray* playerPlots = [_colonyMap getAllPlots: playerId];
        int farms = 0;
        for(YAVector2i* plot in playerPlots)
            if([_colonyMap plotHouseAtX:plot.x Z:plot.y] == HOUSE_FARM)
                farms++;
        replaceValue = 2 * baseValue * farms;
        activePlayer.money += replaceValue;
    } else if([event isEqualToString:@"INFLUENCE_WARTWORM"]) {
        replaceValue = 4 * baseValue;
        activePlayer.money += replaceValue;
    } else if([event isEqualToString:@"INFLUENCE_MUSEUM"]) {
        replaceValue = 8 * baseValue;
        activePlayer.money += replaceValue;
    } else if([event isEqualToString:@"INFLUENCE_EELEATING"]) {
        replaceValue = 2 * baseValue;
        activePlayer.money += replaceValue;
    } else if([event isEqualToString:@"INFLUENCE_CHARITY"]) {
        replaceValue = 3 * baseValue;
        activePlayer.money += replaceValue;
    } else if([event isEqualToString:@"INFLUENCE_INVESTMENT"]) {
        replaceValue = 6 * baseValue;
        activePlayer.money += replaceValue;
    } else if([event isEqualToString:@"INFLUENCE_HERITAGE"]) {
        replaceValue = 4 * baseValue;
        activePlayer.money += replaceValue;
    } else if([event isEqualToString:@"INFLUENCE_DEADMOOSE"]) {
        replaceValue = 2 * baseValue;
        activePlayer.money += replaceValue;
    } else if([event isEqualToString:@"INFLUENCE_DEVELOPMENT"]) {
        YAVector2i* plot = [_colonyMap randomVacantPlot];
        [_colonyMap setClaim:playerId X:plot.x Z:plot.y At:0];
    } else if([event isEqualToString:@"INFLUENCE_ELVES"]) {
        activePlayer.foodUnits /=2;
    } else if([event isEqualToString:@"INFLUENCE_DROMEDARBOLT"]) {
        replaceValue = 3 * baseValue;
        activePlayer.money -= replaceValue;
    } else if([event isEqualToString:@"INFLUENCE_DROMEDARUSED"]) {
        NSArray* playerPlots = [_colonyMap getAllPlots: playerId];
        int bergwerk  = 0;
        for(YAVector2i* plot in playerPlots)
            if([_colonyMap plotHouseAtX:plot.x Z:plot.y] == HOUSE_SMITHORE || [_colonyMap plotHouseAtX:plot.x Z:plot.y] == HOUSE_CRYSTALYTE)
                bergwerk++;
        replaceValue = 2 * baseValue * bergwerk;
        activePlayer.money -= replaceValue;
    } else if([event isEqualToString:@"INFLUENCE_DROMEDARDIRTY"]) {
        NSArray* playerPlots = [_colonyMap getAllPlots: playerId];
        int energy = 0;
        for(YAVector2i* plot in playerPlots)
            if([_colonyMap plotHouseAtX:plot.x Z:plot.y] == HOUSE_ENERGY)
                energy++;
        replaceValue = 1 * baseValue * energy;
        activePlayer.money -= replaceValue;
    } else if([event isEqualToString:@"INFLUENCE_ZOMBIE"]) {
        replaceValue = 6 * baseValue;
        activePlayer.money -= replaceValue;
    } else if([event isEqualToString:@"INFLUENCE_BUGS"]) {
        replaceValue = 4 * baseValue;
        activePlayer.money -= replaceValue;
    } else if([event isEqualToString:@"INFLUENCE_BETTING"]) {
        replaceValue = 4 * baseValue;
        activePlayer.money -= replaceValue;
    } else if([event isEqualToString:@"INFLUENCE_LIZARD"]) {
        replaceValue = 4 * baseValue;
        activePlayer.money -= replaceValue;
    }  else if([event isEqualToString:@"INFLUENCE_LOSTPLOT"]) {
        NSArray* playerPlots = [_colonyMap getAllPlots: playerId];
        __block YAVector2i* destroyPlot = [YAProbability randomSelectArray:playerPlots];
        YABlockAnimator* anim = [_world createBlockAnimator];
        anim.oneExecution = YES;
        [anim addListener:^(float sp, NSNumber *event, int message) {
            [_colonyMap destroyPlotAtX:destroyPlot.x Z:destroyPlot.y];
        }];
    }
    
    NSString* eventString = [YALog decode:event];
    if(replaceValue != -1000)
        eventString = [eventString stringByReplacingOccurrencesOfString:@"_" withString:[NSString stringWithFormat:@"%d", replaceValue]];

    YAImpersonator* messageTextImp = [_sceneUtils genText:eventString];
    
    [[[messageTextImp material] phongAmbientReflectivity] setVector:_sceneUtils.color_yellow];
    [messageTextImp resize:0.15];
    [[messageTextImp translation] setVector:[[YAVector3f alloc] initVals:2.01 :-1.0 :5]];
    [[messageTextImp material] setEta:0.5];
    const float result = [_sceneUtils tickerText:messageTextImp atTime:0 withLength:(int)eventString.length];
    
    [_sceneUtils removeImp:messageTextImp atTime:result];
    return result;
}

- (float) gambleFor: (int) playerId usedTime: (float) timeInPercent At: (float) myTime;
{
    NSAssert(_sceneUtils,@"Scene Utils not available");
   
    YAAlienRace* activePlayer = nil;
    for(YAAlienRace* player in _players) {
        if(player.playerId == playerId)
            activePlayer = player;
    }

    
    float gambleBase = 0;
    
    if(_gameContext.round <= 3)
        gambleBase = 50;
    else if(_gameContext.round <= 7)
        gambleBase = 100;
    else if(_gameContext.round <= 11)
        gambleBase = 150;
    else
        gambleBase = 200;
    
    int win = (gambleBase * (1 -  fminf(timeInPercent, 0.9f))) * [YAProbability random];
    NSString* text = [YALog decode:@"gambleWon"];
    text = [text stringByReplacingOccurrencesOfString:@"_" withString:[NSString stringWithFormat:@"%d", win]];

    YAImpersonator* infoTextImp = [_sceneUtils genText:text];
    [[[infoTextImp material] phongAmbientReflectivity] setVector:_sceneUtils.color_red];
    [infoTextImp setVisible: NO];
    [infoTextImp resize:0.15];
    [[infoTextImp translation] setVector:[[YAVector3f alloc] initVals:-0.1 * text.length * 0.5 :-1.0 :5]];
    [[infoTextImp material] setEta:0.5];
    [_sceneUtils alignToCam:infoTextImp];

    [_sceneUtils showImp:infoTextImp atTime: myTime];
    myTime += 1.5;
    [_sceneUtils removeImp:infoTextImp atTime:myTime];
    
    return myTime;
}


- (float) globalFortune
{
    
    bool dice = [YAProbability dice:0.5];
    if(!dice)
        return 0;
    
    NSString* event = (NSString*)[YAProbability randomSelectArray:globalFortunes];
    
    NSString* eventTitle =       [YALog decode:event];
    NSString* eventDescription = [YALog decode:[NSString stringWithFormat:@"%@%@", event, @"_DESCRIPTION"]];

    float resultTime = 0;
    
    
    if([event isEqualToString:@"INFLUENCE_STORM"]) {
        NSArray* gcImps = [self createGlobalEventText:eventTitle Description:eventDescription];
        
        __block int randomRow = [YAProbability selectOneOutOf:7];
        
        
        // modify production
        for(int x = 0; x <= 6; x++) {
            for(int z = 0; z <=6; z++) {
                house_type house = [_colonyMap plotHouseAtX:x Z:z];
                
                if(house == HOUSE_ENERGY) {
                    if(z == randomRow)
                        [_colonyMap addProduction:[[YAVector2i alloc] initVals:x :z] Amount:-2];
                    else
                        [_colonyMap addProduction:[[YAVector2i alloc] initVals:x :z] Amount:-1];
                } else if (house == HOUSE_FARM) {
                    if(z == randomRow)
                        [_colonyMap addProduction:[[YAVector2i alloc] initVals:x :z] Amount:+4];
                    else
                        [_colonyMap addProduction:[[YAVector2i alloc] initVals:x :z] Amount:+2];
                }
                
            }
        }
        
        __block float maxHeight = 0;
        
        for(int i = 0; i <= 6 ; i++) {
            const float h = [_colonyMap worldHeightX:i Z:randomRow];
            if (h > maxHeight)
                maxHeight = h;
        }
        
        maxHeight += 0.5;

        
        __block YAVector3f* leftRowPos = [_colonyMap calcWorldPosX:0 Z:randomRow];
       
        NSArray* cloudImps = [NSArray arrayWithObjects:
                              [NSMutableArray arrayWithObjects:_impCollector.cloudNormalImp, @80.0f, nil],
                              [NSMutableArray arrayWithObjects:_impCollector.cloudLightningImp, @20.0f, nil],
                              nil];
        
        __block YAImpersonator* cloudImp;
        __block int frameCounter = 0;

        // create the storm animation
        YABlockAnimator* anim = [_world createBlockAnimator];
        __weak YABlockAnimator* animW = anim;

        [_colonyMap enableLaserPointer:YES];
        
        
        anim.asyncProcessing = 0;
        anim.once = YES;
        anim.onceReset = NO;
        anim.interval = 10;
        anim.progress = cyclic;
        [anim addListener:^(float sp, NSNumber *event, int message) {
            _impCollector.cloudNormalImp.visible = NO;
            _impCollector.cloudLightningImp.visible = NO;
            
            if(!animW.deleteme) {
                
                int line = roundf(0.00001 + sp * 7.0f - 0.5f);
                
                [_colonyMap laserPointerAtPlot:line :randomRow];
                
                if(frameCounter++ % 5 == 0)
                    cloudImp =  [YAProbability randomSelect:cloudImps];
                
                cloudImp.translation.y = maxHeight + 1.5;
                cloudImp.translation.x = (sp * 9) - 9 * 0.5;
                cloudImp.translation.z = leftRowPos.z;
                cloudImp.visible = YES;
                
            } else {
                [_colonyMap enableLaserPointer:NO];
                
                for(YAImpersonator* imp in gcImps) {
                    [_world removeImpersonator:imp.identifier];
                }
                
            }
        }];
        
        resultTime = 10;
        
    } else if([event isEqualToString:@"INFLUECE_METEOR"]) {

        int jingleId = [_soundCollector getJingleId:@"melodyE"];
        [_soundCollector playJingle: jingleId];
        
        NSArray* gcImps =  [self createGlobalEventText:eventTitle Description:eventDescription];
        
        
        const int luckyOne = [YAProbability selectOneOutOf:4];
        
        NSArray* plots = [_colonyMap getAllPlots:luckyOne];
        
        YAVector2i* plotPos = [YAProbability randomSelectArray:plots];
        YAVector3f* plotCoords = [_colonyMap calcWorldPosX:plotPos.x Z:plotPos.y];
        plotCoords.y = [_colonyMap worldHeightX:plotPos.x Z:plotPos.y];

        
        [_colonyMap laserPointerAtPlot:plotPos.x :plotPos.y];
        [_colonyMap enableLaserPointer:YES];
        
        YAImpersonator* meteoritImp = _impCollector.meteoriteImp;
        YAImpersonator* fireImp = _impCollector.fireImp;
        
        [[meteoritImp translation] setVector:plotCoords];
        meteoritImp.rotation.x = 90;
        meteoritImp.rotation.z = 45;

        meteoritImp.translation.y += 3;
        meteoritImp.visible = YES;

        [[fireImp translation] setVector:plotCoords];
        [fireImp setVisible:NO];

        
        __block YABasicAnimator* metRotX = [_world createBasicAnimator];
        metRotX.interval = 5;
        [metRotX addListener:[meteoritImp rotation]  factor:360];
        
        YABlockAnimator* anim = [_world createBlockAnimator];
        __weak YABlockAnimator* animW = anim;
        
        anim.asyncProcessing = NO;
        anim.interval = 5;
        anim.once = YES;
        anim.onceReset = NO;

        [anim addListener:^(float sp, NSNumber *event, int message) {
            
            const float distMultiplier = 5;
            meteoritImp.translation.y = plotCoords.y + 0.4 + distMultiplier - sp * distMultiplier;
            [meteoritImp resize: 0.65 + 1.35 - sp * 1.35];

            if(animW.deleteme) {
                [_colonyMap enableLaserPointer:NO];
                meteoritImp.visible = NO;
                metRotX.deleteme = YES;
                fireImp.visible = YES;
            }
        }];
        
     
        anim = [_world createBlockAnimator]; // destroy Plot
        anim.oneExecution = YES;
        anim.delay = 10;
        [anim addListener:^(float sp, NSNumber *event, int message) {

            [_soundCollector stopAllSounds];
            
            fireImp.visible = NO;
            [_colonyMap destroyPlotAtX:plotPos.x Z:plotPos.y];
            [_colonyMap highCrystitePlotAtX:plotPos.x Z:plotPos.y];

            for(YAImpersonator* imp in gcImps) {
                [_world removeImpersonator:imp.identifier];
            }
            
        }];
        
        resultTime = 10;
    } else if([event isEqualToString:@"INFLUENCE_STORE"]) {
        NSArray* gcImps =  [self createGlobalEventText:eventTitle Description:eventDescription];
        
        YAImpersonator* fireImp = _impCollector.fireImp;
        YAVector2i* plotPos = [[YAVector2i alloc] initVals:3 :3];
        YAVector3f* plotCoords = [_colonyMap calcWorldPosX:plotPos.x Z:plotPos.y];
        plotCoords.y = [_colonyMap worldHeightX:plotPos.x Z:plotPos.y];

        [[fireImp translation] setVector:plotCoords];
        [fireImp setVisible:YES];
        
        _store.foodStock = 0;
        _store.energyStock = 0;
        _store.smithoreStock = 0;
        _store.crystaliteStock = 0;
        
        YABlockAnimator* anim = [_world createBlockAnimator];
        anim.oneExecution = YES;
        anim.delay = 10;
        [anim addListener:^(float sp, NSNumber *event, int message) {
            for(YAImpersonator* imp in gcImps) {
                fireImp.visible = NO;
                [_world removeImpersonator:imp.identifier];
            }
        }];
    
   
        resultTime = 10;
    } else if([event isEqualToString:@"INFLUENCE_QUAKE"]) {
                    
        int jingleId = [_soundCollector getJingleId:@"melodyH"];
        [_soundCollector playJingle:jingleId];
        
        NSArray* gcImps =  [self createGlobalEventText:eventTitle Description:eventDescription];

        __block NSMutableArray* plotsHouses = [[NSMutableArray alloc] init];
        
        for(int x = 0; x <= 6; x++) {
            for(int z = 0; z <= 6; z++) {
                
                if([_colonyMap plotHouseAtX:x Z:z] == HOUSE_CRYSTALYTE || [_colonyMap plotHouseAtX:x Z:z] == HOUSE_SMITHORE) {
                    [_colonyMap addProduction:[[YAVector2i alloc] initVals:x :z] Amount:-4];
                    [plotsHouses addObject:[_colonyMap getHouseAtX: x Z:z]];
                }
            }
        }
        
        __block YAChronograph* shakeTime = [[YAChronograph alloc] init];
        [shakeTime start];
        
        __block YAVector2i* randomPlot = [_colonyMap randomVacantPlot];
        [_colonyMap enableLaserPointer:YES];
        [_colonyMap laserPointerAtPlot:randomPlot.x :randomPlot.y];
        
        YABlockAnimator* shake = [_world createBlockAnimator];
        YABlockAnimator* shakeW = shake;
        
        shake.interval = 0.5f;
        shake.progress = harmonic;
        shake.asyncProcessing = NO;
        [shake addListener:^(float sp, NSNumber *event, int message) {

            const float activity =  [YAProbability sinPowProb:((11 - [shakeTime getTime]) / 11)];
            
            const float ssp = copysignf([YAProbability sinPowProb:fabsf(sp * 2)],sp);
            
            for(YAImpersonator* house in plotsHouses) {
                house.rotation.z = ssp * activity * 10;
            }
            
            if(shakeW.deleteme)
                for(YAImpersonator* house in plotsHouses)
                    house.rotation.z = 0;
        }];
        
        
        YABlockAnimator* anim = [_world createBlockAnimator];
        anim.oneExecution = YES;
        anim.delay = 2.5;
        [anim addListener:^(float sp, NSNumber *event, int message) {
            if(randomPlot != nil)
                [_colonyMap createMountainX:randomPlot.x Z:randomPlot.y];
        }];
        
        anim = [_world createBlockAnimator];
        anim.oneExecution = YES;
        anim.delay = 10;
        [anim addListener:^(float sp, NSNumber *event, int message) {
            [_soundCollector stopAllSounds];

            for(YAImpersonator* imp in gcImps) {
                [_world removeImpersonator:imp.identifier];
            }
            
            shake.deleteme = YES;
            [_colonyMap enableLaserPointer:NO];

        }];
        
        resultTime = 10;
        
    } else if([event isEqualToString:@"INFLUENCE_RADIATION"]) {
        NSArray* gcImps =  [self createGlobalEventText:eventTitle Description:eventDescription];

        const int luckyOne = [YAProbability selectOneOutOf:4];
        
        NSArray* plots = [_colonyMap getAllPlots:luckyOne];
        YAVector2i* plotPos = [YAProbability randomSelectArray:plots];
        YAVector3f* plotCoords = [_colonyMap calcWorldPosX:plotPos.x Z:plotPos.y];
        plotCoords.y = [_colonyMap worldHeightX:plotPos.x Z:plotPos.y];
        [_colonyMap laserPointerAtPlot:plotPos.x :plotPos.y];
        [_colonyMap enableLaserPointer:YES];
        [_colonyMap setProductivityProbability:plotPos Probability:0.0f];
        [_colonyMap  changeProduction:plotPos Amount:-8];
        
        __block YAImpersonator* houseImp = [_colonyMap getHouseAtX:plotPos.x Z:plotPos.y];
        
        NSArray* originalColors = [NSArray arrayWithObjects:[[YAVector3f alloc] initCopy: houseImp.material.phongAmbientReflectivity],
                                   [[YAVector3f alloc] initCopy: houseImp.material.phongDiffuseReflectivity],
                                   [[YAVector3f alloc] initCopy: houseImp.material.phongSpecularReflectivity],
                                   nil ];

        
        YABlockAnimator* glow = [_world createBlockAnimator];
        __weak YABlockAnimator* glowW = glow;
        glow.asyncProcessing = NO;
        glow.interval = 2.5f;
        glow.progress = harmonic;
        [glow addListener:^(float sp, NSNumber *event, int message) {
            float ssp = fabs(sp) + 0.5;
            ssp = pow(ssp,1.0/0.5);
            
            [[[houseImp material] phongAmbientReflectivity] setValues:ssp :0 :0];
            [[[houseImp material] phongDiffuseReflectivity] setValues:0 :0 :ssp];
            [[[houseImp material] phongSpecularReflectivity] setValues:ssp :0 :ssp];
            
            if(glowW.deleteme) {
                [[[houseImp material] phongAmbientReflectivity] setVector:[originalColors objectAtIndex:0]];
                [[[houseImp material] phongDiffuseReflectivity] setVector:[originalColors objectAtIndex:1]];
                [[[houseImp material] phongDiffuseReflectivity] setVector:[originalColors objectAtIndex:2]];
            }
            
        }];
        
        
        
        YABlockAnimator* anim = [_world createBlockAnimator];
        anim.oneExecution = YES;
        anim.delay = 10;
        [anim addListener:^(float sp, NSNumber *event, int message) {
            for(YAImpersonator* imp in gcImps) {
                [_world removeImpersonator:imp.identifier];
            }
            [_colonyMap enableLaserPointer:NO];
            glow.deleteme = YES;

        }];
        
        resultTime = 10;
        
    } else if([event isEqualToString:@"INFLUENCE_PIRATE"]) {
        NSArray* gcImps =  [self createGlobalEventText:eventTitle Description:eventDescription];
        
        int impId = [_world createImpersonatorWithShapeShifter: @"Thargoid"];
        __block YAImpersonator* imp = [_world getImpersonator:impId];
        [[[imp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
        [[[imp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
        [[[imp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
        [[imp material] setPhongShininess: 20];

        imp.rotation.x = -90.0f;
        imp.translation.y = 2;
        imp.translation.x = 100; // out of sight
        [imp resize:0.5];
        
        gcImps = [gcImps arrayByAddingObject:imp];
        
        __block YAKinematic* kinematic = [[YAKinematic alloc] initWithJoints:[imp joints]];

        YABlockAnimator* thargoidRotate = [_world createBlockAnimator];
        thargoidRotate.asyncProcessing = NO;
        [thargoidRotate addListener:^(float sp, NSNumber *event, int message) {
            [kinematic setJointOrientation:@"Head" quaternion:[[YAQuaternion alloc] initEulerDeg:0 pitch:0  roll:  sp * 360 ]];
        }];
        
        int jingleId = [_soundCollector getJingleId:@"BlaueDonau"];
        [_soundCollector playJingle:jingleId];

        YABlockAnimator* thargoidEnter = [_world createBlockAnimator];
        thargoidEnter.asyncProcessing = NO;
        thargoidEnter.interval = 2;
        thargoidEnter.once = YES;
        thargoidEnter.onceReset = NO;
        thargoidEnter.progress = damp;
        [thargoidEnter addListener:^(float sp, NSNumber *event, int message) {
            const float dist = 10;
            imp.translation.x = dist - (sp * dist);
            const float rot = 45 * (1 - [YAProbability sinPowProb:sp]);
            imp.rotation.z = rot;
        }];
        
        YABlockAnimator* thargoidLeave = [_world createBlockAnimator];
        thargoidLeave.asyncProcessing = NO;
        thargoidLeave.interval = 2;
        thargoidLeave.once = YES;
        thargoidLeave.onceReset = NO;
        thargoidLeave.progress = accelerate;
        thargoidLeave.delay = 5;
        [thargoidLeave addListener:^(float sp, NSNumber *event, int message) {
            const float dist = 15;
            imp.translation.x =  - (sp * dist);
            const float rot = 45 * ([YAProbability sinSqrtProb:sp]);
            imp.rotation.z = rot;
        }];
        
        YABlockAnimator* anim = [_world createBlockAnimator];
        anim.oneExecution = YES;
        anim.delay = 10;
        [anim addListener:^(float sp, NSNumber *event, int message) {
            thargoidRotate.deleteme = YES;
            [_soundCollector stopAllSounds];

            for(YAImpersonator* imp in gcImps) {
                [_world removeImpersonator:imp.identifier];
            }
        }];

        _store.crystaliteStock = 0;
        _store.smithoreStock = 0;
        
        for(int playerId = 0; playerId < 4; playerId++) {
            YAAlienRace* player = [_gameContext playerDataForId:playerId];
            player.smithoreUnits = 0;
            player.crystaliteUnits = 0;
        }

        resultTime = 10;
        
    } else if([event isEqualToString:@"INFLUENCE_SUNSPOT"]) {
        NSArray* gcImps =  [self createGlobalEventText:eventTitle Description:eventDescription];
        
        
        __block YAImpersonator* sunImp = _impCollector.sunImp;
        __block YAVector3f* oldSize = [[YAVector3f alloc] initCopy:sunImp.size];
        __block YAVector3f* oldAmbient = [[YAVector3f alloc] initCopy:sunImp.material.phongAmbientReflectivity];

        [[sunImp translation] setValues:0 :2.5 :0];
        [sunImp setVisible:YES];
        
        YABasicAnimator* sunRot = [_world createBasicAnimator];
        [sunRot addListener:sunImp.rotation factor:360];
        [sunRot setInterval:2.5];
        sunRot.influence = Y_AXE;
        
        YABlockAnimator* sunGrow = [_world createBlockAnimator];
        YABlockAnimator* sunGrowW = sunGrow;
        sunGrow.asyncProcessing = NO;
        sunGrow.interval = 1.5;
        [sunGrow setProgress:harmonic];
        [sunGrow addListener:^(float sp, NSNumber *event, int message) {
            float ssp = powf(sp + 0.5, 1/ 0.5) * 0.5;
            [sunImp resize: 1 + ssp];
            [sunImp.material.phongAmbientReflectivity setValues: 1+ sp + 0.5 :1 + sp + 0.5 :1 + sp + 0.5 ];
            
            if(sunGrowW.deleteme) {
                [sunImp.material.phongAmbientReflectivity setVector:oldAmbient];
                [sunImp.size setVector:oldSize];
            }
        }];
        
        YABlockAnimator* anim = [_world createBlockAnimator];
        anim.oneExecution = YES;
        anim.delay = 10;
        [anim addListener:^(float sp, NSNumber *event, int message) {
            for(YAImpersonator* imp in gcImps) {
                [_world removeImpersonator:imp.identifier];
            }
            
            sunImp.visible = NO;
            sunGrow.deleteme = YES;
        }];

        for(YAVector2i* plot in [_colonyMap getAllProduction]) {
            if([_colonyMap plotHouseAtX:plot.x Z:plot.y] == HOUSE_ENERGY) {
                int productionGain =  3;
                if([_colonyMap plotProduction:plot] + productionGain > 8)
                    productionGain = 8 - [_colonyMap plotProduction:plot];
                [_colonyMap addProduction:plot Amount:productionGain];
            }
        }
        
        resultTime = 10;
        
    } else if([event isEqualToString:@"INFLUENCE_PEST"]) {
        NSArray* gcImps =  [self createGlobalEventText:eventTitle Description:eventDescription];
        
        __block NSMutableArray* plotsHouses = [[NSMutableArray alloc] init];
        
        for(int x = 0; x <= 6; x++) {
            for(int z = 0; z <= 6; z++) {
                
                if([_colonyMap plotHouseAtX:x Z:z] == HOUSE_FARM ) {
                    const float newProb = [_colonyMap productivityProbability:[[YAVector2i alloc] initVals:x :z]] * .5f;
                    [_colonyMap setProductivityProbability:[[YAVector2i alloc] initVals:x :z] Probability:newProb];
                    [plotsHouses addObject:[_colonyMap getHouseAtX: x Z:z]];
                }
            }
        }
        
        __block YAVector3f* oldAmbient = [[YAVector3f alloc] initCopy:[[[plotsHouses objectAtIndex:0] material] phongAmbientReflectivity]];
        
        
        YABlockAnimator* pestFlash = [_world createBlockAnimator];
        YABlockAnimator* pestFlashW = pestFlash;
        pestFlash.asyncProcessing = NO;
        pestFlash.progress = harmonic;
        pestFlash.interval = 0.5;
        [pestFlash addListener:^(float sp, NSNumber *event, int message) {
            float ssp = pow(sp + 0.5, 1 / 0.9);
            for(YAImpersonator* imp in plotsHouses) {
                [[[imp material] phongAmbientReflectivity] setValues:0 :ssp :0];
            }
            
            if(pestFlashW.deleteme) {
                for(YAImpersonator* imp in plotsHouses) {
                    [[[imp material] phongAmbientReflectivity] setVector:oldAmbient];
                }
            }
            
        }];
        
        
        YABlockAnimator* anim = [_world createBlockAnimator];
        anim.oneExecution = YES;
        anim.delay = 10;
        [anim addListener:^(float sp, NSNumber *event, int message) {
            for(YAImpersonator* imp in gcImps) {
                [_world removeImpersonator:imp.identifier];
            }
            pestFlash.deleteme = YES;
        }];
        
        resultTime = 10;
    }

    return resultTime;
}

- (NSArray*) createGlobalEventText: (NSString*) textTitle Description: (NSString*) textDescription
{
    YAImpersonator* impTitle = [_sceneUtils genTextBlocked:textTitle];
    [[[impTitle material] phongAmbientReflectivity] setVector:_sceneUtils.color_yellow];
    [impTitle resize:0.20];
    [[impTitle translation] setVector:[[YAVector3f alloc] initVals:-0.8 :0.9 :5]];
    [[impTitle material] setEta:0.5];
    [_sceneUtils alignToCam:impTitle];

    YAImpersonator* impDescription = [_sceneUtils genTextBlocked:textDescription];
    [[[impDescription material] phongAmbientReflectivity] setVector:_sceneUtils.color_yellow];
    [impDescription resize:0.15];
    [[impDescription translation] setVector:[[YAVector3f alloc] initVals:-0.09 * textDescription.length * 0.5 :-1.0 :5]];
    [[impDescription material] setEta:0.5];
    [_sceneUtils alignToCam:impDescription];
    
    return [NSArray arrayWithObjects:impTitle, impDescription, nil];
}

@end
