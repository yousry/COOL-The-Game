//
//  YAPlotAuction.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 06.09.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YALog.h"
#import "YASoundCollector.h"
#import "YADevelopmentAI.h"
#import "YAChronograph.h"
#import "YAProbability.h"
#import "YAInterpolationAnimator.h"
#import "YAImpersonatorMover.h"
#import "YAVector2i.h"
#import "YAAlienRace.h"
#import "YAGameContext.h"
#import "YAVector3f.h"
#import "YAMaterial.h"
#import "YAImpersonator.h"
#import "YASceneUtils.h"
#import "YARenderLoop.h"
#import "YAVector2i.h"
#import "YAColonyMap.h"
#import "YABlockAnimator.h"
#import "YAPlotAuction.h"


#define BID_LINE_ORIGIN 3.5f
#define PLAYER_IMP_ORIGIN -5.0f

@implementation YAPlotAuction
@synthesize sceneUtils, world, colonyMap, gameContext, terrainImp, auctionNumber;
@synthesize sunImp, sunCoverImp, barrackImp, planeImp;
@synthesize boardImp, boardTitleImp, stickSunImp;


// update line position to the Imp with the highest X position
- (void) bitLine: (float) myTime
{
    const float duration = [gameContext calcAuctionTime];
    YABlockAnimator* anim = [world createBlockAnimator];
    [anim setOnce:true];
    [anim setOnceReset:true];
    [anim setDelay:myTime];
    [anim setInterval:duration];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        
        float maxBitPos = BID_LINE_ORIGIN;
        
        for(int playerId = 0; playerId < 4; playerId ++) {
            YAImpersonator* imp = [[gameContext.playerGameData objectAtIndex:playerId] impersonator];
            const float impXPos = imp.translation.x;
            if(imp.translation.x < maxBitPos)
                maxBitPos = impXPos;
        }
        planeImp.translation.x = maxBitPos;
    }];
}

// update max bid text and players color ball
- (void) calcHighBid: (float) myTime
{
    __block float lastHighestBid = 0;
    const float duration = [gameContext calcAuctionTime];
    
    YABlockAnimator* anim = [world createBlockAnimator];
    [anim setOnce:true];
    [anim setAsyncProcessing:NO];
    [anim setOnceReset:true];
    [anim setInterval:duration];
    [anim setDelay:myTime];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        
        const float maxBid = [[playerBids valueForKeyPath:@"@max.floatValue"] floatValue];
        
        int newWinner = -1;
        for(int i = 0; i < 4; i ++) {
            float playerBid = [[playerBids objectAtIndex:i] floatValue];
            if(playerBid == lastHighestBid && playerBid != 0) {
                [[playerColorBalls objectAtIndex:i] setVisible:true];
                newWinner = i;
            } else {
                [[playerColorBalls objectAtIndex:i] setVisible:false];
            }
        }
        
        if(lastHighestBid == maxBid && newWinner == winner)
            return;
        
        lastHighestBid = maxBid;
        winner = newWinner;
        
        if(maxBid >= price) {
            NSString* newBidText = [NSString stringWithFormat:@"%@%d", [YALog decode:@"highBid"], (int)maxBid];
            [world updateTextIngredient:newBidText Impersomator:actualBidTextImp];
        } else {
            [world updateTextIngredient:[YALog decode:@"noBids"] Impersomator:actualBidTextImp];
        }
        
        for(int i = 0; i < 4; i ++) {
            float playerBid = [[playerBids objectAtIndex:i] floatValue];
            if(playerBid == lastHighestBid && playerBid != 0) {
                [[playerColorBalls objectAtIndex:i] setVisible:true];
                winner = i;
            } else {
                [[playerColorBalls objectAtIndex:i] setVisible:false];
            }
        }
        
    }];
}


// the bot AI
- (void) botsRun: (float) myTime
{
    __block float lastSP = 0;
    const float duration = [gameContext calcAuctionTime];

    float  houseCalculationsMultiplier[4];
    
    for(int i = 0; i <= 3; i++) {
        house_type houseCalculation = [_developmentAI chooseFabX:freePlot.x Z:freePlot.y Player:0];
        
        if(houseCalculation == HOUSE_FARM)
            houseCalculationsMultiplier[i] = 0.4;
        else if(houseCalculation == HOUSE_ENERGY)
            houseCalculationsMultiplier[i] = 0.3;
        else if(houseCalculation == HOUSE_SMITHORE)
            houseCalculationsMultiplier[i] = 0.5;
        else if(houseCalculation == HOUSE_CRYSTALYTE)
            houseCalculationsMultiplier[i] = 0.3 + gameContext.round/40 ;
    }

    __block NSArray* botDecision = [[NSArray alloc] initWithObjects:
                                    [NSNumber numberWithFloat:[[gameContext.playerGameData objectAtIndex:0] money] *
                                     (houseCalculationsMultiplier[0] + ([YAProbability random] - 0.5) * 0.4) ],
                                    [NSNumber numberWithFloat:[[gameContext.playerGameData objectAtIndex:1] money] *
                                     (houseCalculationsMultiplier[1] + ([YAProbability random] - 0.5) * 0.4) ],
                                    [NSNumber numberWithFloat:[[gameContext.playerGameData objectAtIndex:2] money] *
                                     (houseCalculationsMultiplier[2] + ([YAProbability random] - 0.5) * 0.4) ],
                                    [NSNumber numberWithFloat:[[gameContext.playerGameData objectAtIndex:3] money] *
                                     (houseCalculationsMultiplier[3] + ([YAProbability random] - 0.5) * 0.4) ],
                                    nil];
    
    YABlockAnimator* anim = [world createBlockAnimator];
    botAnim = anim;
    [anim setOnce:true];
    [anim setOnceReset:true];
    [anim setInterval:duration];
    [anim setDelay:myTime];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        
        if(lastSP == sp)
            return;
        
        lastSP = sp;
        
        for(int botId = [gameContext playerNumber]; botId < 4; botId++) {
            float botBid = [[playerBids objectAtIndex:botId] floatValue];
            float maxBid = [[playerBids valueForKeyPath:@"@max.floatValue"] floatValue];
            
            NSArray* sortedByMoney = [playerBids sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                int v1 = [(NSNumber*)obj1 floatValue];
                int v2 = [(NSNumber*)obj2 floatValue];
                if (v1 > v2)
                    return NSOrderedAscending;
                else if (v1 < v2)
                    return NSOrderedDescending;
                else
                    return NSOrderedSame;
            }];
            
            float second = [[sortedByMoney objectAtIndex:1] floatValue];
            
            float speed = 0.0;
            
            if(botId == winner && botBid > second + 10 &&  botBid > price)
                speed = 0.5f * 0.1;
            else if ((botBid < maxBid || maxBid < price || botBid == second ) &&
                     [[botDecision objectAtIndex:botId] floatValue] > maxBid &&
                     [[botDecision objectAtIndex:botId] floatValue] > price)
                speed = -0.5 * 0.1;
            
            YAImpersonator* imp = [[gameContext.playerGameData objectAtIndex:botId] impersonator];
            id<YAImpersonatorMover> mover = [[gameContext.playerGameData objectAtIndex:botId] impMover];
            
            if(speed == 0) {
                [mover reset];
                [mover setActive:none];
                continue;
            } else {
                [mover setActive:walk];
            }

            
                float newPos = imp.translation.x + speed;
                [[imp translation] setX: fmin(fmax(newPos, PLAYER_IMP_ORIGIN), PLAYER_IMP_ORIGIN * -1)];
                [[[playerColorRings objectAtIndex:botId] translation] setX: fmin(fmax(newPos, PLAYER_IMP_ORIGIN), PLAYER_IMP_ORIGIN * -1)];
                
                YAImpersonator* impBid = [playerBidsImps objectAtIndex:botId];
                if(newPos <= BID_LINE_ORIGIN) {
                    
                    if(botBid == 0)
                        botBid = price;
                    else
                        botBid -= speed * 20;
                    
                    // overwrite position to max (puffer)
                    if(imp.translation.x < PLAYER_IMP_ORIGIN) {
                        [[imp translation] setX: PLAYER_IMP_ORIGIN];
                        [[[playerColorRings objectAtIndex:botId] translation] setX: PLAYER_IMP_ORIGIN];
                    }
                    
                    [world updateTextIngredient:[NSString stringWithFormat:@"%d", (int)botBid] Impersomator:impBid];
                    [playerBids replaceObjectAtIndex:botId withObject:[NSNumber numberWithFloat:botBid]];
                } else if(botBid != 0) {
                    botBid = 0;
                    [world updateTextIngredient:[NSString stringWithFormat:@"%d", (int)botBid] Impersomator:impBid];
                    [playerBids replaceObjectAtIndex:botId withObject:[NSNumber numberWithFloat:botBid]];
                }
                 
        }
        
        
    }];
    
    
}


- (void) humansRun: (float) myTime
{
    const float duration = [gameContext calcAuctionTime];
    __block float speed = 0.0f;
    __block float lastSP = 0.0f;
    
    __block NSMutableArray* speeds = [[NSMutableArray alloc] initWithObjects:
                                      [NSNumber numberWithFloat:0],
                                      [NSNumber numberWithFloat:0],
                                      [NSNumber numberWithFloat:0],
                                      [NSNumber numberWithFloat:0],
                                      nil ];
    YABlockAnimator* anim = [world createBlockAnimator];
    humanAnim = anim;
    
    anim = [world createBlockAnimator];
    [anim setOnce:true];
    [anim setOnceReset:true];
    [anim setInterval:duration];
    [anim setDelay:myTime];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        
        event_keyPressed ev = (event_keyPressed) event.intValue;
        
        int deviceId = -1;
        float evVal = 0;
        int playerId = -1;
        
        switch (ev) {
            case GAMEPAD_LEFT_Y:
                evVal = (float)(message & 255) / 255.0f - 0.5f;
                speed = evVal * 0.1;
                deviceId = message >> 16;
                playerId = [gameContext playerForDevice:deviceId];
                [speeds replaceObjectAtIndex:playerId withObject:[NSNumber numberWithFloat:speed]];
                break;
            case MOUSE_DOWN:
                if(message == [cursorUpImp identifier])
                    speed = -0.5 * 0.1;
                else if (message == [cursorDownImp identifier])
                    speed = 0.5 * 0.1;
                else
                    speed = 0;
                
                playerId = [gameContext playerForDevice:1000];
                [speeds replaceObjectAtIndex:playerId withObject:[NSNumber numberWithFloat:speed]];
                break;
            case MOUSE_UP:
                speed = 0;
                playerId = [gameContext playerForDevice:1000];
                [speeds replaceObjectAtIndex:playerId withObject:[NSNumber numberWithFloat:speed]];
                break;
            default:
                break;
        }
        
        if(lastSP == sp)
            return;
        
        lastSP = sp;
        
        for(int playerId = 0; playerId < [gameContext playerNumber]; playerId ++) {
            
            float playerBid = [[playerBids objectAtIndex:playerId] floatValue];
            int playerMoney = [[gameContext.playerGameData objectAtIndex:playerId] money];
            
            // not enough money to bid
            if(playerMoney < price)
                continue;
            
            id<YAImpersonatorMover> mover = [[gameContext.playerGameData objectAtIndex:playerId] impMover];
            
            float speed = [[speeds objectAtIndex:playerId] floatValue];
            if(fabs(speed) > 0.01) {
                
                // already bid all money
                if(playerMoney <= playerBid && speed < 0)
                    continue;
                
                YAImpersonator* imp = [[gameContext.playerGameData objectAtIndex:playerId] impersonator];
                
                float newPos = imp.translation.x + speed;
                [[imp translation] setX: fmin(fmax(newPos, PLAYER_IMP_ORIGIN), PLAYER_IMP_ORIGIN * -1)];
                [mover setActive:walk];
                [[[playerColorRings objectAtIndex:playerId] translation] setX: fmin(fmax(newPos, PLAYER_IMP_ORIGIN), PLAYER_IMP_ORIGIN * -1)];
                
                YAImpersonator* impBid = [playerBidsImps objectAtIndex:playerId];
                if(newPos <= BID_LINE_ORIGIN) {
                    
                    if(playerBid == 0)
                        playerBid = price;
                    else
                        playerBid -= speed * 20;
                    
                    // overwrite position to max (puffer)
                    if(imp.translation.x < PLAYER_IMP_ORIGIN) {
                        [[imp translation] setX: PLAYER_IMP_ORIGIN];
                        [[[playerColorRings objectAtIndex:playerId] translation] setX: PLAYER_IMP_ORIGIN];
                    }
                    
                    [world updateTextIngredient:[NSString stringWithFormat:@"%d", (int)playerBid] Impersomator:impBid];
                    [playerBids replaceObjectAtIndex:playerId withObject:[NSNumber numberWithFloat:playerBid]];
                } else if(playerBid != 0) {
                    playerBid = 0;
                    [world updateTextIngredient:[NSString stringWithFormat:@"%d", (int)playerBid] Impersomator:impBid];
                    [playerBids replaceObjectAtIndex:playerId withObject:[NSNumber numberWithFloat:playerBid]];
                }
                
                
                
            } else {
                [mover reset];
                [mover setActive:none];
            }
        }
        
    } ];
}

- (int) calculatePrice: (YAVector2i*) plot
{
    float distance = [plot distanceTo:[[YAVector2i alloc] initVals:3 :3]];
    float newPrice = (5 - distance) * 150 + [YAProbability random] * 50;
    return (int)newPrice;
}

- (float) presentPlot: (float) myTime
{
    assert(freePlot != nil);
    assert(colonyMap != nil);
    
    float duration = 2;
    
    [colonyMap setClaim:PLAYER_STORE X:freePlot.x Z:freePlot.y At:myTime];
    
    __block YABlockAnimator* blink = [world createBlockAnimator];
    __weak YABlockAnimator* blinkW = blink;
    [blink setDelay:myTime];
    [blink setProgress:harmonic];
    [blink setInterval:0.5f];
    [blink addListener:^(float sp, NSNumber *event, int message) {
        YAImpersonator* imp = [colonyMap getSocketImpAtX: freePlot.x Z:freePlot.y];
        [[[imp material] phongAmbientReflectivity] setX:sp + 0.5];
        if(blinkW.deleteme)
            imp.material.phongAmbientReflectivity.x = imp.material.phongAmbientReflectivity.y;
    }];
    
    YABlockAnimator* anim = [world createBlockAnimator];
    [anim setOneExecution:true];
    [anim setDelay:myTime + duration];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        YAImpersonator* imp = [colonyMap getSocketImpAtX: freePlot.x Z:freePlot.y];
        [_soundCollector playForImp:imp Sound:[_soundCollector getSoundId:@"LaserC"]];

        [[[imp material] phongAmbientReflectivity] setX:sceneUtils.color_grey_white.x];
        [blink setDeleteme:true];
    }];
    return myTime + duration;
}

// Run the SunClock. The event is finished if the time runs up
- (float) sunCounter: (float) myTime
{
    
    YAChronograph* chronograph = [[YAChronograph alloc] init];
    
    const float duration = [gameContext calcAuctionTime];
    float startRotation = 100;
    __block bool isFinished = false;
    
    YABlockAnimator* anim = [world createBlockAnimator];
    __weak YABlockAnimator* animW = anim;
    
    __block float lastTotalBids;
    __block float lastSP = 0;
    __block float realSP = 0;

    [anim setAsyncProcessing:NO];
    [anim setOnce:true];
    [anim setOnceReset:true];
    [anim setProgress:cyclic];
    [anim setInterval:duration];
    [anim setDelay:myTime];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        
        const float totalBids = [[playerBids objectAtIndex:0] floatValue] +
                                [[playerBids objectAtIndex:1] floatValue] +
                                [[playerBids objectAtIndex:2] floatValue] +
                                [[playerBids objectAtIndex:3] floatValue];
        
        float timeMultiplier = lastTotalBids == totalBids && totalBids != 0 ? 1.5f : 1.0f;
        lastTotalBids = totalBids;
        
        realSP =  realSP + ((sp - lastSP) * timeMultiplier);
        lastSP = sp;
        
        [[sunCoverImp rotation] setY: startRotation + realSP * 360];
        stickSunImp.rotation.y = startRotation + realSP * 360;
        [[sunImp rotation] setY: startRotation - realSP * 360 * 0.1];
        
        if(realSP >= 1)
            animW.deleteme = YES;
        
        if(animW.deleteme) {
            isFinished = YES;
        }
        

        
    } ];
    
    do {
        [chronograph wait:0.5];
    } while (!isFinished);
    
    botAnim.deleteme = YES;
    humanAnim.deleteme = YES;
    
    [chronograph wait:1.0];
    
    return 0;
}

#pragma mark Entry Function
#pragma mark -

- (float) auction: (float) myTime
{
    assert(colonyMap != nil);
    assert(terrainImp != nil);
    assert(gameContext != nil);
    assert(sunImp != nil);
    assert(sunCoverImp != nil);
    assert(boardImp != nil);
    assert(boardTitleImp != nil);
    
    gcImps = [[NSMutableArray alloc] init];
    
    playerColorRings = [sceneUtils createPlayerColorRings:gameContext];
    playerColorBalls = [sceneUtils createPlayerColorBalls:gameContext];
    
    for(YAImpersonator* impB in playerColorBalls) {
        [impB resize:0.8];
        [[impB translation] setValues:0 :1.5 :0];
        [impB setVisible:false];
    }
    
    playerBids = [[NSMutableArray alloc] initWithObjects:
                  [NSNumber numberWithFloat:0],
                  [NSNumber numberWithFloat:0],
                  [NSNumber numberWithFloat:0],
                  [NSNumber numberWithFloat:0],
                  nil];
    
    playerBidsImps = [[NSMutableArray alloc] init];
    
    winner = -1;
    
    __block  YAImpersonator* textLandSale = [sceneUtils genTextBlocked:[YALog decode:@"landForSale"]];
    [gcImps addObject:textLandSale];
    [textLandSale resize:0.15];
    [[textLandSale translation] setVector:[[YAVector3f alloc] initVals:-0.5 :0.9 :5]];
    [[[textLandSale material] phongAmbientReflectivity] setVector:sceneUtils.color_yellow];
    [[textLandSale material] setEta:0.3];
    [textLandSale setClickable:false];
    [textLandSale setVisible:false];
    
    [sceneUtils showImp:textLandSale atTime:myTime];
    [sceneUtils alignToCam:textLandSale AtTime: myTime];
    
    freePlot = colonyMap.randomVacantPlot;
    
    myTime = [self presentPlot:myTime];
    myTime = [sceneUtils moveAvatarPositionTo:AVATAR_AUCTION At:myTime];
    [sceneUtils removeImp:textLandSale atTime:myTime];
    
    myTime += 0.5;
    [colonyMap hideImps:myTime];
    
    // hide map
    YAInterpolationAnimator* ipo = [world createInterpolationAnimator];
    [ipo setDelay:myTime];
    [ipo addIpo:[[YAVector3f alloc] initVals:0.6 :0.6 :0.6]  timeFrame:0.0f];
    [ipo addIpo:[[YAVector3f alloc] initVals:127.0 / 102.0 :108.0 / 98.0 :59.0 / 36.0]  timeFrame:0.7f];
    [ipo addListener:[[terrainImp material] phongAmbientReflectivity]];
    
    YABlockAnimator* anim = [world createBlockAnimator];
    [anim setOnce:true];
    [anim setInterval:0.7];
    [anim setProgress:damp];
    [anim setDelay:myTime];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        [terrainImp setNormalMapFactor:1 - sp];
    }];

    myTime += 0.7;
   
    for(YAImpersonator* imp in playerColorRings)
        [sceneUtils showImp:imp atTime:myTime];

    [sceneUtils showImp:boardTitleImp atTime:myTime];
    [sceneUtils hideImp:boardImp atTime:myTime];
    [sceneUtils hideImp:terrainImp atTime:myTime];
    
    NSString* auctionText = [NSString stringWithFormat:@"%@%d", [YALog decode:@"landAuction"], auctionNumber];
    textLandSale = [sceneUtils genTextBlocked:auctionText];
    [gcImps addObject:textLandSale];
    [textLandSale resize:0.15];
    [[textLandSale translation] setVector:[[YAVector3f alloc] initVals:-0.6 :0.95 :5]];
    [[[textLandSale material] phongAmbientReflectivity] setVector:sceneUtils.color_yellow];
    [textLandSale setClickable:false];
    [textLandSale setVisible:false];
    
    [sceneUtils showImp:textLandSale atTime:myTime];
    [sceneUtils alignToCam:textLandSale AtTime: myTime];
    
    // create the player meeples
    for(int playerId = 0; playerId < 4; playerId++) {
        YAAlienRace* ar = [[gameContext playerGameData]objectAtIndex:playerId];
        YAImpersonator* imp = ar.impersonator;
        [sceneUtils showImp:imp atTime:myTime];
        
        anim = [world createBlockAnimator];
        [anim setOneExecution:true];
        [anim setDelay:myTime];
        [anim addListener:^(float sp, NSNumber *event, int message) {
            
            [ar sizeSmall];
            [[imp translation] setZ: PLAYER_IMP_ORIGIN + 3.3f * playerId];
            [[imp translation] setY: 0.1];
            [[imp translation] setX: PLAYER_IMP_ORIGIN * -1];
            [[imp rotation] setY: -90];
            
            YAImpersonator* colorRingImp = [playerColorRings objectAtIndex:playerId];
            [[colorRingImp translation] setZ: PLAYER_IMP_ORIGIN + 3.3f * playerId];
            [[colorRingImp translation] setY: 0.1];
            [[colorRingImp translation] setX: 5];
            [[colorRingImp rotation] setX: -90];
            [colorRingImp resize:0.65];
            
            int score = [[[gameContext playerGameData] objectAtIndex:playerId] money];
            YAImpersonator* scoreImp = [sceneUtils genText:[NSString stringWithFormat:@"%d", score]];
            [gcImps addObject:scoreImp];
            [scoreImp resize:0.15];
            [[scoreImp translation] setVector:[[YAVector3f alloc] initVals:-1.95 + (1.16 * playerId) :-1.0 :5]];
            [[[scoreImp material] phongAmbientReflectivity] setVector:sceneUtils.color_yellow];
            [sceneUtils alignToCam:scoreImp];
            
            YAImpersonator* bidImp = [sceneUtils genText:[NSString stringWithFormat:@"%d", 0]];
            [gcImps addObject:bidImp];
            [playerBidsImps addObject:bidImp];
            [bidImp resize:0.15];
            [[bidImp translation] setVector:[[YAVector3f alloc] initVals:-1.95 + (1.16 * playerId) :-0.85 :5]];
            [[[bidImp material] phongAmbientReflectivity] setVector:sceneUtils.color_red];
            [sceneUtils alignToCam:bidImp];
            
            if([gameContext deviceIdforPlayer:playerId] == 1000) {
                int cursorImpId = [world createImpersonator:@"csArrow"];
                cursorUpImp = [world getImpersonator:cursorImpId];
                [[cursorUpImp rotation] setX: -90];
                [[cursorUpImp rotation] setY: 90];
                [[cursorUpImp size] setZ:0.2];
                [[cursorUpImp size] setX:0.8];
                [[cursorUpImp size] setY:0.9];
                [[cursorUpImp translation] setValues:-4.968626 :0.01 : 7 ];
                [cursorUpImp setClickable:true];
                
                int cursorDownImpId =[world createImpersonator:@"csArrow"];
                cursorDownImp = [world getImpersonator:cursorDownImpId];
                [[cursorDownImp rotation] setX: 90];
                [[cursorDownImp rotation] setY: 90];
                [[cursorDownImp size] setZ:0.2];
                [[cursorDownImp size] setX:0.8];
                [[cursorDownImp size] setY:0.9];
                [[cursorDownImp translation] setValues:-2.433331 :0.01 : 7];
                [cursorDownImp setClickable:true];

            }
        }];
    }
    
    // show the barrack
    [sceneUtils showImp:barrackImp atTime:myTime];
    [sceneUtils showImp:sunImp atTime:myTime];
    [sceneUtils showImp:sunCoverImp atTime:myTime];
    [sceneUtils showImp:stickSunImp atTime:myTime];

    [sceneUtils showImp:planeImp atTime:myTime];
    
    anim = [world createBlockAnimator];
    [anim setOneExecution:true];
    [anim setDelay:myTime];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        [[planeImp rotation] setY:-90];
        [[planeImp size] setY:0.05];
        [[planeImp size] setX:5.5];
        [[planeImp translation] setZ:-0.1];
        [[planeImp translation] setX: BID_LINE_ORIGIN];
        [[planeImp translation] setY: 0.105];
        planeImp.material.eta = 20.0f;
        
        
        const float sunHeight = 3.0;
        const float sunXPos = -5.2;
        
        [[sunImp translation] setValues:1.096080 :sunHeight :sunXPos];
        [[sunCoverImp translation] setValues:1.096080 :sunHeight :sunXPos];
        [[stickSunImp translation] setValues:1.096080 :sunHeight + 1.105 :sunXPos];

        [[sunCoverImp rotation] setY:100];
        [[stickSunImp rotation] setY:100];

        [_soundCollector playForImp:planeImp Sound:[_soundCollector getSoundId:@"Powerup"]];
        
    }];
    
    price = [self calculatePrice:freePlot];
    
    NSString* bidsStartText = [NSString stringWithFormat:@"%@%d", [YALog decode:@"bidsStart"], price];
    YAImpersonator* bidsStartTextImp = [sceneUtils genTextBlocked:bidsStartText];
    [gcImps addObject:bidsStartTextImp];
    [bidsStartTextImp resize:0.1];
    [[bidsStartTextImp translation] setVector:[[YAVector3f alloc] initVals:-0.5 :-0.2 :5]];
    [bidsStartTextImp setClickable:false];
    [bidsStartTextImp setVisible:false];
    
    [sceneUtils showImp:bidsStartTextImp atTime:myTime];
    [sceneUtils alignToCam:bidsStartTextImp AtTime: myTime];
    
    
    actualBidTextImp = [sceneUtils genTextBlocked:[YALog decode:@"noBids"]];
    [gcImps addObject:actualBidTextImp];
    [actualBidTextImp resize:0.15];
    [[actualBidTextImp translation] setVector:[[YAVector3f alloc] initVals:-0.65 :0.75 :5]];
    [[[actualBidTextImp material] phongAmbientReflectivity] setVector:sceneUtils.color_yellow];
    actualBidTextImp.material.eta = 0.4;
    [actualBidTextImp setClickable:false];
    [actualBidTextImp setVisible:false];
    
    [sceneUtils showImp:actualBidTextImp atTime:myTime];
    [sceneUtils alignToCam:actualBidTextImp AtTime: myTime];
    
    [self humansRun:myTime];
    [self botsRun:myTime];
    [self bitLine:myTime];
    [self calcHighBid:myTime];
    
    // let the balls move
    animBall = [world createBasicAnimator];
    [animBall setDelay:myTime];
    [animBall setProgress:harmonic];
    [animBall setInterval:0.5];
    
    [animBall addListener:[[playerColorBalls objectAtIndex:0] translation] factor:0.2];
    [animBall addListener:[[playerColorBalls objectAtIndex:1] translation] factor:0.2];
    [animBall addListener:[[playerColorBalls objectAtIndex:2] translation] factor:0.2];
    [animBall addListener:[[playerColorBalls objectAtIndex:3] translation] factor:0.2];
    
    myTime = [self sunCounter:myTime];
    
    
    // cleanup
    YABlockAnimator* cleanUp = [world createBlockAnimator];
    [cleanUp setOneExecution:true];
    [cleanUp setDelay:myTime];
    [cleanUp addListener:^(float sp, NSNumber *event, int message) {
        
        if(winner != -1) {
            
            YAAlienRace* playerWinner = [gameContext.playerGameData objectAtIndex:winner];
            playerWinner.money -= [[playerBids objectAtIndex:winner] floatValue];

            [colonyMap changePlotOwnerAtX:freePlot.x Z:freePlot.y Owner:winner];
        } else { // No Winner
            [colonyMap destroyPlotAtX:freePlot.x Z:freePlot.y];
        }
            
        [animBall setDeleteme:true];
        
        for(YAAlienRace* ar in [gameContext playerGameData]) {
            id<YAImpersonatorMover> mover = [ar impMover];
            [mover setActive:none];
            [[ar impersonator] setVisible:false];
       }

        for(YAImpersonator* impGC in gcImps)
            [sceneUtils removeImp:impGC atTime:0];
        
        for(YAImpersonator* impGC in playerColorRings)
            [sceneUtils removeImp:impGC atTime:0];
        
        for(YAImpersonator* impGC in playerColorBalls)
            [sceneUtils removeImp:impGC atTime:0];

        [sceneUtils hideImp:planeImp atTime:0];
        [sceneUtils hideImp:barrackImp atTime:0];
        
        [sceneUtils removeImp:cursorUpImp atTime:0];
        [sceneUtils removeImp:cursorDownImp atTime:0];

        [sceneUtils hideImp:sunImp atTime:0];
        [sceneUtils hideImp:sunCoverImp atTime:0];
        [sceneUtils hideImp:stickSunImp atTime:0];

        [sceneUtils hideImp:boardTitleImp atTime:0];
        [sceneUtils showImp:boardImp atTime:0];
        [sceneUtils showImp:terrainImp atTime:0];

    }];
    
    
    // show map
    ipo = [world createInterpolationAnimator];
    [ipo setDelay:myTime];
    [ipo addIpo:[[YAVector3f alloc] initVals:127.0 / 102.0 :108.0 / 98.0 :59.0 / 36.0]  timeFrame:0.0f];
    [ipo addIpo:[[YAVector3f alloc] initVals:0.6 :0.6 :0.6]  timeFrame:0.7f];
    [ipo addListener:[[terrainImp material] phongAmbientReflectivity]];

    anim = [world createBlockAnimator];
    [anim setOnce:true];
    [anim setInterval:0.7];
    [anim setProgress:damp];
    [anim setDelay:myTime];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        [terrainImp setNormalMapFactor:sp];
    }];
    
    myTime += 0.7;
    [colonyMap showImps:myTime];
    
    return myTime;
}

@end
