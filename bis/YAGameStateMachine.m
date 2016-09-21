//
//  YAGameStateMachine.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 22.06.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//


#import "YAIntroStage.h"
#import "YAGamepadStage.h"
#import "YAPlayerColorStage.h"
#import "YASpeciesStage.h"
#import "YASummaryStage.h"
#import "YAInGameStage.h"

#import "YARenderLoop.h"
#import "YAGameContext.h"
#import "YAGameStateMachine.h"

@implementation YAGameStateMachine

dispatch_queue_t setupGameStageQueue();
void shutdownGameStageQueue (void *context);

- (id) initWithWorld: (YARenderLoop*) world {
    self = [super init];
    
    if(self) {
        _world = world;
        gameContext =[[YAGameContext alloc] init];
        gameStages = setupGameStageQueue();
    }
    
    return self;
    
}

- (void) startState
{
    
    introStage = [[YAIntroStage alloc] initWithWorld:_world StateMachine:self]; 
    activeState = introStage;
    
    // NSLog(@"Try to start dispatch.");
    dispatch_async(gameStages, ^{
        // NSLog(@"In dispatch.");
        [introStage setGameContext:gameContext];
        [introStage setupScene];
    });
    
    
   // gamepadStage = [[YAGamepadStage alloc] initWithWorld:_world StateMachine:self];
   // activeState = gamepadStage;
   
   // [gameContext setGameDifficulty:0];
   // [gameContext setPlayerNumber:2];
   
   // dispatch_async(gameStages, ^{
   //     [gamepadStage setGameContext:gameContext];
   //     [gamepadStage setupScene];
   // });

//    playerColorStage = [[YAPlayerColorStage alloc] initWithWorld:_world StateMachine:self];
//    activeState = playerColorStage;
//
//    // Mockup
//    [gameContext setGameDifficulty:0];
//    [gameContext setPlayerNumber:2];
//    [gameContext setDeviceId:100 forPlayer:0];
//    [gameContext setDeviceId:1000 forPlayer:1];
//
//    dispatch_async(gameStages, ^{
//        [playerColorStage setGameContext:gameContext];
//        [playerColorStage setupScene];
//    });
    
//    speciesStage = [[YASpeciesStage alloc] initWithWorld:_world StateMachine:self];
//    activeState = speciesStage;
//    
//    // Mockup
//    [gameContext setGameDifficulty:0];
//    [gameContext setPlayerNumber:2];
//    [gameContext setDeviceId:100 forPlayer:0];
//    [gameContext setDeviceId:1000 forPlayer:1];
//    [gameContext setColor:0 forPlayer:0];
//    [gameContext setColor:1 forPlayer:1];
//    [gameContext setColor:2 forPlayer:2]; // bots
//    [gameContext setColor:3 forPlayer:3];
//    
//    
//    dispatch_async(gameStages, ^{
//        [speciesStage setGameContext:gameContext];
//        [speciesStage setupScene];
//    });


//    summaryStage = [[YASummaryStage alloc] initWithWorld:_world StateMachine:self];
//    activeState = summaryStage;
//    
//    // Mockup
//    [gameContext setPlayerNumber:2];
//    [gameContext setDeviceId:100 forPlayer:0]; // player 0 plays mouse
//    [gameContext setDeviceId:1000 forPlayer:1]; // player 1 player rumblePad
//    
//    [gameContext setColor:4 forPlayer:0];
//    [gameContext setColor:1 forPlayer:1];
//    [gameContext setColor:2 forPlayer:2]; // Bot
//    [gameContext setColor:3 forPlayer:3]; // Bot
//    
//    [gameContext setSpecies:@"Humanoid" forPlayer:0];
//    [gameContext setSpecies:@"Gollumer" forPlayer:1];
//
//    
//    dispatch_async(gameStages, ^{
//        [summaryStage setGameContext:gameContext];
//        [summaryStage setupScene];
//    });

    
   // inGameStage = [[YAInGameStage alloc] initWithWorld:_world StateMachine:self];
   // activeState = inGameStage;
   
   // // Mockup
   // gameContext.gameDifficulty = 2; // Tournament

   // // [gameContext setPlayerNumber:0];

   // [gameContext setPlayerNumber:1];
   // [gameContext setDeviceId:1000 forPlayer:0];
   // [gameContext setSpecies:@"Gollumer" forPlayer:0];


   // [gameContext setColor:0 forPlayer:0];
   // [gameContext setColor:1 forPlayer:1];
   // [gameContext setColor:2 forPlayer:2]; // Bot
   // [gameContext setColor:3 forPlayer:3]; // Bot

   // dispatch_async(gameStages, ^{
   //     [inGameStage setGameContext:gameContext];
   //     [inGameStage setupScene];
   // });

}

- (void) nextState
{
    // NSLog(@"---------------------------- nextStage ----------------------");
    // NSLog(@"%@",gameContext);

    if(activeState == introStage) {
        [introStage clearScene];
        gamepadStage = [[YAGamepadStage alloc] initWithWorld:_world StateMachine:self];
        
        dispatch_async(gameStages, ^{
            [gamepadStage setGameContext:gameContext];
            [gamepadStage setupScene];
        });
        
        activeState = gamepadStage;
        
    }   else if(activeState == gamepadStage) {
        [gamepadStage clearScene];
        
        if(!gamepadStage.restartGame) {
            playerColorStage = [[YAPlayerColorStage alloc] initWithWorld:_world StateMachine:self];
            activeState = playerColorStage;
            
            dispatch_async(gameStages, ^{
                [playerColorStage setGameContext:gameContext];
                [playerColorStage setupScene];
            });

        }  else {
            activeState = introStage;
            
            dispatch_async(gameStages, ^{
                [introStage setGameContext:gameContext];
                [introStage setupScene];
            });
        }
     }  else if(activeState == playerColorStage) {

        [playerColorStage clearScene];
        speciesStage = [[YASpeciesStage alloc] initWithWorld:_world StateMachine:self];
        activeState = speciesStage;

        dispatch_async(gameStages, ^{
            [speciesStage setGameContext:gameContext];
            [speciesStage setupScene];
        });
    } else if(activeState == speciesStage) {
        [speciesStage clearScene];
        summaryStage = [[YASummaryStage alloc]initWithWorld:_world StateMachine:self];
        
        dispatch_async(gameStages, ^{
            [summaryStage setGameContext:gameContext];
            [summaryStage setupScene];
        });
        
        activeState = summaryStage;
    }  else if(activeState == summaryStage) {
        [summaryStage clearScene];
        
        if ([summaryStage startGameState] == YES) {
            inGameStage = [[YAInGameStage alloc] initWithWorld:_world StateMachine:self];
            
            dispatch_async(gameStages, ^{
                [inGameStage setGameContext:gameContext];
                [inGameStage setupScene];
            });
            
            activeState = inGameStage;
        } else {
            gameContext =[[YAGameContext alloc] init];
            activeState = introStage;
            
            dispatch_async(gameStages, ^{
                [introStage setGameContext:gameContext];
                [introStage setupScene];
            });
        }
    }  else if(activeState == inGameStage) {
        [inGameStage clearScene];
        
        introStage = [[YAIntroStage alloc] initWithWorld:_world StateMachine:self];
        
        dispatch_async(gameStages, ^{
            [introStage setGameContext:gameContext];
            [introStage setupScene];
        });
        
        activeState = introStage;
    }
    
    
}

- (void) shutdown
{
    shutdownGameStageQueue(NULL);
}


dispatch_queue_t setupGameStageQueue()
{
    // NSLog(@"setup game stage queue.");
    return dispatch_queue_create("de.yousry.gameStageQueue", NULL);
}

void shutdownGameStageQueue (void *context)
{
    // NSLog(@"shutdown game stage queue.");
}

- (bool) isInGame
{
    // return activeState == inGameStage;
    return false;
}


@end
