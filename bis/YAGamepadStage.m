//
//  YAGamepadStage.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 23.07.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YALog.h"
#import "YASoundCollector.h"
#import "YAGameStateMachine.h"
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
#import "YAGameContext.h"

#import "YAGamepadStage.h"

@implementation YAGamepadStage
@synthesize gameContext;

- (id) initWithWorld: (YARenderLoop*) world StateMachine: (YAGameStateMachine*) stateMachine
{
    self = [super init];
    
    if(self) {
        renderLoop = world;
        _stateMachine = stateMachine;
    }
    return self;
}


- (void) setupScene
{
    // NSLog(@"Setup Scene");


   [renderLoop setOpenGLContextToThread];

    soundCollector = _stateMachine.soundCollector;
    
    _restartGame = false;
    
    [self loadModels];
    
    [renderLoop setTraceMouseMove:YES];
    
    __block YAAvatar* avatar = [renderLoop avatar];
    [avatar setPosition: [[YAVector3f alloc] initVals:0.0f :8.0f :-14.0f ]];
    [avatar setAtlas:34.0f axis:00.0f];
    
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
    



    
    
    __block NSMutableArray* gamepadImps = [[NSMutableArray alloc] initWithCapacity:4];
    for(int i = 0; i <= 3; i++) {
        int gamepadId = [renderLoop createImpersonator:@"Gamepad"];
        YAImpersonator* gamepadImp = [renderLoop getImpersonator:gamepadId];
        [[gamepadImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
        [[gamepadImp translation] setVector: [[YAVector3f alloc] initVals: -2: 0.5 : -4]];
        [[[gamepadImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4 : 0.4 : 0.4 ]];
        [[[gamepadImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
        [[[gamepadImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
        [gamepadImp resize:0.5];
        [gamepadImp setShadowCaster:true];
        [gamepadImp setVisible:false];
        [gamepadImps addObject:gamepadImp];
    }
    
    int mouseId = [renderLoop createImpersonator:@"Mouse"];
    YAImpersonator* mouseImp = [renderLoop getImpersonator:mouseId];
    [[mouseImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
    [[mouseImp translation] setVector: [[YAVector3f alloc] initVals: 2: 0.5 : -4]];
    [[[mouseImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4 : 0.4 : 0.4 ]];
    [[[mouseImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[mouseImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [mouseImp resize:0.5];
    [mouseImp setShadowCaster:true];
    [mouseImp setVisible:false];
    
    // --------------- Text --------------------

    __block  YAImpersonator* textTitleImp = [self genText:[YALog decode:@"Controls"]];
    [textTitleImp resize:0.5];
    [[[textTitleImp material] phongAmbientReflectivity] setValues:0.9 :0.1 :0.2];
    textTitleImp.material.eta = 0.7;

    __block  YAImpersonator* textHiPlaneteersImp = [self genText:[YALog decode:@"EachPlanateer"]];
    [textHiPlaneteersImp resize:0.2];
    [[[textHiPlaneteersImp material] phongAmbientReflectivity] setValues:0.0 :0.0 :1.0];
    textHiPlaneteersImp.material.eta = 0;
    
    
    __block  YAImpersonator* textTipImp = [self genText:[YALog decode:@"PressYourGamepad"]];
    [textTipImp resize:0.2];
    [[[textTipImp material] phongAmbientReflectivity] setValues:0.9 :0.1 :0.2];
    textTipImp.material.eta = 0;

    
    // -----------------------------------
    
    YABlockAnimator* rotateCam = [renderLoop createBlockAnimator];
    [rotateCam setProgress:harmonic];
    [rotateCam addListener:^(float sp, NSNumber *event, int message) {
        [avatar setPosition: [[YAVector3f alloc] initVals:0.0f :8.0f + sp :-14.0f ]];
        [avatar setAtlas:34.0f + sp * 2 axis:00.0f];
    }];
    
    
    YABlockAnimator* alignToCam = [renderLoop createBlockAnimator];
    [alignToCam setProgress:harmonic];
    [alignToCam addListener:^(float sp, NSNumber *event, int message) {
        
        YAVector3f* position = [[YAVector3f alloc] initVals:-1.25 :0.9 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textTitleImp translation] setVector: position];
        [[textTitleImp rotation] setX: [avatar headAtlas]];
        [[textTitleImp rotation] setY: -[avatar headAxis]];
        
        // -------------------
        
        position = [[YAVector3f alloc] initVals:-1.0 :0.1 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textHiPlaneteersImp translation] setVector: position];
        [[textHiPlaneteersImp rotation] setX: [avatar headAtlas]];
        [[textHiPlaneteersImp rotation] setY: -[avatar headAxis]];
        
        // -------------------
        
        position = [[YAVector3f alloc] initVals:-1.2 :-0.2 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textTipImp translation] setVector: position];
        [[textTipImp rotation] setX: [avatar headAtlas]];
        [[textTipImp rotation] setY: -[avatar headAxis]];
        
    }];
    
    
    
    __block NSMutableArray* playerColorRings = [[NSMutableArray alloc] init];
    for (int i = 0; i <= 3; i++) {
        int playerColorRingId = [renderLoop createImpersonatorWithShapeShifter: @"playerColorRing"];
        YAImpersonator* playerColorRingImp = [renderLoop getImpersonator:playerColorRingId];
        [playerColorRings addObject:playerColorRingImp];
        
        [[playerColorRingImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :0 :0] ];
        [playerColorRingImp setBackfaceCulling:false];
        [[playerColorRingImp translation] setVector:[[YAVector3f alloc] initVals:-3 + (i * 2.2)  :0.076 :0] ];
        [playerColorRingImp resize: 0.9];
        
        if(i <  gameContext.playerNumber)
            [[[playerColorRingImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 1.0 : 1.0 : 0.0 ]];
        else
            [[[playerColorRingImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 1.0 : 0.0 : 0.0 ]];
        
        [[[playerColorRingImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
        [[[playerColorRingImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
        [[playerColorRingImp material] setPhongShininess: 20];
        
        
    }
    
    __block int lastPlayerSelection = 0;
    __block int deviceNumber = -1;
    YABlockAnimator* enableInputDevices = [renderLoop createBlockAnimator];
    [enableInputDevices addListener:^(float sp, NSNumber *event, int message) {
        const int actualDevNum = [renderLoop getGamePadNum];
        
        
        // Device was disabled // resetselection
        if(deviceNumber > actualDevNum) {
            deviceNumber = -1;
            lastPlayerSelection = 0;
            [gameContext clearAllDevices];
            
            // clear color rings and reset gamepad  / mouse Pos
            [[mouseImp translation] setZ: -4];
            for (int i = 0; i <= 3; i++) {
                YAImpersonator* imp = [gamepadImps objectAtIndex:i];
                [[imp translation] setZ: -4];
                YAImpersonator* playerColorRingImp = [playerColorRings objectAtIndex:i];
                if(i <  gameContext.playerNumber)
                    [[[playerColorRingImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 1.0 : 1.0 : 0.0 ]];
                else
                    [[[playerColorRingImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 1.0 : 0.0 : 0.0 ]];
            }
        }
        
        if(deviceNumber != actualDevNum) {
            
            for(int i = 0; i <= 3; i++) {
                if(actualDevNum > i)
                    [[gamepadImps objectAtIndex:i]setVisible:YES];
                else
                    [[gamepadImps objectAtIndex:i]setVisible:NO];
            }
            
            // mouse is alway visible
            [mouseImp setVisible:YES];
            
            float offset = ((float)(actualDevNum + 1.0) * 2.5) * - 0.35;
            
            for(int i = 0; i <= actualDevNum; i++) { // + mouse
                [[[gamepadImps objectAtIndex:i]translation] setX:offset + i * 2.5 ];
                if(i == actualDevNum)
                    [[mouseImp translation] setX:offset + (i * 2.5) ];
            }
            
            deviceNumber = actualDevNum;
        }
        
    }];
    
    YABlockAnimator* reactInputDevices = [renderLoop createBlockAnimator];
    [reactInputDevices addListener:^(float sp, NSNumber *event, int message) {
        int ev = event.intValue;
        if(ev >= 5 && ev <= 12) {
            const float mValue = ((float)(message & 255) / 255) - 0.5;
            int deviceId = message >> 16;
            
            const int MAGIC = 100; // gamepad id offset
            YAImpersonator* gamepadImp = gamepadImps[deviceId - MAGIC];
            if (event.intValue == GAMEPAD_LEFT_X ) {
                [[gamepadImp rotation] setValues: gamepadImp.rotation.x :gamepadImp.rotation.y :-mValue * 25];
            } else if (event.intValue == GAMEPAD_LEFT_Y ) {
                [[gamepadImp rotation] setValues: -90 - mValue * 25 :gamepadImp.rotation.y :gamepadImp.rotation.z];
            }
        } else if (event.intValue ==MOUSE_MOVE_X ) {
            [[mouseImp rotation] setValues:mouseImp.rotation.x :mouseImp.rotation.y :-message];
        } else if (event.intValue ==MOUSE_MOVE_Y ) {
            [[mouseImp rotation] setValues:-90 + message :mouseImp.rotation.y :mouseImp.rotation.z];
            
        }
    }];
    
    
    
    for(int i = 0; i <= 3; i++) {
        
        int humanoidId = [renderLoop createImpersonatorWithShapeShifter: @"Humanoid"];
        __block YAImpersonator* humanoidImp = [renderLoop getImpersonator:humanoidId];
        
        [humanoidImp resize:0.50];
        [humanoidImp setVisible:true];
        [[humanoidImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :0 :0] ];
        [[humanoidImp translation] setVector:[[YAVector3f alloc] initVals:-3.0 + (i * 2.2)  :0 :0] ];
        [[[humanoidImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
        [[[humanoidImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
        [[[humanoidImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
        [[humanoidImp material] setPhongShininess: 20];
        
        __block YAHumanoidMover* humanoidMover = [[YAHumanoidMover alloc] initWithImp:humanoidImp inWorld:renderLoop];
        [humanoidMover setActive:walk];
        
    }
    
    YABlockAnimator* selectionMade = [renderLoop createBlockAnimator];
    [selectionMade addListener:^(float sp, NSNumber *event, int message) {
        
        int ev = event.intValue;
        if(ev == GAMEPAD_BUTTON_OK && lastPlayerSelection < 3 ) {
            const int mValue = message & 255;
            const int deviceId = message >> 16;
            const int player = [gameContext playerForDevice:deviceId];
            if(player == -1 && mValue == 1) {
                YAImpersonator* playerColorRingImp = [playerColorRings objectAtIndex:lastPlayerSelection];
                [[[playerColorRingImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.0 : 1.0 : 0.0 ]];
                [gameContext setDeviceId:deviceId forPlayer:lastPlayerSelection];
                lastPlayerSelection++;
                
                int MAGIC = 100;
                YAImpersonator* gcImp = [gamepadImps objectAtIndex:deviceId - MAGIC];
                [[gcImp translation] setZ:2];
                
                [soundCollector playForImp:playerColorRingImp Sound:[soundCollector getSoundId:@"Pickup"]];
            }
            
        } else if(ev == MOUSE_DOWN ) {
            // using ID 1000 for mouse
            int deviceId = 1000;
            const int player = [gameContext playerForDevice:deviceId];
            if(player == -1 ) {
                YAImpersonator* playerColorRingImp = [playerColorRings objectAtIndex:lastPlayerSelection];
                [[[playerColorRingImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.0 : 1.0 : 0.0 ]];
                [gameContext setDeviceId:deviceId forPlayer:lastPlayerSelection];
                lastPlayerSelection++;
                
                [[mouseImp translation] setZ:2];
                
                [soundCollector playForImp:playerColorRingImp Sound:[soundCollector getSoundId:@"Pickup"]];
            }
        } else if (ev == ESCAPE) {
            // NSLog(@"Escape");
            [_stateMachine.soundCollector stopAllSounds];
            _restartGame = true;
            [_stateMachine nextState];
        }
        
    }];
    
    __block bool once = false;
    YABlockAnimator* selectionDone = [renderLoop createBlockAnimator];
    [selectionDone addListener:^(float sp, NSNumber *event, int message) {
        if(!once && gameContext.allInputDevicesAssigned) {
            once = true;
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
    [renderLoop setTraceMouseMove:NO];
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
    
    return textImp;
}

- (void) loadModels
{
    YAIngredient* ingredient;

    ingredient = [renderLoop createIngredient:@"Gamepad"];
    [ingredient setModelWithShader:@"Gamepad" shader:@"ads_texture_normal_spotlight"];

    ingredient = [renderLoop createIngredient:@"GameButton"];
    [ingredient setModelWithShader:@"GameButton" shader:@"gourad"];

    ingredient = [renderLoop createIngredient:@"GameButtonSocket"];
    [ingredient setModelWithShader:@"GameButtonSocket" shader:@"gourad"];
    
    ingredient = [renderLoop createIngredient:@"PlayboardTitle"];
    [ingredient setModelWithShader:@"PlayboardTitle" shader:@"ads_texture_normal_spotlight"];
    
    
    ingredient = [renderLoop createIngredient:@"Mouse"];
    [ingredient setModelWithShader:@"Mouse" shader:@"ads_texture_normal_spotlight"];

    ingredient = [renderLoop createIngredient:@"Desk"];
    [ingredient setModelWithShader:@"Desk" shader:@"ads_texture_normal_spotlight"];
    
    NSArray* models = [[NSArray alloc] initWithObjects: @"Humanoid", nil ];
    
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
    [ingredient setModelWithShader:@"playerColorRing" shader:@"billboard_3d"];
    
    models = [[NSArray alloc] initWithObjects:
              @"BallColorA", @"BallColorB", @"BallColorC", @"BallColorD",
              @"BallColorE", @"BallColorF", @"BallColorG", @"BallColorH" , nil ];
    
    for(id model in models) {
        ingredient = [renderLoop createIngredient:model];
        [ingredient setModelWithShader:model shader:@"billboard"];
    }
    
    // NSLog(@"Done Loading models");
}

@end
