//
//  YAInGameStage.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 03.04.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YALogicState.h"
@class YAGameStateMachine, YARenderLoop, YAColonyMap, YAPlotAuction, YABulletEngineTranslator,
YABulletEngineTranslator, YAImpCollector, YAInfoEvents, YAMoonClockEvent, YAMainEvents,
YAEventChain, YAMapEvents, YAEagleFlightEvents, YAShopEvent, YADevelopmentEvent,
YASocketEvents, YAProductionEvent, YACounterEvent, YASoundCollector, YATerrain,
YASceneUtils, YAMapManagement, YABasicAnimator, YABlockAnimator, YAStore;

@interface YAInGameStage : NSObject <YALogicState> {
@private
    YARenderLoop* renderLoop;
    YAGameStateMachine* stateMachine;
    
    YAImpersonator *terrainImp, *cursorInnerImp, *cursorOuterImp, *moonImp, *sunImp,
    *sunCoverImp, *deskImp, *boardImp, *boardTitleImp ,*spaceShipImp,
    *barrackImp, *planeImp, *coffeeCupImp, *tableImp, *wallImp,
    *bookshelfImp, *booksLevelAImp, *booksLevelBImp, *booksLevelCImp, *MagAImp,
    *MagBImp, *PosterSharksImp, *PosterSuperManImp, *LedgeImp, *parachuteImp,
    *podImp, *shadowCupImp, *shadowDeskImp, *shadowPlayBoardImp, *shadowTableImp,
    *stickSunImp, *stickMoonImp, *cloudNormalImp, *cloudLightningImp, *meteoridImp,
    *fireImp;
    
    YATerrain* terrain;
    float seed;
    
    YASceneUtils* sceneUtils;
    
    YAMapManagement* mapManagement;
    YAPlotAuction* plotAuction;
    
    __block YAColonyMap* colMap;
    
    YABasicAnimator *rotCover, *rotSun, *rotMoon;
    YABlockAnimator* solarRot;
    
    NSMutableArray* starImps;
    
    YAStore* _store;
    
    YASoundCollector* _soundCollector;
    
    __block YABulletEngineTranslator* be;
    
    YAImpCollector* _ic;
    YAMainEvents* _mainEvents;
    YAMoonClockEvent* _moonClockEvent;
    YAInfoEvents* _infoEvents;
    YAMapEvents* _mapEvents;
    __block volatile YAEagleFlightEvents* _eagleFlightEvent;
    YAShopEvent* _shopEvent;
    YACounterEvent* _counterEvent;
    YASocketEvents* _socketEvents;
    YADevelopmentEvent* _developmentEvent;
    YAProductionEvent* _productionEvent;
    YAEventChain* _eventChain;
    NSArray* _ropeSegments;
}

- (id) initWithWorld: (YARenderLoop*) world StateMachine: (YAGameStateMachine*) stateMachine;

@end
