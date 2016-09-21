//
//  YASummaryStage.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 30.07.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YALogicState.h"
@class YARenderLoop, YAGameStateMachine, YASoundCollector;

@interface YASummaryStage : NSObject <YALogicState> {
@private
    YARenderLoop* renderLoop;
    YASoundCollector* soundCollector;
    
    YAGameStateMachine* _stateMachine;
    
    YAImpGroup* buttonStart;
    int sensorStart;
    
    
    
}

@property (assign, readwrite) bool startGameState;

- (id) initWithWorld: (YARenderLoop*) world StateMachine: (YAGameStateMachine*) stateMachine;
- (void) loadModels;
- (void) genButton: (int*)sensor group: (YAImpGroup*) button;
- (YAImpersonator*) genText: (NSString*) text;

@end
