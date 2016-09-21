//
//  YAStore.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 03.05.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "YABulletEngineCollisionProtocol.h"
#import "YAImpersonatorMover.h"

@class YARenderLoop, YAImpGroup, YASceneUtils, YAColonyMap, YAGameContext, YABulletEngineTranslator, YAImpGroup;
@class YAOpenAL;
@class YADromedarMover;
@class YABlockAnimator;
@class YAAlienRace;
@class YAEventChain;
@class YASoundCollector;
@class YAVector3f;

typedef enum {
    COMISSION_NONE = -1,
    COMISSION_LAND = 0,
    COMISSION_ASSAY = 1
} comission_type;

@interface YAStore : NSObject <YABulletEngineCollisionProtocol> {

@private
    YARenderLoop* _world;
    YASceneUtils* _sceneUtils;
    YAColonyMap* _colonyMap;
    YAGameContext* _gameContext;
    YABulletEngineTranslator* _be;
    YAImpersonator *_shopSocket, *_shopPlaceSign;
    
    int _player;
    int maxCamels;
    
    bool camelBought;
    bool crystaliteBought;
    bool smithoreBought;
    bool energyBought;
    bool farmBought;

    YAImpersonator* dromedarImp;
    YADromedarMover* dm;

    YAImpersonator *meeple;
    YABlockAnimator* followMeeple;
    YABlockAnimator* _moveAlien;
    id<YAImpersonatorMover> _animator;
    
    
    YAImpersonator *crystaliteImp, *smithoreImp, *energyImp, *farmImp;
    
    YAImpersonator *camelTable, *pubTable, *assayTable, *landTable;
    
    YAImpersonator* shopSignText;
    NSString* actualShopSignText;
    
    
    YAAlienRace* arPlayer;
    
    YAEventChain* _eventChain;
    
    NSMutableArray* _localPhysicImps;
    NSArray* _playerColorRings;
    
    YAVector3f* _screenCoords;
    YAVector3f* _lastValidCoords;
    
    __weak YAImpersonator *doorImp, *crystaliteBoardImp, *smithoreBoardImp, *energyBoardImp, *farmBoardImp, *eagleImp;
}

- (id) initInWorld: (YARenderLoop*) world
             utils: (YASceneUtils*) sceneUtils
            colony: (YAColonyMap*) colonyMap
       gameContext: (YAGameContext*) gameContext
        eventChain: (YAEventChain*) eventChain;

- (void) setEnvironment: (YABulletEngineTranslator*) be;

- (float) showShopAt: (float) startTime;
- (float) activatePodDoor: (float) startTime;
- (void) goShoppingWith: (int) player;

- (void) updatePrices;
- (void) produceCamels;

@property (weak, readwrite) YASoundCollector* soundCollector;

@property (assign, readwrite) int crystaliteFabPrice;
@property (assign, readwrite) int smithoreFabPrice;
@property (assign, readwrite) int energyFabPrice;
@property (assign, readwrite) int farmFabPrice;
@property (assign, readwrite) int camelPrice;
@property (assign, readwrite) int assayPrice;

@property (assign, readwrite) int camelsAvailable;

@property (assign, readwrite) int crystaliteUnitPrice;
@property (assign, readwrite) int smithoreUnitPrice;
@property (assign, readwrite) int energyUnitPrice;
@property (assign, readwrite) int foodUnitPrice;

@property (assign, readwrite) int plotUnitPriceEmpty;
@property (assign, readwrite) int plotUnitPriceDeveloped;

@property (assign, readwrite) int foodStock;
@property (assign, readwrite) int energyStock;
@property (assign, readwrite) int smithoreStock;
@property (assign, readwrite) int crystaliteStock;


// value shared between events
@property (assign, readwrite) int lastPurchase;
@property (assign, readwrite) comission_type comission;


// collison detection must be established after setup
@property (strong, readwrite) NSMutableArray* contactImps;

@property(assign, readwrite) bool gambling;

@end
