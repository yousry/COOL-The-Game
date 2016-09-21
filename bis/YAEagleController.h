//
//  YAEagleController.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 16.10.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YAImpGroup, YABlockAnimator, YARenderLoop, YAColonyMap,
YASceneUtils, YATerrain, YABulletEngineTranslator, YAOpenAL,
YAEventChain, YAImpCollector, YASoundCollector, YAGameContext;

typedef enum
{
    EAGLE_LANDING,
    EAGLE_LANDED,
    EAGLE_STARTING,
    EAGLE_CONTROLLED,
    EAGLE_PASSIVE
} eagle_State;

@interface YAEagleController : NSObject {
@private
    float xSpeed;
    float ySpeed;
    float zSpeed;
    float turnSpeed;
    
    float xLPadPos;
    float zLPadPos;
    float xRPadPos;
    float ybPadPos;
    
    float lastSp;
    float lastCall;
    
    bool hasCargo;
    NSArray* afterburners;
    
    YABlockAnimator* eagleFly;
    YARenderLoop* _world;
    YAColonyMap* _colMap;
    YAImpersonator* _terrainImp;
    YASceneUtils* _sceneUtils;
    YATerrain* _terrain;
    YAGameContext* _gameContext;
    
    YAImpGroup* _eagleGroup;
    eagle_State state;
    
    YABulletEngineTranslator* _be;
    
    YAOpenAL* _soundHandler;
    int _soundThrustId;
    int _soundBackdrive;
    int _soundEngineId;
    
    YAEventChain* _eventChain;
    YAImpCollector* _ic;
    YASoundCollector* _sc;
    
    float _height;
}

@property (assign,readwrite) eagle_State state;


- (id) initFor: (YAImpGroup*) eagleGroup
       inWorld: (YARenderLoop*) world
     colonyMap: (YAColonyMap*) colMap
      flyAbove: (YAImpersonator*) terrainImp
     withUtils: (YASceneUtils*) sceneUtils
    forTerrain: (YATerrain*) terrain
    withPhysic: (YABulletEngineTranslator*) be
soundCollector: (YASoundCollector*) sc
    eventChain: (YAEventChain*) eventChain
  impCollector: (YAImpCollector*) ic
   gameContext: (YAGameContext*) gameContext;

- (void) fly: (bool) activate at: (float) time withPlayer: (int) activePlayer;

@end
