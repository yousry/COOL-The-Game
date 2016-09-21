//
//  YAIntroStage.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 19.06.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YALogicState.h"

@class YARenderLoop, YAGameContext, YAImpGroup, YASoundCollector, YAOpenAL;
@class YAGameStateMachine, YAImpGroup, YAImpersonator, YASoundCollector;

@interface YAIntroStage : NSObject <YALogicState> {
    YASoundCollector* soundCollector;
    YAOpenAL* al;
	YARenderLoop* renderLoop;
	YAGameStateMachine* stateMachine;

    YAImpGroup *buttonStart, *buttonDifficulty, *buttonNumberOfPlayer; 
    int sensorStart, sensorDifficulty, sensorNumPlayer;
}

- (id) initWithWorld: (YARenderLoop*) world StateMachine: (YAGameStateMachine*) stateMachine;


- (void) loadModels;
- (void) genButton: (int*)sensor group: (YAImpGroup*) button;
- (YAImpersonator*) genText: (NSString*) text;

@end
