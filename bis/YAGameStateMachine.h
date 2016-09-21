//
//  YAGameStateMachine.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 22.06.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//
#import <dispatch/dispatch.h>
#import <Foundation/Foundation.h>

@class YARenderLoop, YAGameContext, YASoundCollector, YAIntroStage, YAGamepadStage, 
YAPlayerColorStage, YASpeciesStage, YASummaryStage, YAInGameStage;

@interface YAGameStateMachine : NSObject {
@private 

    dispatch_queue_t gameStages;
   
    YARenderLoop* _world;
    YAGameContext* gameContext;


    YAIntroStage* introStage;
    YAGamepadStage* gamepadStage;
    YAPlayerColorStage* playerColorStage;
    YASpeciesStage* speciesStage;
    YASummaryStage* summaryStage;
    __block YAInGameStage* inGameStage;
    
    id activeState;
}
- (id) initWithWorld: (YARenderLoop*) world;

- (void) shutdown;
- (void) startState;
- (void) nextState;
- (bool) isInGame;

@property (strong, readwrite) YASoundCollector* soundCollector;

@end
