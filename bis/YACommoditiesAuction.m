//
//  YAComoditiesAuction.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 20.03.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import <math.h>

#import "YALog.h"
#import "YAImpersonatorMover.h"
#import "YAProbability.h"
#import "YAChronograph.h"
#import "YAVector2i.h"
#import "YAGouradLight.h"
#import "YAAvatar.h"
#import "YAAlienRace.h"
#import "YABlockAnimator.h"
#import "YAInterpolationAnimator.h"
#import "YAMaterial.h"
#import "YAVector3f.h"
#import "YAImpersonator.h"
#import "YAImpCollector.h"
#import "YAGameContext.h"
#import "YASceneUtils.h"
#import "YARenderLoop.h"
#import "YAColonyMap.h"
#import "YASoundCollector.h"
#import "YAStore.h"
#import "YACommoditiesAuction.h"

#define DEFAULT_CHART_MAX 20
#define DEFAULT_CHART_MIN_RANGE 0.01f
#define DEFAULT_CHART_MAX_RANGE 2.0f
#define BID_LINE_ORIGIN 4.2f
#define DECISION_SHORT 5.0f
#define PLAYER_IMP_ORIGIN -5.0f
#define DEFAULT_MOVE_SPEED 0.1f
#define ADDITIONAL_MOVE_SPEED 0.025f
#define STORE_ID 4
#define TRANSACTION_TIMEOUT 0.5f
#define GAMEPAD_DEADZONE 0.01f

@implementation YACommoditiesAuction {
    YAImpCollector* impCollector;
    YAGameContext*  gameContext;
    YASceneUtils* sceneUtils;
    YARenderLoop* world;
    YAColonyMap* colonyMap;
    YASoundCollector* soundCollector;
    YAStore* store;
    
    NSMutableArray* gcLocalImps;
    NSArray *playerColorRings, *playerColorBalls, *playerColorBars, *playerMaterial;
    
    NSMutableArray *commoditiyUnitTextImps, *moneyTextImps, *shortageMargins, *shortageMarginsValues, *bidLines;
    NSMutableArray *playerBidTextImps;
    NSArray *botSellMentality;
    
    tCommodity activeCommodity;
    YAImpersonator *cursorUpImp, *cursorDownImp;
    
    YAVector2i* shopPrices; // buy,sell
    YAVector2i* auctionPrices; // buy,sell
    
    NSMutableArray *isPlayerSeller, *playerBids;
    
    
    // in this auction the meeple position is mapped by the price tag
    float initBuyMeeplePrice, initSellMeeplePrice;
    
    YAImpersonator* storeIconBuyImp;
    YAImpersonator* sellPriceImp;
    
}

- (id) initInfo: (NSDictionary*) info;
{
    self = [super init];
    
    if(self) {
        NSAssert(info, @"Auction Created without game information.");
        _info = info;
        
        [self setupGlobals:_info];
    }
    
    return self;
}

-(void) initDicts
{
    gcLocalImps = [[NSMutableArray alloc] init];
    commoditiyUnitTextImps = [[NSMutableArray alloc] init];
    moneyTextImps = [[NSMutableArray alloc] init];
    shopPrices = [[YAVector2i alloc] init];
    
    isPlayerSeller = [[NSMutableArray alloc] init];
    playerBids = [[NSMutableArray alloc] init];
    bidLines = [[NSMutableArray alloc] init];
    playerBidTextImps = [[NSMutableArray alloc] init];
    
    botSellMentality = [NSArray arrayWithObjects:
                        [NSNumber numberWithFloat:[YAProbability random]],
                        [NSNumber numberWithFloat:[YAProbability random]],
                        [NSNumber numberWithFloat:[YAProbability random]],
                        [NSNumber numberWithFloat:[YAProbability random]],
                        nil];
    
    for(int playerid = 0; playerid < 4; playerid++) {
        [isPlayerSeller addObject:@NO];
        [playerBids addObject:@0.0f];
    }

}

- (void) auctionFor: (tCommodity) material;
{
    // NSLog(@"Start Comodities Auction");

    YAChronograph* chronograph = [[YAChronograph alloc] init];
    
    _isFinished = NO;
    activeCommodity = material;
    
    if([self maxPossession] +
       [self storeUnits] +
       [self producedCommodities:0] +
       [self producedCommodities:1] +
       [self producedCommodities:2] +
       [self producedCommodities:3] == 0) {
        // NSLog(@"Nothing to trade");
        return;
    }
    
    [self initDicts];
    
    [self setupLocalImps];
    [self createTitle:material];
    [self showSunClock];
    [self setupMeeple];
    [self showOptionalMouseCursor];
    [self showCommmodityUnits];
    [self showChartBars];
    
    [chronograph wait:1.0f];
    
    for(int playerId = 0; playerId < 4; playerId++ ) {
        [[playerColorBars objectAtIndex:playerId] setVisible:NO];
        [[shortageMargins objectAtIndex:playerId] setVisible:NO];
        [[shortageMarginsValues objectAtIndex:playerId] setVisible:NO];
    }
    
    [self createStoreImp];
    [self calcShopPrices];
    [self showShopPrices];
    
    // initial position for meeples
    [self commendRole];
    YABlockAnimator* overweriteCommedRole = [self overwriteCommedRole];
    [self showBidLines];
    
    YAImpersonator* declareTextImp = [self declareText];
    [self startSunClockBlocking:DECISION_SHORT];
    
    overweriteCommedRole.deleteme = YES;
    
    [chronograph wait:1.0f];
    declareTextImp.visible = NO;
    
    [self showPlayerBids];
    
    // start auction
    // presets are shop prices
    auctionPrices = [[YAVector2i alloc] initCopy:shopPrices];
    [self initPlayerBids];
    
    YABlockAnimator* bidLineUpdater = [self updateBidLines];
    YABlockAnimator* auctionPriceRangeUpdater = [self updateAuctionPriceRange];
    YABlockAnimator* botsRun = [self botsRun];
    YABlockAnimator* humansRun = [self humansRun];
    YABlockAnimator* transActions =  [self transActions];
    
    const float auctionTime = [gameContext calcAuctionTime];
    
    [soundCollector playForImp:declareTextImp Sound:[soundCollector getSoundId:@"Powerup"]];
    [self startSunClockBlocking:auctionTime];
    auctionPriceRangeUpdater.deleteme = YES;
    bidLineUpdater.deleteme = YES;
    transActions.deleteme = YES;
    botsRun.deleteme = YES;
    humansRun.deleteme =YES;
    
    [chronograph wait:1.0f];
    
    [self shutDownLocalImps];
    
    for(int playerId = 0; playerId < 4; playerId++) {
        YAAlienRace* player = [gameContext.playerGameData objectAtIndex:playerId];
        player.impersonator.visible = NO;
        [player.impMover setActive:none];
        [player.impMover reset];
    }
    
    [self hideSunCLock];
    
    [chronograph wait:2];
}

#pragma mark -

- (YABlockAnimator*) overwriteCommedRole
{
    
    YABlockAnimator* anim = [world createBlockAnimator];
    
    [anim addListener:^(float sp, NSNumber *event, int message) {
        
        event_keyPressed ev = (event_keyPressed) event.intValue;
        const float evVal = (float)(message & 255) / 255.0f - 0.5f;
        const int deviceId = message >> 16;
        
        int playerId = -1;
        
        // identify playerId from device message
        switch (ev) {
            case GAMEPAD_LEFT_Y:
                playerId = [gameContext playerForDevice:deviceId];
                
                if(playerId == -1)
                    return;
                
                if(evVal < -0.40)
                    [self positionPlayer:playerId Seller:YES];
                else if(evVal > 0.40)
                    [self positionPlayer:playerId Seller:NO];

                break;
            case MOUSE_DOWN:
                
                playerId = [gameContext playerForDevice:1000];
                
                if(playerId == -1)
                    return;
                
                if(message == [cursorUpImp identifier])
                    [self positionPlayer:playerId Seller:YES];
                
                if(message == [cursorDownImp identifier])
                    [self positionPlayer:playerId Seller:NO];
                
                break;
            default:
                break;
        }
    }];
    
    return anim;
}

- (YABlockAnimator*) transActions
{
    __block YAImpersonator* buyBidLine = [bidLines objectAtIndex:0];
    __block YAImpersonator* sellBidLine = [bidLines objectAtIndex:1];

    __block YAChronograph* chronograph = nil;
    
    __block float transactionTimeout = TRANSACTION_TIMEOUT;
    __block int lastBuyerId = -1;
    __block int lastSellerId = -1;
    
    YABlockAnimator *anim = [world createBlockAnimator];
    anim.asyncProcessing = NO;
    
    [anim addListener:^(float sp, NSNumber *event, int message) {
        
        if(chronograph != nil) {
            if (chronograph.getTime <= transactionTimeout) {
                return;
            } else {
                chronograph = nil;
            }
        }
        
        const float buyX = buyBidLine.translation.x;
        const float sellX = sellBidLine.translation.x;
        const float distance = buyX - sellX;
        
        if(distance > 0)
            return;
        
        int sellerId = -1;
        int buyerId = STORE_ID;
        
        float sellPrice = 100000;
        float buyPrice = shopPrices.x;
        
        if([self storeUnits] > 0) {
            sellerId = STORE_ID;
            sellPrice = shopPrices.y;
        }
        
        float lastBuyerPrice = -1000;
        float lastSellerPrice = -1000;
        
        for(int playerId = 0; playerId < 4; playerId++) {
            
            const float playerPrice = [[playerBids objectAtIndex:playerId] floatValue];
            
            if([[isPlayerSeller objectAtIndex:playerId] boolValue]) {
                if(playerPrice < sellPrice) {
                    sellerId = playerId;
                    sellPrice = playerPrice;
                    
                    if(lastSellerId == playerId)
                        lastSellerPrice = sellPrice;
                    
                }
            } else {
                if(playerPrice > buyPrice) {
                    buyerId = playerId;
                    buyPrice = playerPrice;
                    
                    if(lastBuyerId == playerId)
                        lastBuyerPrice = playerPrice;
                }
                
            }
        }
        
        if(sellerId == buyerId)
            return;
        
        if(sellPrice > auctionPrices.y)
            return;
        
        if(lastBuyerPrice == buyPrice)
            buyerId = lastBuyerId;
        
        if(lastSellerPrice == sellPrice)
            sellerId = lastSellerId;
        
        // start the transaction
        
        if(buyerId != STORE_ID) {
            int newAccount = [self updateMoney:buyerId Money:-sellPrice];
            [world updateTextIngredient:[NSString stringWithFormat:@"%4d", newAccount] Impersomator:[moneyTextImps objectAtIndex:buyerId]];
            [self changeAccountedUnits:1 Player:buyerId];
        } else {
            [self changeStoreUnits:1];
        }
        
        if(sellerId != STORE_ID) {
            int newAccount = [self updateMoney:sellerId Money:sellPrice];
            [world updateTextIngredient:[NSString stringWithFormat:@"%4d", newAccount] Impersomator:[moneyTextImps objectAtIndex:sellerId]];
            [self changeAccountedUnits:-1 Player:sellerId];
            
            if([self availableUnits:sellerId] == 0 || [self calculatePosseession:sellerId] <= 0) {
                [playerBids replaceObjectAtIndex:sellerId withObject:[NSNumber numberWithFloat:initSellMeeplePrice]];
            }
            
        } else {
            [self changeStoreUnits:-1];
            
            if([self storeUnits] == 0) {
                storeIconBuyImp.visible = NO;
                sellPriceImp.visible = NO;
            }
        }
        
        [self updateCommodityUnits];
        [soundCollector playForImp:sellBidLine Sound:[soundCollector getSoundId:@"Pickup"]];
        
        if(sellerId != lastSellerId || buyerId != lastBuyerId) {
            lastSellerId = sellerId;
            lastBuyerId = buyerId;
            transactionTimeout = TRANSACTION_TIMEOUT;
        } else {
            transactionTimeout -= 0.05;
            if(transactionTimeout <= 0.01)
                transactionTimeout = 0.01;
        }
        
        chronograph = [[YAChronograph alloc] init];
        [chronograph start];
    }];
    
    return anim;
}

- (void) initPlayerBids
{
    [self setInitPrices];
    
    for (int playerId = 0; playerId < 4; playerId++) {
        if([[isPlayerSeller objectAtIndex:playerId] boolValue])
            [playerBids replaceObjectAtIndex:playerId withObject:[NSNumber numberWithFloat:initSellMeeplePrice]];
        else
            [playerBids replaceObjectAtIndex:playerId withObject:[NSNumber numberWithFloat:initBuyMeeplePrice]];
    }
    
}

- (YABlockAnimator*) updateAuctionPriceRange
{
    
    YABlockAnimator* anim = [world createBlockAnimator];
    anim.asyncProcessing = NO;
    
    [anim addListener:^(float sp, NSNumber *event, int message) {
        
        float sellPrice = auctionPrices.y;
        NSMutableArray* newMinPoss = [[NSMutableArray alloc] init];
        NSMutableArray* newMaxPoss = [[NSMutableArray alloc] init];
        
        for(int playerId = 0; playerId < 4; playerId++) {
            const float playerBid = [[playerBids objectAtIndex:playerId] floatValue];
            
            if(playerBid < auctionPrices.x) {
                [newMinPoss addObject:[NSNumber numberWithInt:playerId]];
            } else if(playerBid > auctionPrices.y) {
                [newMaxPoss addObject:[NSNumber numberWithInt:playerId]];
            } else  if(![[isPlayerSeller objectAtIndex:playerId] boolValue]) {
                if(playerBid + 1 > sellPrice)
                    sellPrice = playerBid + 5;
            }
            
        }
        
        if(sellPrice == auctionPrices.y)
            return;
        
        auctionPrices.y = sellPrice;
        [self setInitPrices];
        
        for(NSNumber* playerNum in newMinPoss) {
            int playerId = playerNum.intValue;
            [playerBids replaceObjectAtIndex:playerId withObject:[NSNumber numberWithFloat:initBuyMeeplePrice]];
        }
        
        for(NSNumber* playerNum in newMaxPoss) {
            int playerId = playerNum.intValue;
            [playerBids replaceObjectAtIndex:playerId withObject:[NSNumber numberWithFloat:initSellMeeplePrice]];
        }
        
        
    }];
    
    
    return anim;
}

- (void) setInitPrices
{
    // setup bid for 0 position
    const float initRange = -PLAYER_IMP_ORIGIN - BID_LINE_ORIGIN; // 0.6f
    const float bidRange = 2 * BID_LINE_ORIGIN; // 8.4f
    const float priceMultiplier = initRange / bidRange; // 0,0714
    const float priceRange = auctionPrices.y - auctionPrices.x;
    const float linearPriceDist = priceRange * priceMultiplier;
    
    initSellMeeplePrice = auctionPrices.y + linearPriceDist;
    initBuyMeeplePrice = auctionPrices.x - linearPriceDist;
}

- (YABlockAnimator*) updateBidLines
{
    __block YAImpersonator* buyBidLine = [bidLines objectAtIndex:0];
    __block YAImpersonator* sellBidLine = [bidLines objectAtIndex:1];
    
    YABlockAnimator* anim = [world createBlockAnimator];
    anim.asyncProcessing = NO;
    [anim addListener:^(float sp, NSNumber *event, int message) {
        
        const float initMinPrice = auctionPrices.x;
        const float initMaxPrice = auctionPrices.y;
        
        float minPrice = initMinPrice;
        float maxPrice = initMaxPrice;
        
        
        // begin with shop
        if(shopPrices.x > minPrice)
            minPrice = shopPrices.x;
        
        if(shopPrices.y < maxPrice && self.storeUnits > 0)
            maxPrice = shopPrices.y;
        
        for(int playerId = 0; playerId < 4; playerId++) {
            const float playerBid = [[playerBids objectAtIndex:playerId] floatValue];
            
            if([[isPlayerSeller objectAtIndex:playerId] boolValue])
                maxPrice = maxPrice > playerBid && playerBid != 0 ? playerBid : maxPrice;
            else
                minPrice = minPrice < playerBid && playerBid != 0 ? playerBid : minPrice;
        }
        
        const float minMap = [YAProbability mapToProbRange:minPrice From:initMinPrice To:initMaxPrice];
        const float maxMap = [YAProbability mapToProbRange:maxPrice From:initMinPrice To:initMaxPrice];
        
        float xPosBuy = BID_LINE_ORIGIN - (BID_LINE_ORIGIN * 2) * minMap;
        float xPosSell = BID_LINE_ORIGIN - (BID_LINE_ORIGIN * 2) * maxMap;
        
        if(xPosBuy < xPosSell)
            xPosBuy = xPosSell;
        
        buyBidLine.translation.x = xPosBuy;
        sellBidLine.translation.x = xPosSell;
        
        // WARNING: Sideeffect
        [self updatePlayerBids];
        
    }];
    
    return anim;
}

-(void) updateMeeplePos: (int) playerId
{
    YAAlienRace* player = [gameContext playerDataForId:playerId];
    YAImpersonator* imp = player.impersonator;
    id<YAImpersonatorMover> mover = player.impMover;
    
    YAImpersonator* ringImp = [playerColorRings objectAtIndex:playerId];
    
    const float playerBid = [[playerBids objectAtIndex:playerId] floatValue];
    
    const float initMinPrice = auctionPrices.x;
    const float initMaxPrice = auctionPrices.y;
    
    const float posMap = [YAProbability mapToProbRange:playerBid From:initMinPrice To:initMaxPrice];
    float xPos = BID_LINE_ORIGIN - (BID_LINE_ORIGIN * 2) * posMap;
    if(xPos < PLAYER_IMP_ORIGIN)
        xPos = PLAYER_IMP_ORIGIN;
    
    if (xPos != imp.translation.x) {
        [mover setActive:walk];
    } else {
        [mover reset];
        [mover setActive:none];
    }
    
    imp.translation.x = xPos;
    ringImp.translation.x = xPos;
}

- (void) botRun: (int) playerId Amount: (int) amount Price: (float) price
{
    float (^priceDistance)(float) = ^(float myPrice) {
        float resultDistance = 10000;
        for(int pid = 0; pid <4; pid++) {
            const float playerPrice = [[playerBids objectAtIndex:pid] floatValue];
            const float distance = fabs(myPrice - playerPrice);
            if(distance < resultDistance
               && pid != playerId
               && [[isPlayerSeller objectAtIndex:pid] boolValue] != [[isPlayerSeller objectAtIndex:playerId] boolValue]
               && playerPrice >= auctionPrices.x
               && playerPrice <= auctionPrices.y)
                resultDistance = distance;
        }
        return resultDistance;
    };
    
    const bool iSell = [[isPlayerSeller objectAtIndex:playerId] boolValue];
    
    float actualBid = [[playerBids objectAtIndex:playerId] floatValue];
    
    if(iSell) {
        if(amount > 0 && actualBid > price) {

            if(priceDistance(actualBid) > 2 + 3.0f * [[botSellMentality objectAtIndex: playerId] floatValue] ) {
                actualBid -= DEFAULT_MOVE_SPEED;
                
                if(actualBid < price)
                    actualBid = price;
                
            }
        } else if(amount <= 0) {
            // actualBid += DEFAULT_MOVE_SPEED + 0.025; // always use runs dry
            actualBid = initSellMeeplePrice;
        }
    } else { // buy
        if(amount < 0 && actualBid < price) {
            actualBid += DEFAULT_MOVE_SPEED;
        } else if(amount >= 0) {
            actualBid -= DEFAULT_MOVE_SPEED + ADDITIONAL_MOVE_SPEED;
        }
    }
    
    // meeples should not leave the board
    if(actualBid < initBuyMeeplePrice)
        actualBid = initBuyMeeplePrice;
    else if (actualBid > initSellMeeplePrice)
        actualBid = initSellMeeplePrice;
    
    [playerBids replaceObjectAtIndex:playerId withObject:[NSNumber numberWithFloat:actualBid]];
    
    [self updateMeeplePos:playerId];
}

- (YABlockAnimator*) botsRun
{
    
    float (^playerPrice)(bool, float) = ^(bool isSeller, float price) {
        
        float result = price;
        
        for(int playerId = 0; playerId <4; playerId++) {
            
            if([[isPlayerSeller objectAtIndex:playerId] boolValue] == isSeller) {
                const float playerPrice = [[playerBids objectAtIndex:playerId] floatValue];
                
                if(isSeller && playerPrice < price)
                    result = playerPrice;
                else if(!isSeller && playerPrice > price)
                    result = playerPrice;
            }
        }
        
        return result;
    };
    
    const int botStartId = gameContext.playerNumber;
    
    YABlockAnimator* anim = [world createBlockAnimator];
    [anim setAsyncProcessing:NO];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        
        for(int botId = botStartId; botId < 4; botId++) {
            
            float price = 0;
            
            const int availableUnits = [self availableUnits:botId];
            
            if(availableUnits < 0) {// buy
                
                price = shopPrices.y; // shop sell price
                
                if(self.storeUnits <= 0)
                    price += (price / 100) * 10;
                
                price = fminf(playerPrice(YES, price), (float)[self availableMoney:botId]);
            }
            
            if(availableUnits > 0) { // sell
                price = shopPrices.x; // shop sell price
                price = playerPrice(NO, price);
            }
            
            [self botRun:botId Amount:availableUnits Price:price];
        }
        
    }];
    
    return anim;
}

-(YABlockAnimator*) humansRun
{
    
    __block float lastSP = -1;
    
    
    __block NSMutableArray* speeds = [[NSMutableArray alloc] initWithCapacity:4];
    
    for(int i = 0; i < 4; i++)
        [speeds addObject:@0.0f];
    
    YABlockAnimator* anim = [world createBlockAnimator];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        
        
        event_keyPressed ev = (event_keyPressed) event.intValue;
        const float evVal = (float)(message & 255) / 255.0f - 0.5f;
        const int deviceId = message >> 16;
        
        int playerId = -1;
        float speed = 0;
        bool isSeller;
        
        // identify playerId from device message
        switch (ev) {
            case GAMEPAD_LEFT_Y:
                playerId = [gameContext playerForDevice:deviceId];
                
                if(playerId == -1)
                    return;
                
                isSeller = [[isPlayerSeller objectAtIndex:playerId] boolValue];
                
                float addSpeed = 0;
                
                if((isPlayerSeller && evVal > 0) || (!isPlayerSeller && evVal < 0))
                    addSpeed = ADDITIONAL_MOVE_SPEED;
                
                speed = (DEFAULT_MOVE_SPEED + addSpeed) * -evVal * 2;
                
                if(fabsf(evVal) < GAMEPAD_DEADZONE)
                    speed = 0;
                
                if(isSeller && [self calculatePosseession:playerId] <= 0)
                    speed = 0;

                break;
            case MOUSE_DOWN:
                
                playerId = [gameContext playerForDevice:1000];
                
                if(playerId == -1)
                    return;
                
                isSeller = [[isPlayerSeller objectAtIndex:playerId] boolValue];
                
                if(message == [cursorUpImp identifier]) {
                    speed = DEFAULT_MOVE_SPEED;
                    
                    if(isSeller)
                        speed = ADDITIONAL_MOVE_SPEED;
                    
                }
                else if(message == [cursorDownImp identifier]) {
                    
                    speed = -DEFAULT_MOVE_SPEED;
                    if(!isSeller)
                        speed -= ADDITIONAL_MOVE_SPEED;
                    
                }
                break;
            case MOUSE_UP:
                playerId = [gameContext playerForDevice:1000];
                
                if(playerId == -1)
                    return;
                
                speed = 0;
                
                break;
            default:
                break;
        }
        
        
        if(playerId != -1)
            [speeds replaceObjectAtIndex:playerId withObject:[NSNumber numberWithFloat:speed]];
        
        if(lastSP == sp)
            return;
        else
            lastSP = sp;
        
        for(playerId = 0; playerId < 4; playerId++) {
            float speed = [[speeds objectAtIndex:playerId] floatValue];
            
            if([[isPlayerSeller objectAtIndex:playerId] boolValue] && [self calculatePosseession:playerId] <= 0)
                speed = 0;
            
            if(playerId < gameContext.playerNumber) {
                
                if(speed != 0) {
                    
                    float playerBid = [[playerBids objectAtIndex:playerId] floatValue];
                    playerBid += speed;
                    
                    if(![[isPlayerSeller objectAtIndex:playerId] boolValue]) {
                        float lowestSellBid = -1;
                        
                        if(self.storeUnits > 0)
                            lowestSellBid = shopPrices.y;
                        
                        for(int ppId = 0; ppId < 4; ppId++) {
                            if([[isPlayerSeller objectAtIndex:ppId] boolValue]) {
                                if([self availableUnits:ppId] > 0) {
                                    float ppIdPrice = [[playerBids objectAtIndex:ppId] floatValue];
                                    if(lowestSellBid > ppIdPrice)
                                        lowestSellBid = ppIdPrice;
                                }
                                
                            }
                        }
                        
                        if(lowestSellBid >=1 && playerBid > lowestSellBid)
                            playerBid = lowestSellBid;
                        
                        
                        if(playerBid < initBuyMeeplePrice)
                            playerBid = initBuyMeeplePrice;
                    } else { // player is seller
                        float highestbuyBid = shopPrices.x;
                        
                        
                        for(int ppId = 0; ppId < 4; ppId++) {
                            if(![[isPlayerSeller objectAtIndex:ppId] boolValue]) {
                                
                                    float ppIdPrice = [[playerBids objectAtIndex:ppId] floatValue];
                                    
                                    
                                    if(highestbuyBid < ppIdPrice)
                                        highestbuyBid = ppIdPrice;
                                
                            }
                        }
                        
                        
                        if(playerBid < highestbuyBid)
                            playerBid = highestbuyBid;
                    }
                    
                    [playerBids replaceObjectAtIndex:playerId withObject:[NSNumber numberWithFloat:playerBid]];
                }
                
                [self updateMeeplePos:playerId];
            }
        }
    }];
    
    return anim;
}

- (YAImpersonator*) declareText
{
    NSString* declareText = [YALog decode:@"declaration"];
    YAImpersonator* textImp = [sceneUtils genTextBlocked:declareText];
    
    [[[textImp material] phongAmbientReflectivity] setVector:sceneUtils.color_yellow];
    [textImp resize:0.15];
    [[textImp translation] setVector:[[YAVector3f alloc] initVals: -0.7 :0.2 :5]];
    [[textImp material] setEta:0.3];
    [sceneUtils alignToCam:textImp];
    
    [gcLocalImps addObject:textImp];
    
    return textImp;
}

- (void) startSunClockBlocking: (float) duration
{
    YAChronograph* c = [[YAChronograph alloc] init];
    
    const float startRotation = 100;
    __block bool isFinished = NO;
    
    YAImpersonator* sunCoverImp = impCollector.sunCoverImp;
    YAImpersonator* stickSunImp = impCollector.stickSunImp;
    YAImpersonator* sunImp = impCollector.sunImp;
    
    YABlockAnimator* anim = [world createBlockAnimator];
    YABlockAnimator* animW = anim;
    
    [anim setAsyncProcessing:NO];
    [anim setOnce:true];
    [anim setOnceReset:true];
    [anim setProgress:cyclic];
    [anim setInterval:duration];
    
    [anim addListener:^(float sp, NSNumber *event, int message) {
        [[sunCoverImp rotation] setY: startRotation + sp * 360];
        stickSunImp.rotation.y = startRotation + sp * 360;
        [[sunImp rotation] setY: startRotation - sp * 360 * 0.1];
        
        if(animW.deleteme) {
            isFinished = YES;
            [soundCollector playForImp:sunImp Sound:[soundCollector getSoundId:@"Pickup"]];
        }
        
    }];
    
    while(!isFinished)
        [c wait:0.1];
}

- (void) showBidLines
{
    const float undoHDR = - 0.8;
    
    int impId = [world createImpersonator:@"Plane"];
    __block YAImpersonator *imp = [world getImpersonator:impId];
    
    void (^setupImp)(float) = ^(float height) {
        [[imp rotation] setY:-90];
        [[imp size] setY:0.05];
        [[imp size] setX:5.5];
        [[imp translation] setZ:-0.1];
        [[imp translation] setX: height];
        [[imp translation] setY: 0.105];
        imp.material.eta = 20.0f;
        
        [[imp.material phongAmbientReflectivity] setVector:sceneUtils.color_black];
        [[imp.material phongDiffuseReflectivity] setValues:undoHDR :undoHDR :undoHDR];
        [[imp.material phongSpecularReflectivity] setValues:undoHDR :undoHDR :undoHDR];
    };
    
    setupImp(BID_LINE_ORIGIN); // Buy Line
    [bidLines addObject:imp];
    [gcLocalImps addObject:imp];
    
    impId = [world createImpersonator:@"Plane"];
    imp = [world getImpersonator:impId];
    setupImp(-BID_LINE_ORIGIN); // Sell Line
    [bidLines addObject:imp];
    [gcLocalImps addObject:imp];
    
}

// seller or buyer
- (void) commendRole
{
    
    for(int playerId = 0; playerId < 4; playerId++) {
        
        int availableUnits = [self availableUnits:playerId];
        
        if(availableUnits > 0)
            [self positionPlayer:playerId Seller:YES];
        else
            [self positionPlayer:playerId Seller:NO];
    }
    
    
}

// setup the clock imps
- (void) showSunClock
{
    YAImpersonator* sunImp = impCollector.sunImp;
    YAImpersonator* sunCoverImp = impCollector.sunCoverImp;
    YAImpersonator* stickSunImp = impCollector.stickSunImp;
    
    const float sunHeight = 3.0;
    const float sunXPos = -5.2;
    const float thingyDim = -0.5;
    
    [[sunImp translation] setValues:thingyDim :sunHeight :sunXPos];
    [[sunCoverImp translation] setValues:thingyDim :sunHeight :sunXPos];
    [[stickSunImp translation] setValues:thingyDim :sunHeight + 1.105 :sunXPos];
    
    [[sunCoverImp rotation] setY:100];
    [[stickSunImp rotation] setY:100];
    
    sunImp.visible = YES;
    sunCoverImp.visible = YES;
    stickSunImp.visible = YES;
    
}

- (void) hideSunCLock
{
    YAImpersonator* sunImp = impCollector.sunImp;
    YAImpersonator* sunCoverImp = impCollector.sunCoverImp;
    YAImpersonator* stickSunImp = impCollector.stickSunImp;
    
    sunImp.visible = NO;
    sunCoverImp.visible = NO;
    stickSunImp.visible = NO;
}

// show text for shop prices
- (void) showShopPrices
{
    NSString* sellPriceText = [YALog decode:@"sellPrice"];
    sellPriceText = [NSString stringWithFormat:@"%@%d", sellPriceText, shopPrices.y];
    
    NSString* buyPriceText = [YALog decode:@"buyPrice"];
    buyPriceText = [NSString stringWithFormat:@"%@%d", buyPriceText, shopPrices.x];
    
    sellPriceImp = [sceneUtils genTextBlocked:sellPriceText];
    YAImpersonator* buyPriceImp = [sceneUtils genTextBlocked:buyPriceText];
    
    [sellPriceImp resize:0.10];
    [[sellPriceImp translation] setVector:[[YAVector3f alloc] initVals:sellPriceText.length * 0.5 * -0.07f :0.35 :5]];
    [[[sellPriceImp material] phongAmbientReflectivity] setVector:sceneUtils.color_dark_blue];
    sellPriceImp.material.eta = 0.2;
    
    [buyPriceImp resize:0.10];
    [[buyPriceImp translation] setVector:[[YAVector3f alloc] initVals:buyPriceText.length * 0.5 * -0.07f :-0.6 :5]];
    [[[buyPriceImp material] phongAmbientReflectivity] setVector:sceneUtils.color_dark_blue];
    buyPriceImp.material.eta = 0.2;
    
    [sceneUtils alignToCam:sellPriceImp];
    [sceneUtils alignToCam:buyPriceImp];
    
    [gcLocalImps addObject:sellPriceImp];
    [gcLocalImps addObject:buyPriceImp];
    
}

// create shop icon imp
- (void) createStoreImp
{
    int storeIconBuyID = [world createImpersonator:@"StoreIcon"];
    storeIconBuyImp = [world getImpersonator:storeIconBuyID];
    
    [[storeIconBuyImp rotation] setValues:-90 :90 :0];
    
    [[[storeIconBuyImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[storeIconBuyImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[storeIconBuyImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    
    [storeIconBuyImp resize:0.4f];
    storeIconBuyImp.translation.x = PLAYER_IMP_ORIGIN;
    
    [gcLocalImps addObject:storeIconBuyImp];
}

// simple shop price calculation
- (void) calcShopPrices
{
    
    switch (activeCommodity) {
        case COMMODITY_SMITHORE:
            shopPrices.x = store.smithoreUnitPrice;
            shopPrices.y = shopPrices.x + 35;
            break;
        case COMMODITY_ENERGY:
            shopPrices.x = store.energyUnitPrice - 15;
            shopPrices.y = shopPrices.x + 35;
            break;
        case COMMODITY_FOOD:
            shopPrices.x = store.foodUnitPrice - 15;
            shopPrices.y = shopPrices.x + 35;
            break;
        case COMMODITY_CRYSTALITE:
            shopPrices.x = store.crystaliteUnitPrice;
            shopPrices.y = shopPrices.x + 35;
            break;
        default:
            break;
    }

    // limit shop Prices
    if(shopPrices.x < 10)
        shopPrices.x = 10;
    
    if(shopPrices.y < shopPrices.x + 10)
        shopPrices.y = shopPrices.x + 10;
}

// show title for auction
- (void) createTitle: (tCommodity) material;
{
    // NSLog(@"Create Title");
    
    const int round = gameContext.round == 0 ? 1 : gameContext.round; // 0 if uninitialized
    
    NSString* title = [NSString stringWithFormat:@"%@%d", [YALog decode:@"status"], round];
    
    NSString* titleDesctiptor = nil;
    switch (material) {
        case COMMODITY_SMITHORE:
            titleDesctiptor = @"Smithore";
            break;
        case  COMMODITY_ENERGY:
            titleDesctiptor = @"Energy";
            break;
        case COMMODITY_FOOD:
            titleDesctiptor = @"Food";
            break;
        case COMMODITY_CRYSTALITE:
            titleDesctiptor = @"Crystalite";
            break;
        default:
            break;
    }
    
    NSString* subtitle = [YALog decode:titleDesctiptor];

    YAImpersonator *titleImp = [sceneUtils genTextBlocked:title];
    YAImpersonator *subTitleImp = [sceneUtils genTextBlocked:subtitle];
    
    [[[titleImp material] phongAmbientReflectivity] setVector:sceneUtils.color_yellow];
    [titleImp resize:0.20];
    [[titleImp translation] setVector:[[YAVector3f alloc] initVals:title.length * 0.5 * -0.14f :0.92 :5]];
    [[titleImp material] setEta:0.5];
    [sceneUtils alignToCam:titleImp];
    
    [[[subTitleImp material] phongAmbientReflectivity] setVector:sceneUtils.color_yellow];
    [subTitleImp resize:0.15];
    [[subTitleImp translation] setVector:[[YAVector3f alloc] initVals:subtitle.length * -0.05f :0.75 :5]];
    [[subTitleImp material] setEta:0.5];
    [sceneUtils alignToCam:subTitleImp];
    
    [gcLocalImps addObject:titleImp];
    [gcLocalImps addObject:subTitleImp];
}

// create local imps
- (void) setupLocalImps
{
    playerColorRings = [sceneUtils createPlayerColorRings:gameContext];
    playerColorBalls =[sceneUtils createPlayerColorBalls:gameContext];
    playerColorBars  = [sceneUtils createPlayerColorChart:gameContext];
    
    for(YAImpersonator* imp in playerColorRings)
        [gcLocalImps addObject:imp];
    
    for(YAImpersonator* imp in playerColorBalls)
        [gcLocalImps addObject:imp];
    
    for(YAImpersonator* imp in playerColorBars)
        [gcLocalImps addObject:imp];
    
    for(YAImpersonator* imp in playerColorBalls) {
        [imp resize:0.8];
        [[imp translation] setValues:0 :1.5 :0];
        [imp setVisible:false];
    }
}

// gc local imps
-(void) shutDownLocalImps
{
    for(YAImpersonator* imp in gcLocalImps) {
        [sceneUtils removeImp:imp atTime:0];
    }
}

// get neccessary vars from scene-graph
-(void) setupGlobals: (NSDictionary*) info
{
    impCollector = [info objectForKey:@"IMPCOLLECTOR"];
    gameContext = [info objectForKey:@"GAMECONTEXT"];
    sceneUtils = [info objectForKey:@"SCENEUTILS"];
    world = [info objectForKey:@"WORLD"];
    colonyMap = [info objectForKey:@"COLONYMAP"];
    soundCollector = [info objectForKey:@"SOUNDCOLLECTOR"];
    store = [info objectForKey:@"STORE"];
}

// setup board for auction
- (float) cleanBoard: (bool) clean
{
    float myTime = 0;
    YAImpersonator* terrainImp = impCollector.terrainImp;
    YAImpersonator* boardTitleImp = impCollector.boardTitleImp;
    YAImpersonator* boardImp = impCollector.boardTitleImp;
    
    if(clean) {
        [colonyMap hideImps:0];
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
        
        myTime += 0.71;
        
        [sceneUtils hideImp:boardImp atTime:myTime];
        [sceneUtils hideImp:terrainImp atTime:myTime];
        [sceneUtils showImp:boardTitleImp atTime:myTime];
        
        
    } else {
        
        [sceneUtils showImp:boardImp atTime:myTime];
        [sceneUtils showImp:terrainImp atTime:myTime];
        [sceneUtils hideImp:boardTitleImp atTime:myTime];
        
        YAInterpolationAnimator* ipo = [world createInterpolationAnimator];
        [ipo setDelay:myTime];
        [ipo addIpo:[[YAVector3f alloc] initVals:127.0 / 102.0 :108.0 / 98.0 :59.0 / 36.0]  timeFrame:0.0f];
        [ipo addIpo:[[YAVector3f alloc] initVals:0.6 :0.6 :0.6]  timeFrame:0.7f];
        [ipo addListener:[[terrainImp material] phongAmbientReflectivity]];
        
        YABlockAnimator* anim = [world createBlockAnimator];
        [anim setOnce:true];
        [anim setInterval:0.7];
        [anim setProgress:damp];
        [anim setDelay:myTime];
        [anim addListener:^(float sp, NSNumber *event, int message) {
            [terrainImp setNormalMapFactor:sp];
        }];
        
        myTime += 0.7;
        [colonyMap showImps:myTime];
    }
    
    return myTime;
}

//
-(void) showChartBars
{
    
    YAChronograph* chronograph = [[YAChronograph alloc] init];
    const float defaultWait = 2.0f;
    const float additionalWait = 1.0f;
    const bool withUsageSpoilage = (gameContext.gameDifficulty != 0) && ((activeCommodity == COMMODITY_FOOD) || (activeCommodity == COMMODITY_ENERGY));
    
    __block bool animFinished = NO;
    
    void (^waitForAnim)(void) = ^(void) {
        do {
            [chronograph wait:0.2f];
        } while (!animFinished);
        
        animFinished = false;
        [self updateCommodityUnits]; //WARNING: Side effect
        [chronograph wait:additionalWait];
        
    };
    
    const float chartMax = fmaxf([self maxPossession], DEFAULT_CHART_MAX);
    
    
    for(int playerId = 0; playerId < 4; playerId++) {
        
        YAImpersonator* playerColorBarImp = [playerColorBars objectAtIndex:playerId];
        
        playerColorBarImp.visible = YES;
        
        [[playerColorBarImp translation] setZ: PLAYER_IMP_ORIGIN + 3.3f * playerId];
        [[playerColorBarImp translation] setY: 0.05];
        [[playerColorBarImp translation] setX: PLAYER_IMP_ORIGIN * -1 - 4];
        
        [[playerColorBarImp rotation] setValues:-90 :-90 :0];
        [playerColorBarImp resize:0.7];
        playerColorBarImp.size.z = DEFAULT_CHART_MIN_RANGE;
    }
    
    [soundCollector playForImp:impCollector.deskImp Sound:[soundCollector getSoundId:@"LaserA"]];
    
    NSString* chartLegend = [YALog decode:@"previousAmount"];
    __block YAImpersonator* textImp = [sceneUtils genTextBlocked:chartLegend];
    [textImp resize:0.20];
    [[textImp translation] setVector:[[YAVector3f alloc] initVals:chartLegend.length * 0.5 * -0.14f :0 :5]];
    [[textImp material] setEta:0.5];
    [sceneUtils alignToCam:textImp];
    
    YABlockAnimator* anim = [world createBlockAnimator];
    __weak YABlockAnimator* animW = anim;
    anim.asyncProcessing = NO;
    anim.once = YES;
    anim.onceReset = NO;
    anim.interval = defaultWait;
    anim.progress = PROGRESS_ACCELERATE_DECELERATE;
    [anim addListener:^(float sp, NSNumber *event, int message) {
        for (int playerId = 0; playerId < 4; playerId++) {
            YAImpersonator* playerColorBarImp = [playerColorBars objectAtIndex:playerId];
            float mySize = (float)[self calculatePosseession:playerId] / (float)chartMax;
            mySize = DEFAULT_CHART_MAX_RANGE * mySize * sp;
            if(mySize < DEFAULT_CHART_MIN_RANGE)
                mySize = DEFAULT_CHART_MIN_RANGE;
            playerColorBarImp.size.z = mySize;
        }
        
        if(animW.deleteme) {
            [sceneUtils removeImp:textImp atTime:0];
            animFinished = YES;
        }
        
    }];
    
    waitForAnim();
    
    // two additional stages usage and spilage
    if(withUsageSpoilage) {
        
        __block NSMutableArray* commodityUsage = [[NSMutableArray alloc] init];
        __block NSMutableArray* commoditySpoilage = [[NSMutableArray alloc] init];
        
        for(int playerId = 0; playerId < 4; playerId++) {
            int usage = 0;
            int spoilage = 0;
            
            //usage calculation
            if(activeCommodity == COMMODITY_FOOD) {
                if(gameContext.round <= 4)
                    usage = 3;
                else if(gameContext.round <= 8)
                    usage = 4;
                else
                    usage = 5;
            } else if (activeCommodity == COMMODITY_ENERGY) {
                NSArray* plots = [colonyMap getAllPlots:playerId];
                
                for(YAVector2i* plot in plots) {
                    house_type house = [colonyMap plotHouseAtX:plot.x Z:plot.y];
                    if(house != HOUSE_ENERGY && house != HOUSE_NONE)
                        usage++;
                }
            }
            
            //spoilage calculation
            if(activeCommodity == COMMODITY_FOOD) {
                spoilage = (int)floorf( (float)([self calculatePosseession:playerId] - usage) * .5f);
            } else if (activeCommodity == COMMODITY_ENERGY) {
                spoilage = (int)floorf( (float)([self calculatePosseession:playerId] - usage) * .75f);
            }
            
            [commodityUsage addObject:[NSNumber numberWithInt:usage]];
            [commoditySpoilage addObject:[NSNumber numberWithInt:spoilage]];
        }
        
        // show usage
        [soundCollector playForImp:impCollector.deskImp Sound:[soundCollector getSoundId:@"LaserC"]];

        chartLegend = [YALog decode:@"actualUsage"];
        
        textImp = [sceneUtils genTextBlocked:chartLegend]; // destroyed in previous step
        [textImp resize:0.20];
        [[textImp translation] setVector:[[YAVector3f alloc] initVals:chartLegend.length * 0.5 * -0.14f :0 :5]];
        [[textImp material] setEta:0.5];
        [sceneUtils alignToCam:textImp];
        
        anim = [world createBlockAnimator];
        animW = anim;
        anim.asyncProcessing = NO;
        anim.once = YES;
        anim.onceReset = NO;
        anim.interval = defaultWait;
        anim.progress = PROGRESS_ACCELERATE_DECELERATE;
        [anim addListener:^(float sp, NSNumber *event, int message) {
            for (int playerId = 0; playerId < 4; playerId++) {
                
                YAImpersonator* playerColorBarImp = [playerColorBars objectAtIndex:playerId];
                
                float mySize = (float)[self calculatePosseession:playerId] / (float)chartMax;
                mySize = DEFAULT_CHART_MAX_RANGE * mySize;
                
                float actualUsage = (float)[[commodityUsage objectAtIndex:playerId] intValue] / (float)chartMax;
                actualUsage = DEFAULT_CHART_MAX_RANGE * actualUsage;
                
                float result = mySize - actualUsage * sp;
                
                if(result < DEFAULT_CHART_MIN_RANGE)
                    result = DEFAULT_CHART_MIN_RANGE;
                
                playerColorBarImp.size.z = result;
            }
            
            if(animW.deleteme) {
                [sceneUtils removeImp:textImp atTime:0];
                
                for(int playerId = 0; playerId < 4; playerId++) {
                    [self changeAccountedUnits: -1 * [[commodityUsage objectAtIndex:playerId] intValue] Player:playerId];
                }
                
                animFinished = YES;
            }
        }];
        
        waitForAnim();
        
        // show spoilage
        [soundCollector playForImp:impCollector.deskImp Sound:[soundCollector getSoundId:@"LaserC"]];

        chartLegend = [YALog decode:@"actualSpoilage"];
        textImp = [sceneUtils genTextBlocked:chartLegend]; // destroyed in previous step
        [textImp resize:0.20];
        [[textImp translation] setVector:[[YAVector3f alloc] initVals:chartLegend.length * 0.5 * -0.14f :0 :5]];
        [[textImp material] setEta:0.5];
        [sceneUtils alignToCam:textImp];
        
        anim = [world createBlockAnimator];
        animW = anim;
        anim.asyncProcessing = NO;
        anim.once = YES;
        anim.onceReset = NO;
        anim.interval = defaultWait;
        anim.progress = PROGRESS_ACCELERATE_DECELERATE;
        [anim addListener:^(float sp, NSNumber *event, int message) {
            for (int playerId = 0; playerId < 4; playerId++) {
                
                YAImpersonator* playerColorBarImp = [playerColorBars objectAtIndex:playerId];
                
                float mySize = (float)[self calculatePosseession:playerId] / (float)chartMax;
                mySize = DEFAULT_CHART_MAX_RANGE * mySize;
                
                float actualSpoilage = (float)[[commoditySpoilage objectAtIndex:playerId] intValue] / (float)chartMax;
                actualSpoilage = DEFAULT_CHART_MAX_RANGE * actualSpoilage;
                
                float result = mySize - actualSpoilage * sp;
                
                if(result < DEFAULT_CHART_MIN_RANGE)
                    result = DEFAULT_CHART_MIN_RANGE;
                
                playerColorBarImp.size.z = result;
            }
            
            if(animW.deleteme) {
                [sceneUtils removeImp:textImp atTime:0];
                
                for(int playerId = 0; playerId < 4; playerId++) {
                    [self changeAccountedUnits: -1 * [[commoditySpoilage objectAtIndex:playerId] intValue] Player:playerId];
                }
                
                animFinished = YES;
            }
        }];
        
        waitForAnim();
        
    }
    
    chartLegend = [YALog decode:@"actualProduction"];
    textImp = [sceneUtils genTextBlocked:chartLegend]; // destroyed in previous step
    [textImp resize:0.20];
    [[textImp translation] setVector:[[YAVector3f alloc] initVals:chartLegend.length * 0.5 * -0.14f :0 :5]];
    [[textImp material] setEta:0.5];
    [sceneUtils alignToCam:textImp];
    
    [soundCollector playForImp:impCollector.deskImp Sound:[soundCollector getSoundId:@"LaserC"]];
    
    anim = [world createBlockAnimator];
    animW = anim;
    anim.asyncProcessing = NO;
    anim.once = YES;
    anim.onceReset = NO;
    anim.interval = defaultWait;
    anim.progress = PROGRESS_ACCELERATE_DECELERATE;
    [anim addListener:^(float sp, NSNumber *event, int message) {
        for (int playerId = 0; playerId < 4; playerId++) {
            YAImpersonator* playerColorBarImp = [playerColorBars objectAtIndex:playerId];
            float mySize = (float)[self calculatePosseession:playerId] / (float)chartMax;
            mySize = DEFAULT_CHART_MAX_RANGE * mySize;
            if(mySize < DEFAULT_CHART_MIN_RANGE)
                mySize = DEFAULT_CHART_MIN_RANGE;
            
            float actualProduction = (float)[self producedCommodities:playerId] / (float)chartMax;
            playerColorBarImp.size.z = mySize + actualProduction * sp * 2;
        }
        
        if(animW.deleteme) {
            [sceneUtils removeImp:textImp atTime:0];
            
            [self moveProductionToAccout]; // WARNING: side effect
            
            animFinished = YES;
        }
        
    }];
    
    waitForAnim();
    
    // Display shortage or surplus for food and energy
    if(withUsageSpoilage) {
        
        [soundCollector playForImp:impCollector.deskImp Sound:[soundCollector getSoundId:@"LaserB"]];

        
        shortageMargins = [[NSMutableArray alloc] init];
        shortageMarginsValues = [[NSMutableArray alloc] init];
        
        
        for(int playerId = 0; playerId < 4; playerId++) {
            int impId = [world createImpersonator:@"Plane"];
            YAImpersonator* imp = [world getImpersonator:impId];
            [[imp rotation] setValues:-90 :0 :0];
            
            [imp resize:0.76f];
            
            [[imp translation] setZ: PLAYER_IMP_ORIGIN + 3.3f * playerId];
            [[imp translation] setY: 0.0];
            [[imp translation] setX: PLAYER_IMP_ORIGIN * -1 - 4];
            
            if([self availableUnits:playerId] >= 0)
                [[[imp material] phongAmbientReflectivity] setVector:sceneUtils.color_black];
            else
                [[[imp material] phongAmbientReflectivity] setVector:sceneUtils.color_red];
            
            [[[imp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.0f : 0.0f : 0.0f ]];
            [[[imp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.0f : 0.0f : 0.0f ]];
            imp.material.eta = 0;
            
            [shortageMargins addObject:imp];
            [gcLocalImps addObject:imp];

            int available = [self availableUnits:playerId];
            
            NSString* availableText;
            
            if(available >= 0)
                availableText = [YALog decode:@"surplus"];
            else
                availableText = [YALog decode:@"shortage"];
            
            availableText = [NSString stringWithFormat:@"%@%d", availableText, abs(available)];
            YAImpersonator* textImp = [sceneUtils genTextBlocked:availableText];
            
            [textImp resize:0.08];
            textImp.material.eta = 0.0;
            [[textImp translation] setVector:[[YAVector3f alloc] initVals:-1.75 + (0.96 * playerId) :-0.3 :5]];
            
            if(available < 0)
                [[[textImp material] phongAmbientReflectivity] setVector:sceneUtils.color_red];
            else
                [[[textImp material] phongAmbientReflectivity] setVector:sceneUtils.color_green];
            
            [sceneUtils alignToCam:textImp];
            
            [shortageMarginsValues addObject:textImp];
            [gcLocalImps addObject:textImp];
        }
        
        anim = [world createBlockAnimator];
        animW = anim;
        anim.asyncProcessing = NO;
        anim.once = YES;
        anim.onceReset = NO;
        anim.interval = defaultWait * 0.5f;
        anim.progress = PROGRESS_ACCELERATE_DECELERATE;
        [anim addListener:^(float sp, NSNumber *event, int message) {
            
            for (int playerId = 0; playerId < 4; playerId++) {
                
                YAImpersonator* marginImp = [shortageMargins objectAtIndex:playerId];
                
                float myHeight = ((float)[self calculatePosseession:playerId] - (float)[self availableUnits:playerId] ) / (float)chartMax;

                myHeight = DEFAULT_CHART_MAX_RANGE * myHeight * sp * 2 + 0.08;
                if(myHeight < DEFAULT_CHART_MIN_RANGE)
                    myHeight = DEFAULT_CHART_MIN_RANGE;
                
                marginImp.translation.y = myHeight;
                marginImp.rotation.y = sp * 360;
            }
            
            if(animW.deleteme) {
                [sceneUtils removeImp:textImp atTime:0];
                animFinished = YES;
            }
        }];
        
        waitForAnim();
    }
}

// show and position meeples
-(void) setupMeeple
{
    for(int playerId = 0; playerId < 4; playerId++) {
        YAAlienRace* ar = [[gameContext playerGameData]objectAtIndex:playerId];
        YAImpersonator* imp = ar.impersonator;

        imp.visible = YES;
        [ar sizeSmall];
        
        [[imp translation] setZ: PLAYER_IMP_ORIGIN + 3.3f * playerId];
        [[imp translation] setY: 0.1];
        [[imp translation] setX: PLAYER_IMP_ORIGIN * -1];
        
        imp.useQuaternionRotation = NO;
        [[imp rotation] setY: -90];
        
        YAImpersonator* colorRingImp = [playerColorRings objectAtIndex:playerId];
        [[colorRingImp translation] setZ: PLAYER_IMP_ORIGIN + 3.3f * playerId];
        [[colorRingImp translation] setY: 0.1];
        [[colorRingImp translation] setX: 5];
        [[colorRingImp rotation] setX: -90];
        [colorRingImp resize:0.65];
        colorRingImp.visible = YES;
        
        int score = [[[gameContext playerGameData] objectAtIndex:playerId] money];
        YAImpersonator* scoreImp = [sceneUtils genTextBlocked:[NSString stringWithFormat:@"%4d", score]];
        
        [gcLocalImps addObject:scoreImp];
        [moneyTextImps addObject:scoreImp];
        
        [scoreImp resize:0.15];
        [[scoreImp translation] setVector:[[YAVector3f alloc] initVals:-1.95 + (1.16 * playerId) :-1.09 :5]];
        [[[scoreImp material] phongAmbientReflectivity] setVector:sceneUtils.color_yellow];
        [sceneUtils alignToCam:scoreImp];
    }
}

#pragma mark -

// recommandation for buyer seller position dependedn on surplus
- (void) positionPlayer: (int) playerId Seller: (bool) isSeller
{
    YAAlienRace* player = [gameContext playerDataForId:playerId];
    YAImpersonator* imp = player.impersonator;
    
    YAImpersonator* colorRingImp = [playerColorRings objectAtIndex:playerId];
    
    if(isSeller) {
        [isPlayerSeller replaceObjectAtIndex:playerId withObject:@YES];
        [[imp rotation] setY: 90];
        [[imp translation] setX: PLAYER_IMP_ORIGIN ];
        [[colorRingImp translation] setX: -5];
    } else {
        [isPlayerSeller replaceObjectAtIndex:playerId withObject:@NO];
        [[imp rotation] setY: -90];
        [[imp translation] setX: PLAYER_IMP_ORIGIN * -1];
        [[colorRingImp translation] setX: 5];
    }
    
}

// + units = available - units missing for next turn
- (int) availableUnits: (int) playerId
{
    int commodities = [self calculatePosseession:playerId];
    
    if (activeCommodity == COMMODITY_ENERGY) {
        int neccessaryUnits = 0;
        
        if(gameContext.round < 12) {
            NSArray* playerPlots = [colonyMap getAllPlots:playerId];
            
            for(YAVector2i* plot in playerPlots) {
                house_type house = [colonyMap plotHouseAtX:plot.x Z:plot.y];
                if(house == HOUSE_CRYSTALYTE || house == HOUSE_FARM || house == HOUSE_SMITHORE)
                    neccessaryUnits += 1;
            }
        }

        commodities -= neccessaryUnits;
        
    } else if (activeCommodity == COMMODITY_FOOD) {
        int neccessaryUnits = 0;
        
        if(gameContext.round <= 3)
            neccessaryUnits = 3;
        else if(gameContext.round <= 7)
            neccessaryUnits = 4;
        else if(gameContext.round <= 11)
            neccessaryUnits = 5;
        
        commodities -= neccessaryUnits;
    }
    
    return commodities;
}

- (int) availableMoney: (int) playerId
{
    YAAlienRace* player = [gameContext.playerGameData objectAtIndex:playerId];
    return player.money;
}

- (int) updateMoney: (int) playerId Money: (int) money;
{
    YAAlienRace* player = [gameContext.playerGameData objectAtIndex:playerId];
    player.money = player.money + money;
    return player.money;
}

// someone uses a mouse
- (void) showOptionalMouseCursor
{
    for(int playerId = 0; playerId < 4; playerId++) {
        
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
            
            [gcLocalImps addObject:cursorUpImp];
            
            int cursorDownImpId =[world createImpersonator:@"csArrow"];
            cursorDownImp = [world getImpersonator:cursorDownImpId];
            [[cursorDownImp rotation] setX: 90];
            [[cursorDownImp rotation] setY: 90];
            [[cursorDownImp size] setZ:0.2];
            [[cursorDownImp size] setX:0.8];
            [[cursorDownImp size] setY:0.9];
            [[cursorDownImp translation] setValues:-2.433331 :0.01 : 7];
            [cursorDownImp setClickable:true];
            
            [gcLocalImps addObject:cursorDownImp];
            
        }
        
        
    }
    
}

// aggregate the production for a commodity per player
- (int) producedCommodities: (int) playerId
{
    int result = 0;
    
    NSArray* plots = [colonyMap getAllPlots:playerId];
    for(YAVector2i* plot in plots) {
        
        house_type house = [colonyMap plotHouseAtX:plot.x Z:plot.y];
        
        if(
           (activeCommodity == COMMODITY_SMITHORE && house == HOUSE_SMITHORE) ||
           (activeCommodity == COMMODITY_FOOD && house == HOUSE_FARM) ||
           (activeCommodity == COMMODITY_ENERGY && house == HOUSE_ENERGY) ||
           (activeCommodity == COMMODITY_CRYSTALITE && house == HOUSE_CRYSTALYTE)
           )
            result += [colonyMap plotProduction:plot];
    }
    
    return result;
}

// the maxximum units one player 
- (int) maxPossession
{
    int result = 0;
    for(int playerId = 0; playerId < 4; playerId++) {
        const int possession = [self calculatePosseession: playerId];
        if(possession > result)
            result = possession + [self producedCommodities:playerId];
    }
    
    return result;
}

// return the actual commodity units in the player account
- (int) calculatePosseession: (int) playerId
{
    int result = 0;
    YAAlienRace* player = [[gameContext playerGameData]objectAtIndex:playerId];
    
    switch (activeCommodity) {
        case COMMODITY_SMITHORE:
            result = player.smithoreUnits;
            break;
        case COMMODITY_ENERGY:
            result = player.energyUnits;
            break;
        case COMMODITY_FOOD:
            result = player.foodUnits;
            break;
        case COMMODITY_CRYSTALITE:
            result = player.crystaliteUnits;
            break;
        default:
            break;
    }
    
    return result;
}

- (void) changeAccountedUnits: (int) unitCount Player: (int) playerId
{
    YAAlienRace* player = [gameContext playerDataForId:playerId];
    
    switch (activeCommodity) {
        case COMMODITY_SMITHORE:
            player.smithoreUnits += unitCount;
            break;
        case COMMODITY_FOOD:
            player.foodUnits += unitCount;
            break;
        case COMMODITY_ENERGY:
            player.energyUnits += unitCount;
            break;
        case COMMODITY_CRYSTALITE:
            player.crystaliteUnits += unitCount;
            break;
        default:
            break;
    }
}

// Depending on the active commodity the production from the colony map is moved to the player account
- (void) moveProductionToAccout
{
    for(int playerId = 0; playerId < 4; playerId++) {
        YAAlienRace* player = [gameContext playerDataForId:playerId];
        
        int production = [self producedCommodities:playerId];
        if(production < 0)
            production = 0;
        
        switch (activeCommodity) {
            case COMMODITY_SMITHORE:
                player.smithoreUnits += production;
                break;
            case COMMODITY_FOOD:
                player.foodUnits += production;
                break;
            case COMMODITY_ENERGY:
                player.energyUnits += production;
                break;
            case COMMODITY_CRYSTALITE:
                player.crystaliteUnits += production;
                break;
            default:
                break;
        }
    }
}

- (void) updatePlayerBids
{
    for(int playerId = 0; playerId < 4; playerId++) {
        
        int playerBid = [[playerBids objectAtIndex:playerId] floatValue];
        
        if(playerBid < auctionPrices.x || playerBid > auctionPrices.y)
            playerBid = 0;
        
        NSString* unitText = [NSString stringWithFormat:@"%d", playerBid];
        YAImpersonator* textImp = [playerBidTextImps objectAtIndex:playerId];
        [world updateTextIngredient:unitText Impersomator:textImp];
        
        [textImp resize:0.15];
        
        float spacing = (4 - unitText.length) * 0.112;
        
        [[textImp translation] setVector:[[YAVector3f alloc] initVals:-1.95 + (1.16 * playerId) + spacing :-0.82 :5]];
        [[textImp rotation] setVector: [[YAVector3f alloc] initVals:90: 0 : 0]];
        [[[textImp material] phongAmbientReflectivity] setVector:sceneUtils.color_dark_blue];
        [sceneUtils alignToCam:textImp];
    }
    
    
}

- (void) showPlayerBids
{
    for(int playerId = 0; playerId < 4; playerId++) {
        
        int playerBid = [[playerBids objectAtIndex:playerId] floatValue];
        
        NSString* unitText = [NSString stringWithFormat:@"%d", playerBid];
        YAImpersonator* textImp = [sceneUtils genTextBlocked:unitText];
        
        [gcLocalImps addObject:textImp]; // for cleaning
        [playerBidTextImps addObject:textImp]; // for update
        
        [textImp resize:0.15];
        
        float spacing = (4 - unitText.length) * 0.112;
        
        [[textImp translation] setVector:[[YAVector3f alloc] initVals:-1.95 + (1.16 * playerId) + spacing :-0.82 :5]];
        [[[textImp material] phongAmbientReflectivity] setVector:sceneUtils.color_dark_blue];
        [sceneUtils alignToCam:textImp];
    }
    
}

// create the unit text imps
- (void) showCommmodityUnits
{
    for(int playerId = 0; playerId < 4; playerId++) {
        
        YAAlienRace* player = [gameContext playerDataForId:playerId];
        int myUnits = 0;
        
        switch (activeCommodity) {
            case COMMODITY_SMITHORE:
                myUnits = player.smithoreUnits;
                break;
            case COMMODITY_ENERGY:
                myUnits = player.energyUnits;
                break;
            case COMMODITY_FOOD:
                myUnits = player.foodUnits;
                break;
            case COMMODITY_CRYSTALITE:
                myUnits = player.crystaliteUnits;
                break;
            default:
                break;
        }
        
        if(myUnits < 0)
            myUnits = 0;
        
        NSString* unitText = [NSString stringWithFormat:@"%d", myUnits];
        YAImpersonator* textImp = [sceneUtils genTextBlocked:unitText];
        
        [gcLocalImps addObject:textImp]; // for cleaning
        [commoditiyUnitTextImps addObject:textImp]; // for update
        
        [textImp resize:0.15];
        
        float spacing = (4 - unitText.length) * 0.112;
        
        [[textImp translation] setVector:[[YAVector3f alloc] initVals:-1.95 + (1.16 * playerId) + spacing :-0.95 :5]];
        [[[textImp material] phongAmbientReflectivity] setVector:sceneUtils.color_red];
        [sceneUtils alignToCam:textImp];
    }
    
    int storeUnits = [self storeUnits];
    
    NSString* storeUnitText = [YALog decode:@"storeUnits"];
    storeUnitText = [storeUnitText stringByReplacingOccurrencesOfString:@"_" withString:[NSString stringWithFormat:@"%d", storeUnits]];
    
    YAImpersonator* storeUnitTextImp = [sceneUtils genTextBlocked:storeUnitText];
    
    [gcLocalImps addObject:storeUnitTextImp];
    [commoditiyUnitTextImps addObject:storeUnitTextImp]; // index 4 assigned to Store
    
    [storeUnitTextImp resize:0.15];
    
    [[storeUnitTextImp translation] setVector:[[YAVector3f alloc] initVals:storeUnitText.length * 0.5 * -0.1 :0.6 :5]];
    [[[storeUnitTextImp material] phongAmbientReflectivity] setVector:sceneUtils.color_red];
    [sceneUtils alignToCam:storeUnitTextImp];
    
}

- (int) storeUnits
{
    int storeUnits = 0;
    
    switch (activeCommodity) {
        case COMMODITY_SMITHORE:
            storeUnits = store.smithoreStock;
            break;
        case COMMODITY_ENERGY:
            storeUnits = store.energyStock;
            break;
        case COMMODITY_FOOD:
            storeUnits = store.foodStock;
            break;
        case COMMODITY_CRYSTALITE:
            storeUnits = store.crystaliteStock;
            break;
        default:
            break;
    }
    
    return storeUnits;
}

-(int) changeStoreUnits: (int) amount
{
    int storeUnits = 0;
    
    switch (activeCommodity) {
        case COMMODITY_SMITHORE:
            store.smithoreStock += amount;
            storeUnits = store.smithoreStock;
            break;
        case COMMODITY_ENERGY:
            store.energyStock += amount;
            storeUnits = store.energyStock;
            break;
        case COMMODITY_FOOD:
            store.foodStock += amount;
            storeUnits = store.foodStock;
            break;
        case COMMODITY_CRYSTALITE:
            store.crystaliteStock += amount;
            storeUnits = store.crystaliteStock;
            break;
        default:
            break;
    }
    
    return storeUnits;
    
    
}

// update the unit text imps
- (void) updateCommodityUnits
{
    
    for(int playerId = 0; playerId < 4; playerId++) {
        YAAlienRace* player = [gameContext playerDataForId:playerId];
        int myUnits = 0;
        
        switch (activeCommodity) {
            case COMMODITY_SMITHORE:
                myUnits = player.smithoreUnits;
                break;
            case COMMODITY_ENERGY:
                myUnits = player.energyUnits;
                break;
            case COMMODITY_FOOD:
                myUnits = player.foodUnits;
                break;
            case COMMODITY_CRYSTALITE:
                myUnits = player.crystaliteUnits;
                break;
            default:
                break;
        }
        
        if(myUnits < 0)
            myUnits = 0;
        
        __block YAImpersonator* textImp =  [commoditiyUnitTextImps objectAtIndex:playerId];
        __block NSString* unitText = [NSString stringWithFormat:@"%d", myUnits];
        
        YABlockAnimator* anim = [world createBlockAnimator];
        anim.oneExecution = YES;
        [anim addListener:^(float sp, NSNumber *event, int message) {
            [world updateTextIngredient:unitText Impersomator:textImp];
        }];
        
        float spacing = (4 - unitText.length) * 0.112;
        
        [[textImp translation] setVector:[[YAVector3f alloc] initVals:-1.95 + (1.16 * playerId) + spacing :-0.95 :5]];
        [[textImp rotation] setVector: [[YAVector3f alloc] initVals:90: 0 : 0]];
        [[[textImp material] phongAmbientReflectivity] setVector:sceneUtils.color_red];
        [sceneUtils alignToCam:textImp];
        
    }
    
    int storeUnits = 0;
    
    switch (activeCommodity) {
        case COMMODITY_SMITHORE:
            storeUnits = store.smithoreStock;
            break;
        case COMMODITY_ENERGY:
            storeUnits = store.energyStock;
            break;
        case COMMODITY_FOOD:
            storeUnits = store.foodStock;
            break;
        case COMMODITY_CRYSTALITE:
            storeUnits = store.crystaliteStock;
            break;
        default:
            break;
    }
    
    __block NSString* storeUnitText = [YALog decode:@"storeUnits"];
    storeUnitText = [storeUnitText stringByReplacingOccurrencesOfString:@"_" withString:[NSString stringWithFormat:@"%d", storeUnits]];
    
    __block YAImpersonator* storeUnitTextImp = [commoditiyUnitTextImps objectAtIndex:4];
    
    YABlockAnimator* anim = [world createBlockAnimator];
    anim.oneExecution = YES;
    [anim addListener:^(float sp, NSNumber *event, int message) {
        [world updateTextIngredient:storeUnitText Impersomator:storeUnitTextImp];
    }];
    
}

@end
