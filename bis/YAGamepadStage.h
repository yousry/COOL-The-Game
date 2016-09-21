//
//  YAGamepadStage.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 23.07.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YALogicState.h"
@class YARenderLoop, YAGameStateMachine, YAImpGroup, YAImpersonator, YASoundCollector;

@interface YAGamepadStage : NSObject <YALogicState> {
@private
    YARenderLoop* renderLoop;
    YASoundCollector* soundCollector;
    YAGameStateMachine* _stateMachine;
}

- (id) initWithWorld: (YARenderLoop*) world StateMachine: (YAGameStateMachine*) stateMachine;
- (YAImpersonator*) genText: (NSString*) text;
- (void) loadModels;

@property bool restartGame;

@end
