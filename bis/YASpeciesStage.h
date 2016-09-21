//
//  YASpeciesStage.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 26.07.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YALogicState.h"
@class YARenderLoop, YAGameStateMachine, YAImpGroup, YAImpersonator, YASoundCollector;

@interface YASpeciesStage : NSObject  <YALogicState> {
@private
    YARenderLoop* renderLoop;
    YASoundCollector* soundCollector;
    YAGameStateMachine* _stateMachine;
    
    YAImpGroup* buttonStart;
    int sensorStart;
}

- (id) initWithWorld: (YARenderLoop*) world StateMachine: (YAGameStateMachine*) stateMachine;
- (void) loadModels;
- (void) genButton: (int*)sensor group: (YAImpGroup*) button;
- (YAImpersonator*) genText: (NSString*) text;

@end
