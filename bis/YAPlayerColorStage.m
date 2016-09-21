//
//  YAPlayerColorStage.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 24.07.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//


#import <dispatch/dispatch.h>

#import "YALog.h"
#import "YARenderLoop.h"
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
#import "YAIntroStage.h"
#import "YAImpGroup.h"
#import "YAGameContext.h"

#import "YAPlayerColorStage.h"

@implementation YAPlayerColorStage
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
    
    int wheelPointerId = [renderLoop createImpersonator:@"wheelPointer"];
    YAImpersonator* wheelPointerImp = [renderLoop getImpersonator:wheelPointerId];
    [[wheelPointerImp rotation] setValues:-90 :0 :0];
    [[wheelPointerImp translation] setValues:0 :0.75 :1.3];
    [wheelPointerImp resize:1.0];
    [[[wheelPointerImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2 : 0.2 : 0.2 ]];
    [[[wheelPointerImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.6f : 0.6f : 0.4f ]];
    [[[wheelPointerImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[wheelPointerImp material] setPhongShininess: 20.0f];
    
    
    int colorWheelSocketId = [renderLoop createImpersonator:@"colorWheelSocket"];
    YAImpersonator* colorWheelSocketImp = [renderLoop getImpersonator:colorWheelSocketId];
    [[colorWheelSocketImp rotation] setValues:-90 :0 :0];
    [[colorWheelSocketImp translation] setValues:0 :0.3 :0];
    [colorWheelSocketImp resize:1.0];
    [[[colorWheelSocketImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2 : 0.2 : 0.2 ]];
    [[[colorWheelSocketImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.6f : 0.6f : 0.4f ]];
    [[[colorWheelSocketImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[colorWheelSocketImp material] setPhongShininess: 20.0f];
    
    int colorWheelId = [renderLoop createImpersonator:@"colorWheel"];
    YAImpersonator* colorWheelImp = [renderLoop getImpersonator:colorWheelId];
    [[colorWheelImp rotation] setValues:-90 :0 :0];
    [[colorWheelImp translation] setValues:0 :0.6 :0];
    [colorWheelImp resize:1.0];
    [[[colorWheelImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2 : 0.2 : 0.2 ]];
    [[[colorWheelImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.6f : 0.6f : 0.4f ]];
    [[[colorWheelImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[colorWheelImp material] setPhongShininess: 20.0f];
    
    
    YABasicAnimator* spinWheel = [renderLoop createBasicAnimator];
    [spinWheel setInfluence:Y_AXE];
    [spinWheel setProgress:accelerate];
    [spinWheel setDelay:1.5];
    [spinWheel setOnce:true];
    [spinWheel addListener:[colorWheelImp rotation] factor:-360];
    
    spinWheel = [renderLoop createBasicAnimator];
    [spinWheel setInfluence:Y_AXE];
    [spinWheel setProgress:cyclic];
    [spinWheel setInterval:3.9];
    [spinWheel setDelay:6.5];
    [spinWheel addListener:[colorWheelImp rotation] factor:-360];
    
    
    int playboardId = [renderLoop createImpersonator:@"PlayboardTitle"];
    YAImpersonator* playboardImp = [renderLoop getImpersonator:playboardId];
    [[playboardImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
    [[playboardImp translation] setVector: [[YAVector3f alloc] initVals: 0: 0 : 0]];
    [[[playboardImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4 : 0.4 : 0.4 ]];
    [[[playboardImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[playboardImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [playboardImp resize:3];
    [playboardImp setShadowCaster:false];
    
    for (int i = 0; i <= 3; i ++) {
        int y = i <= 1 ? -4 : 4;
        int x = i % 2 == 0 ? -4 : 4;
        
        int humanoidId = [renderLoop createImpersonatorWithShapeShifter: @"Humanoid"];
        __block YAImpersonator* humanoidImp = [renderLoop getImpersonator:humanoidId];
        
        [humanoidImp resize:0.50];
        [humanoidImp setVisible:true];
        [[humanoidImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :0 :0] ];
        [[humanoidImp translation] setVector:[[YAVector3f alloc] initVals:x :0 :y] ];
        [[[humanoidImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
        [[[humanoidImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
        [[[humanoidImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
        [[humanoidImp material] setPhongShininess: 20];
        
        __block YAHumanoidMover* humanoidMover = [[YAHumanoidMover alloc] initWithImp:humanoidImp inWorld:renderLoop];
        [humanoidMover setActive:walk];
    }
    
    
    __block NSMutableArray* playerColorRings = [[NSMutableArray alloc] init];
    for (int i = 0; i <= 3; i++) {
        int y = i <= 1 ? -4 : 4;
        int x = i % 2 == 0 ? -4 : 4;
        
        int playerColorRingId = [renderLoop createImpersonatorWithShapeShifter: @"playerColorRing"];
        YAImpersonator* playerColorRingImp = [renderLoop getImpersonator:playerColorRingId];
        [playerColorRings addObject:playerColorRingImp];
        
        [[playerColorRingImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :0 :0] ];
        [[playerColorRingImp translation] setVector:[[YAVector3f alloc] initVals:x  :0.076 :y] ];
        [playerColorRingImp resize: 0.9];
        
        if(i <  gameContext.playerNumber)
            [[[playerColorRingImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 1.0 : 1.0 : 1.0 ]];
        else
            [[[playerColorRingImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.0 : 0.0 : 0.0 ]];
        
        [[[playerColorRingImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
        [[[playerColorRingImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
        [[playerColorRingImp material] setPhongShininess: 20];
    }
    
    
    for (int i = 0; i <= 3; i++) {
        float y = i <= 1 ? -5.5f : 2.5;
        float x = i % 2 == 0 ? -5.5 : 2.5;
        
        YAImpersonator* textPlayerImp = nil;
        
        if(i < gameContext.playerNumber)
            textPlayerImp =[self genText:[NSString stringWithFormat:@"Player  %d",i + 1]];
        else {
            textPlayerImp =[self genText:[NSString stringWithFormat:@"Bot  %d",i - gameContext.playerNumber + 1]];
            x += 0.6;
            
        }
        textPlayerImp.material.eta = 0;
        [textPlayerImp resize:0.5];
        [[[textPlayerImp material] phongAmbientReflectivity] setValues:0.6 :0.1 :0.1];
        [[textPlayerImp translation] setValues:x :0.09 :y];
    }
    
    
    NSArray* ballies = [[NSArray alloc] initWithObjects:
                        @"BallColorA", @"BallColorB", @"BallColorC", @"BallColorD",
                        @"BallColorE", @"BallColorF", @"BallColorG", @"BallColorH" , nil ];
    
    __block NSMutableArray* ballImps = [[NSMutableArray alloc] init];
    
    for(NSString* ballName in ballies) {
        
        int ballId = [renderLoop createImpersonator: ballName];
        YAImpersonator* ballImp = [renderLoop getImpersonator:ballId];
        [ballImps addObject:ballImp];
        [ballImp resize:0.8];
        [ballImp setVisible:false];
        [[ballImp translation] setVector:[[YAVector3f alloc] initVals:0 :0.9 :0] ];
    }
    
    
    __block int ballColor = -1;
    YABlockAnimator* ballColorChanger = [renderLoop createBlockAnimator];
    
    [ballColorChanger setProgress:harmonic];
    [ballColorChanger setInterval:0.5];
    [ballColorChanger addListener:^(float sp, NSNumber *event, int message) {
        
        float spinRotation = colorWheelImp.rotation.y;
        spinRotation += 25.0;
        
        if(spinRotation > 0)
            spinRotation = -360 + spinRotation;
        
        ballColor = 7 + (int)(  ( spinRotation  / 360.0)   * 8.0);
        
        if(![gameContext colorAvailable:ballColor])
            ballColor = -1;
        
        for(int i = 0; i < 8; i++) {
            YAImpersonator* bi = [ballImps objectAtIndex:i];
            if(i == ballColor) {
                [bi setVisible:true];
                [[bi translation] setY:0.9 + sp / 5];
            }
            else
                [bi setVisible:false];
        }
    }];
    
    YABlockAnimator* userSelection = [renderLoop createBlockAnimator];
    [userSelection addListener:^(float sp, NSNumber *event, int message) {
        
        event_keyPressed ev = (event_keyPressed) event.intValue;
        
        int mValue = 0;
        int deviceId = -1;
        
        if (ev == GAMEPAD_BUTTON_OK) {
            mValue = message & 255;
            deviceId = message >> 16;
        } else if (ev == MOUSE_DOWN) {
            mValue = 1;
            deviceId = 1000;
        }
        
        if(mValue == 1 && deviceId != -1 && ballColor != -1) {
            
            [soundCollector playForImp:colorWheelImp Sound:[soundCollector getSoundId:@"Pickup"]];
            
            int player = [gameContext playerForDevice:deviceId];
            
            if([gameContext getColorForPlayer:player] == -1 && ballColor != -1) {
                [gameContext setColor:ballColor forPlayer:player];
                [[[playerColorRings[player] material] phongAmbientReflectivity] setVector: [[gameContext colorVectors] objectAtIndex:ballColor ]];
            }
        }
    }];
    
    __block bool once = false;
    [userSelection addListener:^(float sp, NSNumber *event, int message) {
        
        if(!once && gameContext.allPlayerColorsAssigned) {
            once = true;
            for(int bot = 0; bot <= 3; bot++) {
                if([gameContext getColorForPlayer:bot] == -1) {
                    for(int cl = 0; cl <= 7; cl++) {
                        if([gameContext colorAvailable:cl]) {
                            [gameContext setColor:cl forPlayer:bot];
                            [[[playerColorRings[bot] material] phongAmbientReflectivity] setVector: [[gameContext colorVectors] objectAtIndex:cl]];
                            break;  // TODO: ARRGHHH.
                        }
                    }
                }
            }
            [_stateMachine nextState];
        }
        
    }];
    
    
    __block  YAImpersonator* textTitleImp = [self genText:[YALog decode:@"ColorChoice"]];
    [textTitleImp resize:0.4];
    [[[textTitleImp material] phongAmbientReflectivity] setValues:0.9 :0.1 :0.2];
    textTitleImp.material.eta = 0.7;
    
    __block  YAImpersonator* textHiPlaneteersImp = [self genText:[YALog decode:@"PressButton"]];
    [textHiPlaneteersImp resize:0.15];
    [[[textHiPlaneteersImp material] phongAmbientReflectivity] setValues:0.0 :0.0 :1.0];
    textHiPlaneteersImp.material.eta = 0.0;

    
    
    YABlockAnimator* alignToCam = [renderLoop createBlockAnimator];
    [alignToCam setProgress:harmonic];
    [alignToCam addListener:^(float sp, NSNumber *event, int message) {
        
        YAVector3f* position = [[YAVector3f alloc] initVals:-1.5 :0.9 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textTitleImp translation] setVector: position];
        [[textTitleImp rotation] setX: [avatar headAtlas]];
        [[textTitleImp rotation] setY: -[avatar headAxis]];
        
        // -------------------
        
        position = [[YAVector3f alloc] initVals:-0.7 :-0.5 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textHiPlaneteersImp translation] setVector: position];
        [[textHiPlaneteersImp rotation] setX: [avatar headAtlas]];
        [[textHiPlaneteersImp rotation] setY: -[avatar headAxis]];
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

    
    NSArray* models = [[NSArray alloc] initWithObjects: @"Humanoid", nil ];
    
    for(id model in models) {
        ingredient = [renderLoop createIngredient:model];
        [ingredient setModelWithShader:model shader:@"ads_texture_bones"];
        [renderLoop addShapeShifter:model];
    }
    
    models = [[NSArray alloc] initWithObjects:
              @"wheelPointer", @"colorWheelSocket", @"colorWheel", nil ];
    
    for(id model in models) {
        ingredient = [renderLoop createIngredient:model];
        [ingredient setModelWithShader:model shader:@"ads_texture_spotlight"];
    }
    
    
    ingredient = [renderLoop createIngredient:@"playerColorRing"];
    [ingredient setModelWithShader:@"playerColorRing" shader:@"ads_texture"];
    
    models = [[NSArray alloc] initWithObjects:
              @"BallColorA", @"BallColorB", @"BallColorC", @"BallColorD", @"BallColorE", @"BallColorF", @"BallColorG", @"BallColorH" , nil ];
    
    for(id model in models) {
        ingredient = [renderLoop createIngredient:model];
        [ingredient setModelWithShader:model shader:@"billboard"];
    }

     // NSLog(@"Done loading models"); 
}

@end
