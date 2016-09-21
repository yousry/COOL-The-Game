//
//  YADevelopmentController.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 05.03.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import "YAFortune.h"
#import "YAStore.h"
#import "YAImpGroup.h"
#import "YAQuaternion.h"
#import "YABulletEngineTranslator.h"
#import "YAImpersonator+Physic.h"
#import "YAImpCollector.h"
#import "YAVector3f.h"
#import "YASpotLight.h"
#import "YAGouradLight.h"
#import "YASceneUtils.h"
#import "YARenderLoop.h"
#import "YABlockAnimator.h"
#import "YAChronograph.h"
#import "YAGameContext.h"
#import "YAEvent.h"
#import "YAEventChain.h"
#import "YADevelopmentController.h"

@implementation YADevelopmentController {
    YABlockAnimator* dummy;
    YAChronograph* chronograph;
}

@synthesize info = _info;
@synthesize finished = _finished;

-(id) initInfo: (NSDictionary*) info
{
    self = [super init];
    
    if(self) {
        _info = info;
        _finished = false;
        chronograph = [[YAChronograph alloc] init];
    }
    return self;
    
}

- (void) play: (int) playerId
{
    // NSLog(@"Player %d is playing", playerId);
    
    __block YAGameContext* gameContext = [_info objectForKey:@"GAMECONTEXT"];
    YAEventChain* eventChain = [_info objectForKey:@"EVENTCHAIN"];
    YARenderLoop* world = [_info objectForKey:@"WORLD"];
    __block YASceneUtils* sceneUtils = [_info objectForKey:@"SCENEUTILS"];
    __block YAImpCollector* ic = [_info objectForKey:@"IMPCOLLECTOR"];
    __block YABulletEngineTranslator* be = [_info objectForKey:@"PHYSICS"];
    __block YAStore* store = [_info objectForKey:@"STORE"];
    store.gambling = false; // reset gambling property

    
    gameContext.activePlayer = playerId;

    
    if([[eventChain getEvent:@"shopping"] valid])
        [eventChain resetEvents:[NSArray arrayWithObject:@"shopping"]];
    else
        [eventChain startEvent:@"shopping"];
    
    //start timer
    
    YABlockAnimator* delayTrigger = [world createBlockAnimator];
    delayTrigger.delay = 1.8f;
    delayTrigger.oneExecution = YES;
    
    [delayTrigger addListener:^(float sp, NSNumber *event, int message) {
        for(NSString* event in [NSArray arrayWithObjects:@"gameTimer", @"roundTimeCountdown", nil]) {
            if([[eventChain getEvent:event] valid])
                [eventChain resetEvents:[NSArray arrayWithObject:event]];
            else
                [eventChain startEvent:event];
        }
        [chronograph start]; // used for gambling calculation
    }];

    
    dummy = [world createBlockAnimator];
    dummy.delay = 1.0f;
    __weak YADevelopmentController* selfW = self;
    __weak YABlockAnimator* dummyW = dummy;
    __weak YAChronograph* chronographW = chronograph;
    __weak YAFortune* fortuneW = _fortune;

    [dummy addListener:^(float sp, NSNumber *event, int message) {
        if(gameContext.activePlayer == -1) {
            // NSLog(@"Player %d finished playing", playerId);
            [selfW cleanup];

            YABlockAnimator* delayTrigger = [world createBlockAnimator];
            delayTrigger.oneExecution = YES;
            delayTrigger.delay = 4.5; // <--- At least > 1.5 greater than the value below
            [delayTrigger addListener:^(float sp, NSNumber *event, int message) {
                selfW.finished = YES;
            }];

            dummyW.deleteme = YES;
            
            delayTrigger = [world createBlockAnimator];
            delayTrigger.oneExecution = YES;
            delayTrigger.delay = 2.5; // <--- In Case of errors after player stage ends increase this value
            [delayTrigger addListener:^(float sp, NSNumber *event, int message) {
                [sceneUtils setLightPosition:sceneUtils.light to:LIGHT_NOON_RELAXED];
                
                [sceneUtils setRadiation:sceneUtils.light to:EMISSION_WHITE_FULL];
                [[sceneUtils light] setDirectional:true];
                
                // Set Spotlight position, cutoff and radiation
                [sceneUtils setLightPosition:sceneUtils.spotLight to:LIGHT_ROOM_SPOT];
                [sceneUtils.spotLight spotAt:[[YAVector3f alloc] initVals:1 :0 :0]];
                
                [sceneUtils.spotLight setCutoff:14.0];
                [sceneUtils.spotLight setExponent:75];
                [sceneUtils setRadiation:sceneUtils.spotLight to:EMISSION_ARTIFICIAL_FULL];
                [sceneUtils updateSpotLightFrustum];
                
                [sceneUtils setAvatarPositionTo:AVATAR_DEVELOPMENT];
                
                NSMutableArray* physicImps = be.physicImps;
                
                int i = 0;
                for(YAImpersonator* starImp in ic.starImps) {
                    
                    [starImp setUseQuaternionRotation:true];
                    
                    if(i == 0) {
                        [[starImp translation] setValues:-5.543136 :4.250978 :-0.149020];
                        [[starImp rotation] setZ: 30];
                        [starImp setRotationQuaternion:[[YAQuaternion alloc] initEuler:0 pitch:0 roll:30]];
                    } else if (i == 1) {
                        [[starImp translation] setValues:-6.747066 :3.449020 :-0.807845];
                        [[starImp rotation] setZ: 55];
                        [starImp setRotationQuaternion:[[YAQuaternion alloc] initEuler:0 pitch:0 roll:55]];
                    } else if (i == 2) {
                        [[starImp translation] setValues:-4.462750 :3.245075 :1.149022];
                        [[starImp rotation] setZ: 0];
                        [starImp setRotationQuaternion:[[YAQuaternion alloc] initEuler:0 pitch:0 roll:0]];
                    }
                    i++;
                    
                    [starImp setMass:@0.5f];
                    [starImp setHulls:[[NSArray alloc] initWithObjects:@"StarHull", @"StarHull.001", @"StarHull.002", @"StarHull.003", nil]];
                    
                    if(![physicImps containsObject:starImp])
                        [physicImps addObject:starImp];
                }
                
                [be restart];
                
                // add ropes to stars
                for(YAImpersonator* starImp in ic.starImps) {
                    YAVector3f* from = [[YAVector3f alloc] initCopy:[starImp translation]];
                    YAVector3f* to = [[YAVector3f alloc] initCopy:[starImp translation]];
                    from.y = 8;
                    to.y += 2;
                    [be addRopeFor:starImp.identifier top:from anchor:to];
                }
                
                [ic.eagleGroup setSize: [[YAVector3f alloc] initVals:1 :1 :1]];
                ic.eagleGroup.visible = NO;
                ic.podImp.visible = NO;

                for(YAImpersonator* gImp in ic.eagleGroup.allImps) {
                    gImp.visible = NO;
                }
                
                // Did the player gamble?
                if(store.gambling) {
                    float playTime = chronographW.getTime;
                    
                    float availableUnits = [[gameContext playerDataForId:playerId] foodUnits];
                    
                    
                    float necessaryFoodUnits = 3;
                    if(gameContext.round >= 5)
                        necessaryFoodUnits = 4;
                    else if(gameContext.round >= 9)
                        necessaryFoodUnits = 5;
                    
                    float availableTime = [gameContext calcDevelopmentTime];
                    
                    if(availableUnits < necessaryFoodUnits)
                        availableTime *= (availableUnits / necessaryFoodUnits);
                    
                    float usedTime = playTime / availableTime;
                    [fortuneW gambleFor:playerId usedTime:usedTime At:0];
                }
                
                store.gambling = false;
            }];
            
        }
    }];
}

- (void) cleanup
{
    
}

@end
