//
//  YAPlotAuction.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 06.09.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YAAuction.h"
@class YASceneUtils, YARenderLoop, YAImpersonator, YAColonyMap, YAVector2i, YAGameContext, YABasicAnimator, YABlockAnimator, YADevelopmentAI, YASoundCollector;


@interface YAPlotAuction : YAAuction {
@private
    YAVector2i* freePlot;
    NSMutableArray* gcImps;
    
    YAImpersonator *cursorUpImp, *cursorDownImp;
    
    int price;
    __block int winner;
    
    __block NSMutableArray* playerBids;
    NSMutableArray* playerBidsImps;

    NSArray* playerColorRings;
    __block NSArray* playerColorBalls;

   
    YAImpersonator* actualBidTextImp;
    YABasicAnimator* animBall;
    
    YABlockAnimator *humanAnim, *botAnim;
    
}

@property (weak, readwrite) YASoundCollector* soundCollector;
@property (weak, readwrite) YAGameContext* gameContext;
@property (weak, readwrite) YAColonyMap* colonyMap;
@property (weak, readwrite) YASceneUtils* sceneUtils;
@property (weak, readwrite) YARenderLoop* world;
@property (weak, readwrite) YAImpersonator* terrainImp;
@property (weak, readwrite) YAImpersonator* sunImp;
@property (weak, readwrite) YAImpersonator* sunCoverImp;
@property (weak, readwrite) YAImpersonator* stickSunImp;
@property (weak, readwrite) YAImpersonator* barrackImp;
@property (weak, readwrite) YAImpersonator* planeImp;

@property (weak, readwrite) YAImpersonator* boardImp;
@property (weak, readwrite) YAImpersonator* boardTitleImp;
@property (weak, readwrite) YADevelopmentAI* developmentAI;


@property (assign, readwrite) int auctionNumber;


- (float) auction: (float) myTime;

@end
