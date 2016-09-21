//
//  YASocketEvents.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 21.01.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import "YALog.h"
#import "YABlockAnimator.h"
#import "YARenderLoop.h"
#import "YAMaterial.h"
#import "YASceneUtils.h"
#import "YAAlienRace.h"
#import "YAGameContext.h"
#import "YAProbability.h"
#import "YAStore.h"
#import "YAVector3f.h"
#import "YAVector2i.h"
#import "YAImpersonator.h"
#import "YAImpCollector.h"
#import "YAEventChain.h"
#import "YAColonyMap.h"
#import "YASocketEvents.h"

@implementation YASocketEvents

- (ListenerEvent) setupFab
{
    ListenerEvent listener = ^(NSDictionary *info) {
        // NSLog(@"Setup Fabric Event");
        YAColonyMap* colMap = [info objectForKey:@"COLONYMAP"];
        YAImpCollector* ic = [info objectForKey:@"IMPCOLLECTOR"];
        YAStore* store = [info objectForKey:@"STORE"];
        YAGameContext* gameContext = [info objectForKey:@"GAMECONTEXT"];
        YASceneUtils* sceneUtils = [info objectForKey:@"SCENEUTILS"];
        YARenderLoop* world = [info objectForKey:@"WORLD"];
        
        YAImpersonator* podImp = ic.podImp;
        YAVector2i* claimId = [colMap getClaimIdAt:podImp.translation];
        int lastPurchase = store.lastPurchase;
        int comission = store.comission;

        if(store && lastPurchase != HOUSE_NONE) {
           [colMap buildFab:lastPurchase X:claimId.x Z:claimId.y Pod:podImp];
            store.lastPurchase = HOUSE_NONE;
        } else if(comission == COMISSION_LAND){
            
            store.comission = COMISSION_NONE;
            
            // Sell and destroy Fab
            float distance = [claimId distanceTo:[[YAVector2i alloc] initVals:3 :3]];
            float newPrice = (5 - distance) * 150 + [YAProbability random] * 50;
            
            int activePlayer = gameContext.activePlayer;
            if(activePlayer != -1) {
                [colMap destroyPlotAtX:claimId.x Z:claimId.y];
                YAAlienRace* player = [gameContext playerDataForId:activePlayer];
                player.money += newPrice;
            }
        } else if(comission == COMISSION_ASSAY){
            store.comission = COMISSION_NONE;
            float crystaliteConcentration = [colMap plotCrystaliteX:claimId.x Z:claimId.y];
            
            NSArray* elements = [NSArray arrayWithObjects:
                                 [NSMutableArray arrayWithObjects:[YALog decode:@"noCrystalite"], @1.0f, nil],
                                 [NSMutableArray arrayWithObjects:[YALog decode:@"lowCrystalite"], @1.0f, nil],
                                 [NSMutableArray arrayWithObjects:[YALog decode:@"mediumCrystalite"], @1.0f, nil],
                                 [NSMutableArray arrayWithObjects:[YALog decode:@"highCrystalite"], @1.0f, nil],
                                 nil];
            
            NSString* crystaliteScore = [YAProbability sampleSelect:elements Sample:crystaliteConcentration];
            
            __block YAImpersonator* infoTextImp = [sceneUtils genText:crystaliteScore];
            [[[infoTextImp material] phongAmbientReflectivity] setVector:sceneUtils.color_red];
            [infoTextImp resize:0.15];
            [[infoTextImp translation] setVector:[[YAVector3f alloc] initVals:-1.2 :-1.0 :5]];
            [[infoTextImp material] setEta:0.5];
            [sceneUtils alignToCam:infoTextImp];

            YABlockAnimator* anim = [world createBlockAnimator];
            __weak YABlockAnimator* animW = anim;
            anim.once = YES;
            anim.interval = 2.0f;
            anim.asyncProcessing = NO;
            [anim addListener:^(float sp, NSNumber *event, int message) {
                [[infoTextImp translation] setVector:[[YAVector3f alloc] initVals:-1.2 :-1.0 :5]];
                [sceneUtils alignToCam:infoTextImp];
            
                if(animW.deleteme) {
                    [sceneUtils removeImp:infoTextImp atTime:0];
                }
            }];
        }
    };
    
    return listener;
}


- (ListenerEvent) plotAssayEvent
{
    ListenerEvent listener = ^(NSDictionary *info) {
        // NSLog(@"Get Plot Assay Event");
        
        YAStore* store = [info objectForKey:@"STORE"];
        YAColonyMap* colMap = [info objectForKey:@"COLONYMAP"];
        YAImpCollector* ic = [info objectForKey:@"IMPCOLLECTOR"];
        YASceneUtils* sceneUtils = [info objectForKey:@"SCENEUTILS"];
        YARenderLoop* world = [info objectForKey:@"WORLD"];

        YAImpersonator* podImp = ic.podImp;
        int comission = store.comission;
        
        if(comission == COMISSION_ASSAY){
            store.comission = COMISSION_NONE;
            YAVector2i* plotPos = [colMap getClaimIdAt:podImp.translation];

            
            float crystaliteConcentration = [colMap plotCrystaliteX:plotPos.x Z:plotPos.y];
            
            NSArray* elements = [NSArray arrayWithObjects:
                                 [NSMutableArray arrayWithObjects:[YALog decode:@"noCrystalite"], @1.0f, nil],
                                 [NSMutableArray arrayWithObjects:[YALog decode:@"lowCrystalite"], @1.0f, nil],
                                 [NSMutableArray arrayWithObjects:[YALog decode:@"mediumCrystalite"], @1.0f, nil],
                                 [NSMutableArray arrayWithObjects:[YALog decode:@"highCrystalite"], @1.0f, nil],
                                 nil];
            
            NSString* crystaliteScore = [YAProbability sampleSelect:elements Sample:crystaliteConcentration];
            
            __block YAImpersonator* infoTextImp = [sceneUtils genText:crystaliteScore];
            [[[infoTextImp material] phongAmbientReflectivity] setVector:sceneUtils.color_red];
            [infoTextImp resize:0.15];
            [[infoTextImp translation] setVector:[[YAVector3f alloc] initVals:-1.2 :-1.0 :5]];
            [[infoTextImp material] setEta:0.5];
            [sceneUtils alignToCam:infoTextImp];
            
            YABlockAnimator* anim = [world createBlockAnimator];
            __weak YABlockAnimator* animW = anim;
            anim.once = YES;
            anim.interval = 2.0f;
            anim.asyncProcessing = NO;
            [anim addListener:^(float sp, NSNumber *event, int message) {
                [[infoTextImp translation] setVector:[[YAVector3f alloc] initVals:-1.2 :-1.0 :5]];
                [sceneUtils alignToCam:infoTextImp];
                
                if(animW.deleteme) {
                    [sceneUtils removeImp:infoTextImp atTime:0];
                }
            }];
        }
        
    };

    return listener;
}


@end
