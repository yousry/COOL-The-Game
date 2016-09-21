//
//  YACounterEvent.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 11.01.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import "YASoundCollector.h"
#import "YASceneUtils.h"
#import "YAGameContext.h"
#import "YAImpCollector.h"
#import "YAEventChain.h"
#import "YAOpenAL.h"
#import "YABlockAnimator.h"
#import "YAVector3f.h"
#import "YAMaterial.h"
#import "YAImpersonator.h"
#import "YARenderLoop.h"
#import "YASceneUtils.h"
#import "YACounterEvent.h"

#define SOLAR_SYSTEM_HEIGHT 4.5f

@implementation YACounterEvent {
    YAImpersonator* textCounterImp;
    int _counterSoundId;
}

- (id) init
{
    self = [super init];
    if(self) {
        _counterSoundId = -1;
        _roundTime = 0;
    }
    return self;
}


/* show sun-moon clock
 moon acts as roundcounter clockwise
 sun cover acts as actual roundtime 45secs
*/

- (ListenerEvent) GameTimerEvent
{
    ListenerEvent listener = ^(NSDictionary *info)
    {
        // NSLog(@"Game Timer Event");
        
        // preconditions
        YAImpCollector* ic = [info objectForKey:@"IMPCOLLECTOR"];
        YAGameContext* gameContext = [info objectForKey:@"GAMECONTEXT"];
        YARenderLoop* world = [info objectForKey:@"WORLD"];
//        YASceneUtils* sceneUtils = [info objectForKey:@"SCENEUTILS"];
        
        YAImpersonator* sunImp = ic.sunImp;
        YAImpersonator* sunCoverImp = ic.sunCoverImp;
        YAImpersonator* moonImp = ic.moonImp;
        YAImpersonator* stickMoon = ic.stickMoonImp;
        YAImpersonator* stickSun = ic.stickSunImp;

        const int round = gameContext.round;
        
        _roundTime = [self calcRoundTime: gameContext];
        
        // show sun
        sunImp.visible = YES;
        
        // set default properties fopr sun
        [[sunImp translation] setValues:0.0f :SOLAR_SYSTEM_HEIGHT :0.0f];
        [[sunImp rotation] setValues:-90.0f :0.0f :0.0f];
        [sunImp resize:0.8f];
        
        // show moon
        moonImp.visible = YES;
        
        // set default properties for moon
        [[moonImp translation] setValues:-0.0f :SOLAR_SYSTEM_HEIGHT :4.0f];
        [[moonImp rotation] setValues:-90.0f :0.0f :0.0f];
        [moonImp resize:0.5f];

        // rotate moon around sun according game round
        const float moonRotationAngle = (360.0f / 12.0f) * (float) round;
        [[moonImp translation] rotate:moonRotationAngle axis:[[YAVector3f alloc] initYAxe]];
        
        // show sunCover
        [sunCoverImp setVisible:YES];
        [[sunCoverImp translation] setValues:0.0f :SOLAR_SYSTEM_HEIGHT :0.0f];
        [[sunCoverImp rotation] setValues:-90.0f :0.0f :0.0f];
        [sunCoverImp resize:0.8f];
        
        
        // show sticks
        stickSun.visible = YES;
        stickMoon.visible = YES;
        
        [[stickSun translation] setVector:sunCoverImp.translation];
        [[stickMoon translation] setVector:moonImp.translation];
        
        stickSun.translation.y += 1.1;
        stickMoon.translation.y += 0.635;
        
        
        // add slow moon movement
        __block YABasicAnimator* basicAnimMoon = [world createBasicAnimator];
        basicAnimMoon.asyncProcessing = NO;
        [basicAnimMoon setInfluence:Y_AXE];
        [basicAnimMoon setProgress:harmonic];
        [basicAnimMoon addListener:moonImp.rotation factor:5.0f];
        [basicAnimMoon addListener:stickMoon.rotation factor:5.0f];
        

        // one sunCover rotation eqauls a roundtime
        __block YABasicAnimator* basicAnimCover = [world createBasicAnimator];
        basicAnimCover.asyncProcessing = NO;
        [basicAnimCover setInterval:_roundTime];
        [basicAnimCover setInfluence:Y_AXE];
        [basicAnimCover addListener:sunCoverImp.rotation factor:360.0f];
        [basicAnimCover addListener:stickSun.rotation factor:360.0f];
        
        YABlockAnimator* finisher = [world createBlockAnimator];
        __weak YABlockAnimator* finisherW = finisher;
        
        finisher.asyncProcessing = NO;
        finisher.once = YES;
        finisher.interval = _roundTime;
        [finisher addListener:^(float sp, NSNumber *event, int message) {
            
            if(finisherW.deleteme || gameContext.activePlayer == -1) {
                finisherW.deleteme = YES;
                basicAnimMoon.deleteme = YES;
                basicAnimCover.deleteme = YES;
                
                stickSun.visible = NO;
                stickMoon.visible = NO;
                sunImp.visible = NO;
                sunCoverImp.visible = NO;
                moonImp.visible = NO;
                
                gameContext.activePlayer = -1;
            }
            

        }];
        
        

    };
    
    return listener;
}

// create a small counter in display orientation
- (ListenerEvent) roundTimeCountdownEvent
{
    ListenerEvent listener = ^(NSDictionary *info) {
        // NSLog(@"Round Time Countdown Event");
        YASceneUtils* sceneUtils = [info objectForKey:@"SCENEUTILS"];
        YARenderLoop* world = [info objectForKey:@"WORLD"];
        YAImpCollector* impColelctor = [info objectForKey:@"IMPCOLLECTOR"];
        YAGameContext* gameContext = [info objectForKey:@"GAMECONTEXT"];
        YASoundCollector* soundCollector = [info objectForKey:@"SOUNDCOLLECTOR"];

        
        _roundTime = [self calcRoundTime: gameContext];
        
        __block int counterNumber = _roundTime;
        textCounterImp = [sceneUtils genTextBlocked:[NSString stringWithFormat:@"%d", counterNumber]];
        
        __block YAVector3f* defaultPosition = [[YAVector3f alloc] initVals:-0.1 :-0.1 :2];
        [[textCounterImp translation] setVector:defaultPosition];
        [sceneUtils alignToCam:textCounterImp];
        
        [[[textCounterImp material] phongAmbientReflectivity] setVector:sceneUtils.color_red];
        [[textCounterImp material] setEta:0.7];
        [textCounterImp setClickable:false];

        __block YABlockAnimator* updateCounter = [world createBlockAnimator];
        __weak YABlockAnimator* wUpdateCounter = updateCounter;
        
        [updateCounter setInterval:_roundTime];
        [updateCounter setOnce:YES];
        [updateCounter setAsyncProcessing:NO];
        [updateCounter addListener:^(float sp, NSNumber *event, int message) {
            int timeCode = (int)(_roundTime * (1 - sp)) + 1;
            
            const bool isZoomed = impColelctor.terrainImp.size.x >= 50; // detect the shop zooming
            
            if(isZoomed) {
                [textCounterImp resize:1.0];
                [[textCounterImp translation] setValues:3.2 :2.6 :16];
                [sceneUtils alignToCam:textCounterImp];
            } else {
                [textCounterImp resize:0.25];
                [[textCounterImp translation] setValues:0.8 :0.65 :4];
                [sceneUtils alignToCam:textCounterImp];
            }
            
            if(counterNumber != timeCode) {
                counterNumber = timeCode;
                [world updateTextIngredient:[NSString stringWithFormat:@"%2d", counterNumber] Impersomator:textCounterImp];
                
                if(counterNumber <= 5)
                    [soundCollector playForImp:textCounterImp Sound:[soundCollector getSoundId:@"Pickup"]];
                
            }
            
            if(wUpdateCounter.deleteme || gameContext.activePlayer == -1) {
                wUpdateCounter.deleteme = YES;
                [world removeImpersonator:textCounterImp.identifier];
            }
        }];

        
        

        
    };
    
    return listener;
}

- (float) calcRoundTime: (YAGameContext*) gameContext
{
    float availableUnits = [[gameContext playerDataForId:gameContext.activePlayer] foodUnits];
    float necessaryFoodUnits = 3;
    if(gameContext.round >= 5)
        necessaryFoodUnits = 4;
    else if(gameContext.round >= 9)
        necessaryFoodUnits = 5;
    
    const float standardTime = [gameContext calcDevelopmentTime];
    if(availableUnits > necessaryFoodUnits)
        return standardTime;
    else {
        float reducedTime = ((float)availableUnits) / ((float)necessaryFoodUnits);
        
        if(reducedTime < 0.33)
            reducedTime = 0.33;
        
        return (standardTime * reducedTime);
    }
}

- (ListenerEvent) fiveSecondsCountdownEvent
{
    
    ListenerEvent listener = ^(NSDictionary *info) {
        // NSLog(@"Five Seconds Countdown Event");
        
        YASceneUtils* sceneUtils = [info objectForKey:@"SCENEUTILS"];
        YARenderLoop* world = [info objectForKey:@"WORLD"];
        YAOpenAL* soundHandler = [info objectForKey:@"SOUNDHANDLER"];
        YAEventChain* eventChain = [info objectForKey:@"EVENTCHAIN"];

        if( _counterSoundId == -1) {
            int bufferId = [soundHandler loadSound:@"countdown.wav"];
            _counterSoundId = [soundHandler setupSound:bufferId atPosition:[[YAVector3f alloc] initVals:0 :-1 :0] loop:false];
            [soundHandler setVolume:_counterSoundId gain:1.0];
        }
        
        __block int counterNumber = 5;
        textCounterImp = [sceneUtils genText:[NSString stringWithFormat:@"%d", counterNumber]];

        [textCounterImp resize:0.4];
        
        __block YAVector3f* defaultPosition = [[YAVector3f alloc] initVals:-0.1 :-0.1 :2];
        [[textCounterImp translation] setVector:defaultPosition];
        [sceneUtils alignToCam:textCounterImp];
        
        [[[textCounterImp material] phongAmbientReflectivity] setVector:sceneUtils.color_red];
        [[textCounterImp material] setEta:0.7];

        [textCounterImp setClickable:false];
        
        
        YAVector3f* defaultRotation = [[YAVector3f alloc] initCopy:textCounterImp.rotation];
        [soundHandler playSound:_counterSoundId]; // if [soundHandler isPlaying:_counterSoundId]
        
        __block YABlockAnimator* updateCounter = [world createBlockAnimator];
        __weak YABlockAnimator* wUpdateCounter = updateCounter;
        
        [updateCounter setInterval:5];
        [updateCounter setOnce:YES];
        [updateCounter setAsyncProcessing:NO];
        
        [updateCounter addListener:^(float sp, NSNumber *event, int message) {
            int timeCode = (int)(5 * (1 - sp)) + 1;
            
            [[textCounterImp translation] setVector:defaultPosition];
            [sceneUtils alignToCam:textCounterImp];

            if(counterNumber != timeCode) {
                counterNumber = timeCode;
                [[textCounterImp rotation] setVector:defaultRotation];
                [world updateTextIngredient:[NSString stringWithFormat:@"%d", counterNumber] Impersomator:textCounterImp];
                YABasicAnimator* spin = [world createBasicAnimator];
                [spin setOnce:YES];
                [spin setProgress:damp];
                [spin setInterval:0.1];
                [spin setDelay:0.9];
                [spin setInfluence:X_AXE];
                [spin addListener:textCounterImp.rotation factor:180];
            }
            
            if(wUpdateCounter.deleteme) {
                [world removeImpersonator:textCounterImp.identifier];
                [eventChain startEvent:@"fiveSecondsCountDownFinished"];
            }
        }];
    };

    return listener;
    
}


@end
