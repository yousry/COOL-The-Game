//
//  YASummaryStage.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 30.07.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//


#import "YALog.h"
#import "YASoundCollector.h"
#import "YAGameStateMachine.h"
#import "YAGameContext.h"
#import "YAKinematic.h"
#import "YAQuaternion.h"
#import "YABonzoidMover.h"
#import "YAFlapperMover.h"
#import "YAGollumerMover.h"
#import "YAHumanoidMover.h"
#import "YALeggitMover.h"
#import "YAMechatronMover.h"
#import "YAPackerMover.h"
#import "YASpheroidMover.h"
#import "YADromedarMover.h"

#import "YATexture.h"
#import "YAAvatar.h"
#import "YAIngredient.h"
#import "YAImpersonator.h"
#import "YAVector4f.h"
#import "YAVector3f.h"
#import "YABasicAnimator.h"
#import "YABlockAnimator.h"
#import "YASpotLight.h"
#import "YALight.h"
#import "YAGouradLight.h"
#import "YAMaterial.h"
#import "YATriangleGrid.h"
#import "YATerrain.h"
#import "YARenderLoop.h"
#import "YAIntroStage.h"
#import "YAImpGroup.h"

#import "YASummaryStage.h"

@implementation YASummaryStage
@synthesize gameContext, startGameState;

- (id) initWithWorld: (YARenderLoop*) world StateMachine: (YAGameStateMachine*) stateMachine
{
    self = [super init];
    
    if(self) {
        renderLoop = world;
        _stateMachine = stateMachine;
        startGameState = YES;
    }
    
    return self;
}

- (void) setupScene
{
    // NSLog(@"Setup Scene");

    [renderLoop setOpenGLContextToThread];

    
    [self loadModels];

    
    soundCollector = _stateMachine.soundCollector;
    
    
    __block YAAvatar* avatar = [renderLoop avatar];
    [avatar setPosition: [[YAVector3f alloc] initVals:0.0f :10.0f :-14.0f ]];
    [avatar setAtlas:34.0f axis:00.0f];
    
    YABlockAnimator* rotateCam = [renderLoop createBlockAnimator];
    [rotateCam setProgress:harmonic];
    [rotateCam addListener:^(float sp, NSNumber *event, int message) {
        [avatar setPosition: [[YAVector3f alloc] initVals:0.0f :15.0f + sp :-15.0 ]];
        [avatar setAtlas:45.0f + sp * 2 axis:00.0f];
    }];
    
    NSArray* lights = [renderLoop lights];
    __block YASpotLight* sLight;
    
    for (YALight* lit in lights) {
        if([[lit name] isEqualToString:@"YASpotLight"]) {
            sLight = (YASpotLight*)lit;
        }
    }
    
    [sLight setCutoff:20];
    [sLight setExponent:80];
    
    [[sLight position] setVector:[[YAVector3f alloc] initVals:10.0f :15.0f :-10.0f]];
    [sLight spotAt: [[YAVector3f alloc] initVals: 0 :0 :0]];
    
    int deskId = [renderLoop createImpersonator:@"Desk"];
    YAImpersonator* deskImp = [renderLoop getImpersonator:deskId];
    [[deskImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
    [[deskImp translation] setVector: [[YAVector3f alloc] initVals: 0: -0.1 : 0]];
    [[[deskImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.1 : 0.1 : 0.1 ]];
    [[[deskImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.6f : 0.6f : 0.6f ]];
    [[[deskImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [deskImp resize:3];
    
    int playboardId = [renderLoop createImpersonator:@"PlayboardTitle"];
    YAImpersonator* playboardImp = [renderLoop getImpersonator:playboardId];
    [[playboardImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
    [[playboardImp translation] setVector: [[YAVector3f alloc] initVals: 0: 0 : 0]];
    [[[playboardImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4 : 0.4 : 0.4 ]];
    [[[playboardImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[playboardImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [playboardImp resize:3];
    [playboardImp setShadowCaster:false];
    
    __block  YAImpersonator* textTitleImp = [self genText:[YALog decode:@"GameSummary"]];
    [textTitleImp resize:0.32];
    [[[textTitleImp material] phongAmbientReflectivity] setValues:0.9 :0.1 :0.2];
    textTitleImp.material.eta = 0.7;
    
    __block  YAImpersonator* textyourLevel = [self genText:[YALog decode:@"YourLevel"]];
    [textyourLevel resize:0.15];
    [[[textyourLevel material] phongAmbientReflectivity] setValues:0.6 :0.1 :0.1];
    textyourLevel.material.eta = 0;
    
    NSString* level = [YALog decode:@"LevelEasyKey"];
    if(gameContext.gameDifficulty == 1)
        level = [YALog decode:@"LevelAmateurKey"];
    else if(gameContext.gameDifficulty == 2)
        level = [YALog decode:@"LevelClassicKey"];
    else if(gameContext.gameDifficulty == 3)
        level = [YALog decode:@"LevelModernKey"];
    
    __block  YAImpersonator* textyourLevelValue = [self genText:level];
    [textyourLevelValue resize:0.15];
    [[[textyourLevelValue material] phongAmbientReflectivity] setValues:0.1 :0.1 :0.6];
    textyourLevelValue.material.eta = 0;
    
    __block  YAImpersonator* textyourPlayer = [self genText:[YALog decode:@"YourPlayer"]];
    [textyourPlayer resize:0.15];
    [[[textyourPlayer material] phongAmbientReflectivity] setValues:0.6 :0.1 :0.1];
    textyourPlayer.material.eta = 0;
    
    NSString* playerNumValue = gameContext.playerNumber == 1 ? @"1 Planeteer" : [NSString stringWithFormat:@"%d Planeteers", gameContext.playerNumber];
    __block  YAImpersonator* textPlayerNumber = [self genText:playerNumValue];
    [textPlayerNumber resize:0.15];
    [[[textPlayerNumber material] phongAmbientReflectivity] setValues:0.1 :0.1 :0.6];
    textPlayerNumber.material.eta = 0;
    
    __block  YAImpersonator* textChoosenSpecies = [self genText:[YALog decode:@"ChoosenSpecies"]];
    [textChoosenSpecies resize:0.15];
    [[[textChoosenSpecies material] phongAmbientReflectivity] setValues:0.6 :0.1 :0.1];
    textChoosenSpecies.material.eta = 0;
    
    __block  YAImpersonator* textPlayerOneSpecies = [self genText:[gameContext  getSpeciesForPlayer:0]];
    [textPlayerOneSpecies resize:0.1];
    [[[textPlayerOneSpecies material] phongAmbientReflectivity] setValues:0.1 :0.1 :0.6];
    textPlayerOneSpecies.material.eta = 0;
    
    __block  YAImpersonator* textPlayerTwoSpecies = [self genText:[gameContext  getSpeciesForPlayer:1]];
    [textPlayerTwoSpecies resize:0.1];
    [[[textPlayerTwoSpecies material] phongAmbientReflectivity] setValues:0.1 :0.1 :0.6];
    textPlayerTwoSpecies.material.eta = 0;
    
    __block  YAImpersonator* textPlayerThreeSpecies = [self genText:[gameContext  getSpeciesForPlayer:2]];
    [textPlayerThreeSpecies resize:0.1];
    [[[textPlayerThreeSpecies material] phongAmbientReflectivity] setValues:0.1 :0.1 :0.6];
    textPlayerThreeSpecies.material.eta = 0;
    
    __block  YAImpersonator* textPlayerFourSpecies = [self genText:[gameContext  getSpeciesForPlayer:3]];
    [textPlayerFourSpecies resize:0.1];
    [[[textPlayerFourSpecies material] phongAmbientReflectivity] setValues:0.1 :0.1 :0.6];
    textPlayerFourSpecies.material.eta = 0;
    
    __block NSMutableArray* meepleImps = [[NSMutableArray alloc] init];
    for(int i = 0; i <= 3; i++) {
        
        int meepleId = [renderLoop createImpersonatorWithShapeShifter: [gameContext getSpeciesForPlayer:i]];
        __block YAImpersonator* meepleImp = [renderLoop getImpersonator:meepleId];
        
        [meepleImp setVisible:true];
        [[meepleImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :0 :0] ];
        [[meepleImp translation] setVector:[[YAVector3f alloc] initVals:-4.5 + 3.0 * i : 0.1 :-3.5] ];
        [[[meepleImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
        [[[meepleImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
        [[[meepleImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
        [[meepleImp material] setPhongShininess: 20];
        
        if([[gameContext getSpeciesForPlayer:i] isEqualToString:@"Mechatron"])
            [meepleImp resize: 0.22];
        else if([[gameContext getSpeciesForPlayer:i] isEqualToString:@"Gollumer"])
            [meepleImp resize: 0.17];
        else if([[gameContext getSpeciesForPlayer:i] isEqualToString:@"Paker"])
            [meepleImp resize: 0.22];
        else if([[gameContext getSpeciesForPlayer:i] isEqualToString:@"Bonzoid"])
            [meepleImp resize: 0.22];
        else if([[gameContext getSpeciesForPlayer:i] isEqualToString:@"Spheroid"])
            [meepleImp resize: 0.22];
        else if([[gameContext getSpeciesForPlayer:i] isEqualToString:@"Flapper"])
            [meepleImp resize: 0.17];
        else if([[gameContext getSpeciesForPlayer:i] isEqualToString:@"Leggit"])
            [meepleImp resize: 0.19];
        else if([[gameContext getSpeciesForPlayer:i] isEqualToString:@"Humanoid"])
            [meepleImp resize: 0.70];
        
        [meepleImps addObject:meepleImp];
        
    }
    
    int player = 0;
    NSString* deviceType = @"Pad";
    if([gameContext deviceIdforPlayer:player ]  < 0)
        deviceType = @"Bot";
    else if ([gameContext deviceIdforPlayer:player ]  == 1000)
        deviceType = @"Mouse";
    
    __block  YAImpersonator* textPlayerOneDevice = [self genText:deviceType];
    [textPlayerOneDevice resize:0.1];
    [[[textPlayerOneDevice material] phongAmbientReflectivity] setValues:0.1 :0.1 :0.6];
    textPlayerOneDevice.material.eta = 0;
    
    player = 1;
    deviceType = @"Pad";
    if([gameContext deviceIdforPlayer:player ]  < 0)
        deviceType = @"Bot";
    else if ([gameContext deviceIdforPlayer:player ]  == 1000)
        deviceType = @"Mouse";
    
    __block  YAImpersonator* textPlayerTwoDevice = [self genText:deviceType];
    [textPlayerTwoDevice resize:0.1];
    [[[textPlayerTwoDevice material] phongAmbientReflectivity] setValues:0.1 :0.1 :0.6];
    textPlayerTwoDevice.material.eta = 0;
    
    player = 2;
    deviceType = @"Pad";
    if([gameContext deviceIdforPlayer:player ]  < 0)
        deviceType = @"Bot";
    else if ([gameContext deviceIdforPlayer:player ]  == 1000)
        deviceType = @"Mouse";
    
    __block  YAImpersonator* textPlayerThreeDevice = [self genText:deviceType];
    [textPlayerThreeDevice resize:0.1];
    [[[textPlayerThreeDevice material] phongAmbientReflectivity] setValues:0.1 :0.1 :0.6];
    textPlayerThreeDevice.material.eta = 0;
    
    player = 3;
    deviceType = @"Pad";
    if([gameContext deviceIdforPlayer:player ]  < 0)
        deviceType = @"Bot";
    else if ([gameContext deviceIdforPlayer:player ]  == 1000)
        deviceType = @"Mouse";
    
    __block  YAImpersonator* textPlayerFourDevice = [self genText:deviceType];
    [textPlayerFourDevice resize:0.1];
    [[[textPlayerFourDevice material] phongAmbientReflectivity] setValues:0.1 :0.1 :0.6];
    textPlayerFourDevice.material.eta = 0;
    
    
    __block  YAImpersonator* textGoOn = [self genText:[YALog decode:@"GoOn"]];
    [textGoOn resize:0.15];
    [[[textGoOn material] phongAmbientReflectivity] setValues:0.1 :0.1 :0.6];
    textGoOn.material.eta = 0;
    
    for (int i = 0; i <= 3; i++) {
        if([gameContext deviceIdforPlayer:i] == 1000) {
            buttonStart = [[YAImpGroup alloc] init];
            [self genButton: &(sensorStart) group:buttonStart];
            [buttonStart setTranslation:[[YAVector3f alloc] initVals:-4.6 + 3 * i :0.06 : -4.7]];
        }
    }
    
    
    __block  YAImpersonator* textCancel = [self genText:[YALog decode:@"CancelGoBack"]];
    [textCancel resize:0.1];
    [[[textCancel material] phongAmbientReflectivity] setValues:0.6 :0.1 :0.1];
    textCancel.material.eta = 0;
    
    YABlockAnimator* alignToCam = [renderLoop createBlockAnimator];
    [alignToCam setInterval:1.0];
    [alignToCam setProgress:harmonic];
    [alignToCam addListener:^(float sp, NSNumber *event, int message) {
        
        YAVector3f* position = [[YAVector3f alloc] initVals:-0.9 :1.0 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textTitleImp translation] setVector: position];
        [[textTitleImp rotation] setX: [avatar headAtlas]];
        [[textTitleImp rotation] setY: -[avatar headAxis]];
        
        // ----------------------------------------
        
        position = [[YAVector3f alloc] initVals:-0.925 :0.8 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textyourLevel translation] setVector: position];
        [[textyourLevel rotation] setX: [avatar headAtlas]];
        [[textyourLevel rotation] setY: -[avatar headAxis]];
        
        
        // ----------------------------------------
        
        position = [[YAVector3f alloc] initVals:-0.4 :0.6 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textyourLevelValue translation] setVector: position];
        [[textyourLevelValue rotation] setX: [avatar headAtlas]];
        [[textyourLevelValue rotation] setY: -[avatar headAxis]];
        
        // ----------------------------------------
        
        position = [[YAVector3f alloc] initVals:-0.7 :0.4 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textyourPlayer translation] setVector: position];
        [[textyourPlayer rotation] setX: [avatar headAtlas]];
        [[textyourPlayer rotation] setY: -[avatar headAxis]];
        
        // ----------------------------------------
        
        position = [[YAVector3f alloc] initVals:-0.5 :0.2 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textPlayerNumber translation] setVector: position];
        [[textPlayerNumber rotation] setX: [avatar headAtlas]];
        [[textPlayerNumber rotation] setY: -[avatar headAxis]];
        
        // ----------------------------------------
        
        position = [[YAVector3f alloc] initVals:-1.5 :0.0 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textChoosenSpecies translation] setVector: position];
        [[textChoosenSpecies rotation] setX: [avatar headAtlas]];
        [[textChoosenSpecies rotation] setY: -[avatar headAxis]];
        
        
        const float leftCorner = -1.6f;
        const float separator = 0.8;
        
        // ----------------------------------------
        
        position = [[YAVector3f alloc] initVals:leftCorner + 0 * separator :-0.2 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textPlayerOneSpecies translation] setVector: position];
        [[textPlayerOneSpecies rotation] setX: [avatar headAtlas]];
        [[textPlayerOneSpecies rotation] setY: -[avatar headAxis]];
        
        // ----------------------------------------
        
        position = [[YAVector3f alloc] initVals:leftCorner + 1 * separator :-0.2 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textPlayerTwoSpecies translation] setVector: position];
        [[textPlayerTwoSpecies rotation] setX: [avatar headAtlas]];
        [[textPlayerTwoSpecies rotation] setY: -[avatar headAxis]];
        
        // ----------------------------------------
        
        position = [[YAVector3f alloc] initVals:leftCorner + 2 * separator :-0.2 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textPlayerThreeSpecies translation] setVector: position];
        [[textPlayerThreeSpecies rotation] setX: [avatar headAtlas]];
        [[textPlayerThreeSpecies rotation] setY: -[avatar headAxis]];
        
        // ----------------------------------------
        
        position = [[YAVector3f alloc] initVals:leftCorner + 3 * separator :-0.2 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textPlayerFourSpecies translation] setVector: position];
        [[textPlayerFourSpecies rotation] setX: [avatar headAtlas]];
        [[textPlayerFourSpecies rotation] setY: -[avatar headAxis]];
        
        // ----------------------------------------
        
        position = [[YAVector3f alloc] initVals:leftCorner + 0 * separator :-0.7 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textPlayerOneDevice translation] setVector: position];
        [[textPlayerOneDevice rotation] setX: [avatar headAtlas]];
        [[textPlayerOneDevice rotation] setY: -[avatar headAxis]];
        
        // ----------------------------------------
        
        position = [[YAVector3f alloc] initVals:leftCorner + 1 * separator :-0.7 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textPlayerTwoDevice translation] setVector: position];
        [[textPlayerTwoDevice rotation] setX: [avatar headAtlas]];
        [[textPlayerTwoDevice rotation] setY: -[avatar headAxis]];
        
        // ----------------------------------------
        
        position = [[YAVector3f alloc] initVals:leftCorner + 2 * separator :-0.7 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textPlayerThreeDevice translation] setVector: position];
        [[textPlayerThreeDevice rotation] setX: [avatar headAtlas]];
        [[textPlayerThreeDevice rotation] setY: -[avatar headAxis]];
        
        // ----------------------------------------
        
        position = [[YAVector3f alloc] initVals:leftCorner + 3 * separator :-0.7 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textPlayerFourDevice translation] setVector: position];
        [[textPlayerFourDevice rotation] setX: [avatar headAtlas]];
        [[textPlayerFourDevice rotation] setY: -[avatar headAxis]];
        
        // ----------------------------------------
        
        position = [[YAVector3f alloc] initVals:-1.5 :-0.9 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textGoOn translation] setVector: position];
        [[textGoOn rotation] setX: [avatar headAtlas]];
        [[textGoOn rotation] setY: -[avatar headAxis]];
        
        // ----------------------------------------
        
        position = [[YAVector3f alloc] initVals:-1.1 :-1.1 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textCancel translation] setVector: position];
        [[textCancel rotation] setX: [avatar headAtlas]];
        [[textCancel rotation] setY: -[avatar headAxis]];
        
        
    }];
    
    
    // manage user input
    
    __block NSMutableArray* playerSelections = [[NSMutableArray alloc] initWithCapacity:4];
    
    for (int i = 0; i < 4; i++) {
        if(i < gameContext.playerNumber)
            [playerSelections addObject:@0]; // player
        else
            [playerSelections addObject:@1]; // auto ok
    }
    
    YABlockAnimator* playerFeedback = [renderLoop createBlockAnimator];
    [playerFeedback setInterval:1.0];
    [playerFeedback setProgress:harmonic];
    [playerFeedback addListener:^(float sp, NSNumber *event, int message) {
        event_keyPressed ev = [event intValue];
        
        int mValue = -1;
        int deviceId = -1;
        
        switch (ev) {
            case GAMEPAD_BUTTON_OK:
                mValue = message & 255;
                deviceId = message >> 16;
                break;
            case GAMEPAD_BUTTON_CANCEL:
                mValue = message & 255;
                deviceId = message >> 16;
                break;
            case MOUSE_DOWN:
                if(message == sensorStart) {
                    mValue = 1;
                    deviceId = 1000;
                }
                break;
            case ESCAPE:
                mValue = 1;
                deviceId = 1000;
                break;
            default:
                break;
        }
        
        if(deviceId != -1 && mValue == 1) {
            int player = [gameContext playerForDevice:deviceId];
            if(player >= 0 && player <= 3) {
                if(ev == GAMEPAD_BUTTON_OK || ev ==  MOUSE_DOWN) {
                    [soundCollector playForImp:[meepleImps objectAtIndex:player] Sound:[soundCollector getSoundId:@"Pickup"]];
                    [playerSelections replaceObjectAtIndex:player withObject:@1];
                } else if (ev == GAMEPAD_BUTTON_CANCEL || ev == ESCAPE) {
                    [soundCollector playForImp:[meepleImps objectAtIndex:player] Sound:[soundCollector getSoundId:@"LaserB"]];
                    [playerSelections replaceObjectAtIndex:player withObject:@2];
                }
            }
        }
    } ];
    
    // translate if ok
    [playerFeedback addListener:^(float sp, NSNumber *event, int message) {
        for(int player = 0; player < 4; player++) {
            if(((NSNumber*)[playerSelections objectAtIndex:player]).intValue == 1)
                [[[meepleImps objectAtIndex:player] translation] setZ:2];
            else
                [[[meepleImps objectAtIndex:player] translation] setZ:-3.5];
        }
    }];
    
    
    // blink if cancel
    [playerFeedback addListener:^(float sp, NSNumber *event, int message) {
        for(int player = 0; player < gameContext.playerNumber; player++) {
            YAImpersonator* meepleImp = [meepleImps objectAtIndex:player];
            if(((NSNumber*)[playerSelections objectAtIndex:player]).intValue == 2)
                [[[meepleImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: sp + 0.5 : sp + 0.5 : sp + 0.5 ]];
            else
                [[[meepleImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
            
        }
    }];
    
    // button animation
    [playerFeedback addListener:^(float sp, NSNumber *event, int message) {
        switch (event.intValue) {
            case MOUSE_DOWN:
                if(message == sensorStart)
                    [buttonStart setState:@"pressed"];
                break;
            case MOUSE_UP:
                [buttonStart setState:@"released"];
                break;
            default:
                break;
        }
    }];
    
    
    // go back ?
    [playerFeedback addListener:^(float sp, NSNumber *event, int message) {
        bool finished = YES;
        startGameState = YES;
        
        for(int player = 0; player < gameContext.playerNumber; player++) {
            int playerstatus = ((NSNumber*)[playerSelections objectAtIndex:player]).intValue;
            if(playerstatus == 0)
                finished = NO;
            else if (playerstatus == 2)
                startGameState = NO;
        }
        
        if(finished) {
            // sendMessage to statemachine
            [_stateMachine nextState];
        }
        
    }];

    [renderLoop setSkyMap:@"LR"];

    [renderLoop freeOpenGLContextFromThread];
    
    [renderLoop resetAnimators];
    [renderLoop setActiveAnimation:true];
    [renderLoop setDrawScene:true];
}

- (void) clearScene
{
    // NSLog(@"Clear Scene");
    
    [soundCollector stopAllSounds];

    [renderLoop setActiveAnimation:false];
    [renderLoop setDrawScene:false];
    [renderLoop removeAllAnimators];
    [renderLoop removeAllImpersonators];
}


- (YAImpersonator*) genText: (NSString*) text
{
    __block int textImpersonatorId;
    textImpersonatorId = [renderLoop createImpersonatorFromText: text];
    YAImpersonator* textImp = [renderLoop getImpersonator:textImpersonatorId];
    
    [[textImp translation] setVector: [[YAVector3f alloc] initVals: 0 : 0 : 0]];
    [textImp resize:0.3];
    [[textImp rotation] setVector: [[YAVector3f alloc] initVals:90: 0 : 0]];
    [[[textImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0 : 0 : 0 ]];
    [[[textImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[textImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[textImp material] setPhongShininess: 20];
    
    [[[textImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.5 : 0.2 : 0.2 ]];
    [textImp setClickable:false];
    
    
    return textImp;
}

- (void) loadModels
{
    YAIngredient* ingredient = [renderLoop createIngredient:@"GameButton"];
    [ingredient setModelWithShader:@"GameButton" shader:@"gourad"];
    ingredient = [renderLoop createIngredient:@"GameButtonSocket"];
    [ingredient setModelWithShader:@"GameButtonSocket" shader:@"gourad"];
    
    ingredient = [renderLoop createIngredient:@"PlayboardTitle"];
    [ingredient setModelWithShader:@"PlayboardTitle" shader:@"ads_texture_normal_spotlight"];
    
    ingredient = [renderLoop createIngredient:@"Gamepad"];
    [ingredient setModelWithShader:@"Gamepad" shader:@"ads_texture_normal_spotlight"];
    
    ingredient = [renderLoop createIngredient:@"Mouse"];
    [ingredient setModelWithShader:@"Mouse" shader:@"ads_texture_normal_spotlight"];

    ingredient = [renderLoop createIngredient:@"Desk"];
    [ingredient setModelWithShader:@"Desk" shader:@"ads_texture_normal_spotlight"];
    
    NSArray* models = [[NSArray alloc] initWithObjects:
                       @"Bonzoid",  @"Flapper",  @"Gollumer",  @"Humanoid",  @"Leggit",  @"Mechatron",  @"Paker", @"Spheroid", nil ];
    
    for(id model in models) {
        ingredient = [renderLoop createIngredient:model];
        [ingredient setModelWithShader:model shader:@"ads_texture_bones"];
        [renderLoop addShapeShifter:model];
    }
    
    models = [[NSArray alloc] initWithObjects:
              @"wheelPointer", @"colorWheelSocket", @"colorWheel", @"barCode",  nil ];
    
    for(id model in models) {
        ingredient = [renderLoop createIngredient:model];
        [ingredient setModelWithShader:model shader:@"ads_texture_spotlight"];
    }
    
    
    ingredient = [renderLoop createIngredient:@"playerColorRing"];
    [ingredient setModelWithShader:@"playerColorRing" shader:@"ads_texture"];
    
    models = [[NSArray alloc] initWithObjects:
              @"BallColorA", @"BallColorB", @"BallColorC", @"BallColorD",
              @"BallColorE", @"BallColorF", @"BallColorG", @"BallColorH" , nil ];
    
    for(id model in models) {
        ingredient = [renderLoop createIngredient:model];
        [ingredient setModelWithShader:model shader:@"billboard"];
    }
    
    // NSLog(@"Done Loading models");
}

- (void) genButton: (int*)sensor group: (YAImpGroup*) button;
{
    int buttonId = [renderLoop createImpersonator:@"GameButton"];
    *sensor = buttonId;
    
    int buttonSocketId = [renderLoop createImpersonator:@"GameButtonSocket"];
    
    YAImpersonator* imp = [renderLoop getImpersonator:buttonId];
    [[[imp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.439 : 0 : 0.02582 ]];
    [[[imp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[imp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.3f : 0.3f : 0.3f ]];
    [[imp material] setPhongShininess: 10.0f];
    [imp setClickable:true];
    
    [[imp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
    
    imp = [renderLoop getImpersonator:buttonSocketId];
    [[[imp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2 : 0.2 : 0.2 ]];
    [[[imp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.6f : 0.6f : 0.4f ]];
    [[[imp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[imp material] setPhongShininess: 20.0f];
    
    [[imp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
    
    [button addImp:[renderLoop getImpersonator:buttonId]];
    [button addImp:[renderLoop getImpersonator:buttonSocketId]];
    
    [button addModifier:@"released" Impersonator:buttonId Modifier:@"translation" Value:[[YAVector3f alloc] initVals: 0: 0.18f : 0]];
    [button addModifier:@"pressed" Impersonator:buttonId Modifier:@"translation" Value:[[YAVector3f alloc] initVals: 0: 0.07f : 0]];
    
    [button setRotation:[[YAVector3f alloc] initVals:0 :0 :0] ];
    [button setSize:[[YAVector3f alloc] initVals:0.7 :0.7 :0.7]];
    [button setState:@"released"];
    
}

@end
