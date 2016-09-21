//
//  YASpeciesStage.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 26.07.12.
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

#import "YASpeciesStage.h"

@implementation YASpeciesStage
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
    
    NSArray* speciesDocs = [[NSArray alloc]
                            initWithObjects:[YALog decode:@"BonzoidDocs"],
                            [YALog decode:@"FlapperDocs"],
                            [YALog decode:@"GollumerDocs"],
                            [YALog decode:@"HumanoidDocs"],
                            [YALog decode:@"LeggitDocs"],
                            [YALog decode:@"MechatronDocs"],
                            [YALog decode:@"PakerDocs"],
                            [YALog decode:@"SpheroidDocs"],
                            nil ];
    
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
    
    __block  YAImpersonator* textTitleImp = [self genText:[YALog decode:@"PickYourSpecies"]];
    [textTitleImp resize:0.32];
    [[[textTitleImp material] phongAmbientReflectivity] setValues:0.9 :0.1 :0.2];
    
    __block  YAImpersonator* textIntroImp = [self genText:[YALog decode:@"useYourJoystick"]];
    [textIntroImp resize:0.15];
    [[[textIntroImp material] phongAmbientReflectivity] setValues:1.0 :0.9 :0.1];
    [textIntroImp setClickable:false];
    textTitleImp.material.eta = 0.7;

    
    __block  YAImpersonator* textPlayerImp = [self genText:@"Player  1"];
    [textPlayerImp resize:0.15];
    [[[textPlayerImp material] phongAmbientReflectivity] setValues:1.0 :0.0 :0.0];
    [textPlayerImp setClickable:false];
    textPlayerImp.material.eta = 0;
    
    
    __block  YAImpersonator* textHiPlaneteersImp = [self genText:[YALog decode:@"PressButton"]];
    [textHiPlaneteersImp resize:0.15];
    [[[textHiPlaneteersImp material] phongAmbientReflectivity] setValues:0.0 :0.0 :1.0];
    textHiPlaneteersImp.material.eta = 0;
    
    __block  YAImpersonator* meepleTitleImp = [self genText:@"Bonzoid"];
    [meepleTitleImp resize:0.15];
    [[[meepleTitleImp material] phongAmbientReflectivity] setValues:0.0 :0.0 :1.0];
    [meepleTitleImp setVisible:false];
    meepleTitleImp.material.eta = 0;
    
    __block  YAImpersonator* speciesDescriptionImp = [self genText:@"Docs"];
    [speciesDescriptionImp resize:0.15];
    [[[speciesDescriptionImp material] phongAmbientReflectivity] setValues:1.0 :0.9 :0.1];
    [speciesDescriptionImp setVisible:false];
    [speciesDescriptionImp setClickable:false];
    speciesDescriptionImp.material.eta = 0;
    
    YABlockAnimator* alignToCam = [renderLoop createBlockAnimator];
    [alignToCam setInterval:1.0];
    [alignToCam setProgress:harmonic];
    [alignToCam addListener:^(float sp, NSNumber *event, int message) {
        
        YAVector3f* position = [[YAVector3f alloc] initVals:-1.5 :1.0 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textTitleImp translation] setVector: position];
        [[textTitleImp rotation] setX: [avatar headAtlas]];
        [[textTitleImp rotation] setY: -[avatar headAxis]];
        
        // -------------------
        
        position = [[YAVector3f alloc] initVals:-0.7 :0.7 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textIntroImp translation] setVector: position];
        [[textIntroImp rotation] setX: [avatar headAtlas]];
        [[textIntroImp rotation] setY: -[avatar headAxis]];
        
        // -------------------
        
        position = [[YAVector3f alloc] initVals:-0.7 :-0.7 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textPlayerImp translation] setVector: position];
        [[textPlayerImp rotation] setX: [avatar headAtlas]];
        [[textPlayerImp rotation] setY: -[avatar headAxis]];
        [[[textPlayerImp material] phongAmbientReflectivity] setValues:sp + 0.5 :0 :0.0];
        
        // -------------------
        
        position = [[YAVector3f alloc] initVals:-0.4 :0.7 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[meepleTitleImp translation] setVector: position];
        [[meepleTitleImp rotation] setX: [avatar headAtlas]];
        [[meepleTitleImp rotation] setY: -[avatar headAxis]];
        
        // -------------------
        
        position = [[YAVector3f alloc] initVals:-1.2 :0.4 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[speciesDescriptionImp translation] setVector: position];
        [[speciesDescriptionImp rotation] setX: [avatar headAtlas]];
        [[speciesDescriptionImp rotation] setY: -[avatar headAxis]];
        
        
        // -------------------
        
        position = [[YAVector3f alloc] initVals:-0.7 :-0.9 :5];
        position = [position rotate:[avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[avatar position]];
        
        [[textHiPlaneteersImp translation] setVector: position];
        [[textHiPlaneteersImp rotation] setX: [avatar headAtlas]];
        [[textHiPlaneteersImp rotation] setY: -[avatar headAxis]];
    }];
    
    
    int mechatronId = [renderLoop createImpersonatorWithShapeShifter: @"Mechatron"];
    __block YAImpersonator* mechatronImp = [renderLoop getImpersonator:mechatronId];
    [mechatronImp resize:0.22];
    [mechatronImp setVisible:true];
    [[mechatronImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :0 :0] ];
    [[mechatronImp translation] setVector:[[YAVector3f alloc] initVals:-4  :0 :4] ];
    [[[mechatronImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[mechatronImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[mechatronImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[mechatronImp material] setPhongShininess: 20];
    __block YAMechatronMover* mechatronMover = [[YAMechatronMover alloc] initWithImp:mechatronImp inWorld:renderLoop];
    [mechatronMover setActive:none];
    [mechatronImp setClickable:true];

    
    int gollumerId = [renderLoop createImpersonatorWithShapeShifter: @"Gollumer"];
    __block YAImpersonator* gollumerImp = [renderLoop getImpersonator:gollumerId];
    [gollumerImp resize:0.17];
    [gollumerImp setVisible:true];
    [[gollumerImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :0 :0] ];
    [[gollumerImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :4] ];
    [[[gollumerImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[gollumerImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[gollumerImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[gollumerImp material] setPhongShininess: 20];
    __block YAGollumerMover* gollumerMover = [[YAGollumerMover alloc] initWithImp:gollumerImp inWorld:renderLoop];
    [gollumerMover setActive:none];
    [gollumerImp setClickable:true];
    
    int pakerId = [renderLoop createImpersonatorWithShapeShifter: @"Paker"];
    __block YAImpersonator* pakerImp = [renderLoop getImpersonator:pakerId];
    [pakerImp resize:0.22];
    [pakerImp setVisible:true];
    [[pakerImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :0 :0] ];
    [[pakerImp translation] setVector:[[YAVector3f alloc] initVals:4  :0 :4] ];
    [[[pakerImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[pakerImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[pakerImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[pakerImp material] setPhongShininess: 20];
    __block YAPackerMover* pakerMover = [[YAPackerMover alloc] initWithImp:pakerImp inWorld:renderLoop];
    [pakerMover setActive:none];
    [pakerImp setClickable:true];
    
    int bonzoidId = [renderLoop createImpersonatorWithShapeShifter: @"Bonzoid"];
    __block YAImpersonator* bonzoidImp = [renderLoop getImpersonator:bonzoidId];
    [bonzoidImp resize:0.22];
    [bonzoidImp setVisible:true];
    [[bonzoidImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :0 :0] ];
    [[bonzoidImp translation] setVector:[[YAVector3f alloc] initVals:-4  :0 :0] ];
    [[[bonzoidImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[bonzoidImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[bonzoidImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[bonzoidImp material] setPhongShininess: 20];
    __block YABonzoidMover* bonzoidMover = [[YABonzoidMover alloc] initWithImp:bonzoidImp inWorld:renderLoop];
    [bonzoidMover setActive:none];
    [bonzoidImp setClickable:true];
    
    int spheroidId = [renderLoop createImpersonatorWithShapeShifter: @"Spheroid"];
    __block YAImpersonator* spheroidImp = [renderLoop getImpersonator:spheroidId];
    [spheroidImp resize:0.3];
    [spheroidImp setVisible:true];
    [[spheroidImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :0 :0] ];
    [[spheroidImp translation] setVector:[[YAVector3f alloc] initVals:4  :0 :0] ];
    [[[spheroidImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[spheroidImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[spheroidImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[spheroidImp material] setPhongShininess: 20];
    __block YASpheroidMover* spheroidMover = [[YASpheroidMover alloc] initWithImp:spheroidImp inWorld:renderLoop];
    [spheroidMover setActive:none];
     [spheroidImp setClickable:true];
    
    int flapperId = [renderLoop createImpersonatorWithShapeShifter: @"Flapper"];
    __block YAImpersonator* flapperImp = [renderLoop getImpersonator:flapperId];
    [flapperImp resize:0.17];
    [flapperImp setVisible:true];
    [[flapperImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :0 :0] ];
    [[flapperImp translation] setVector:[[YAVector3f alloc] initVals:-4  :0 :-4] ];
    [[[flapperImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[flapperImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[flapperImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[flapperImp material] setPhongShininess: 20];
    __block YAFlapperMover* flapperMover = [[YAFlapperMover alloc] initWithImp:flapperImp inWorld:renderLoop];
    [flapperMover setActive:none];
    [flapperImp setClickable:true];
    
    
    int leggitId = [renderLoop createImpersonatorWithShapeShifter: @"Leggit"];
    __block YAImpersonator* leggitImp = [renderLoop getImpersonator:leggitId];
    [leggitImp resize:0.19];
    [leggitImp setVisible:true];
    [[leggitImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :0 :0] ];
    [[leggitImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :-4] ];
    [[[leggitImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[leggitImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[leggitImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[leggitImp material] setPhongShininess: 20];
    __block YALeggitMover* leggitMover = [[YALeggitMover alloc] initWithImp:leggitImp inWorld:renderLoop];
    [leggitMover setActive:none];
    [leggitImp setClickable:true];
    
    int humanoidId = [renderLoop createImpersonatorWithShapeShifter: @"Humanoid"];
    __block YAImpersonator* humanoidImp = [renderLoop getImpersonator:humanoidId];
    [humanoidImp resize:0.70];
    [humanoidImp setVisible:true];
    [[humanoidImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :0 :0] ];
    [[humanoidImp translation] setVector:[[YAVector3f alloc] initVals:4  :0 :-4] ];
    [[[humanoidImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[humanoidImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[humanoidImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[humanoidImp material] setPhongShininess: 20];
    __block YAHumanoidMover* humanoidMover = [[YAHumanoidMover alloc] initWithImp:humanoidImp inWorld:renderLoop];
    [humanoidMover setActive:none];
    [humanoidImp setClickable:true];
    
    
    // controller select
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
        [ballImp setShadowCaster:NO];
        [[ballImp translation] setVector:[[YAVector3f alloc] initVals:0 :3 :0] ];
    }
    
    __block int activePlayer = -1;
    __block bool nextPlayer = true;
    __block int ballColor = 0;
    __block float manhattenDist = 0;
    __block YAImpersonator* activeImp = nil;
    __block YAImpersonator* changeDetectionImp = nil;

    
    YABlockAnimator* meepleSelect = [renderLoop createBlockAnimator];
    [meepleSelect setInterval:10.0];
    
    
    // for pad
    [meepleSelect addListener:^(float sp, NSNumber *event, int message) {
        
        if([gameContext deviceIdforPlayer:activePlayer] == 1000)
            return; // don't care
        
        YAImpersonator* ballImp = [ballImps objectAtIndex:ballColor];
        [ballImp setVisible:true];
        
        int deviceId = -1;
        event_keyPressed ev = (event_keyPressed)event.intValue;
        if(ev == GAMEPAD_BUTTON_OK) {
            int mValue = message & 255;
            deviceId = message >> 16;
            if(deviceId == [gameContext deviceIdforPlayer:activePlayer] && activeImp != nil && mValue == 1){
                [soundCollector playForImp:activeImp Sound:[soundCollector getSoundId:@"Pickup"]];
                nextPlayer = true;
            }
            return; // Goodby
            
        } else if(ev == GAMEPAD_LEFT_X) {
            int mValue = message & 255;
            deviceId = message >> 16;
            float cPos = (((float)mValue / 255.0) - 0.5) * 8.0;
            if(deviceId == [gameContext deviceIdforPlayer:activePlayer]) [[ballImp translation]setX: cPos];
        } else if(ev == GAMEPAD_LEFT_Y) {
            int mValue = message & 255;
            deviceId = message >> 16;
            float cPos = -(((float)mValue / 255.0) - 0.5) * 8.0;
            if(deviceId == [gameContext deviceIdforPlayer:activePlayer]) [[ballImp translation]setZ: cPos];
        }
        
        
        if(deviceId == [gameContext deviceIdforPlayer:activePlayer]) {
            
            const float margin = 1.8;
            const float xCp = ballImp.translation.x;
            const float yCp = ballImp.translation.z;
            
            float mh = fabs(xCp) + fabs(yCp);
            
            if(mh < manhattenDist) {
                manhattenDist = mh;
                return;
            }
            
            manhattenDist = mh;
            
            bool drs[] = {false,false,false,false};
            
            if(yCp <= -margin)
                drs[1] = true;
            else if (yCp >= margin)
                drs[0] = true;
            
            if(xCp <= -margin)
                drs[2] = true;
            else if(xCp >= +margin)
                drs[3] = true;
            
            
            if(drs[0] || drs[1] || drs[2] || drs[3]) {
                
                [textIntroImp setVisible:false];
                [meepleTitleImp setVisible:true];
                [speciesDescriptionImp setVisible:true];
                
                [[mechatronImp translation] setVector:[[YAVector3f alloc] initVals:-4  :0 :4] ];
                [[gollumerImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :4] ];
                [[pakerImp translation] setVector:[[YAVector3f alloc] initVals:4  :0 :4] ];
                [[bonzoidImp translation] setVector:[[YAVector3f alloc] initVals:-4  :0 :0] ];
                [[spheroidImp translation] setVector:[[YAVector3f alloc] initVals:4  :0 :0] ];
                [[flapperImp translation] setVector:[[YAVector3f alloc] initVals:-4  :0 :-4] ];
                [[leggitImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :-4] ];
                [[humanoidImp translation] setVector:[[YAVector3f alloc] initVals:4  :0 :-4] ];
                
                [[mechatronImp rotation] setY:0];
                [[gollumerImp rotation] setY:0];
                [[pakerImp rotation] setY:0];
                [[bonzoidImp rotation] setY:0];
                [[spheroidImp rotation] setY:0];
                [[flapperImp rotation] setY:0];
                [[leggitImp rotation] setY:0];
                [[humanoidImp rotation] setY:0];
                
                [mechatronMover setActive:none];
                [gollumerMover setActive:none];
                [pakerMover setActive:none];
                [bonzoidMover setActive:none];
                [spheroidMover setActive:none];
                [flapperMover setActive:none];
                [leggitMover setActive:none];
                [humanoidMover setActive:none];


                if(!drs[0] && !drs[1] && drs[2] && !drs[3]) {
                    [[bonzoidImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :0] ];
                    [bonzoidMover setActive:walk];
                    [renderLoop updateTextIngredient:@"Bonzoid" Impersomator:meepleTitleImp];
                    if( activeImp != bonzoidImp) [renderLoop updateTextIngredient:[speciesDocs objectAtIndex:0] Impersomator:speciesDescriptionImp];
                    activeImp = bonzoidImp;
                } else if(drs[0] && !drs[1] && drs[2] && !drs[3]) {
                    [[mechatronImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :0] ];
                    [mechatronMover setActive:walk];
                    [renderLoop updateTextIngredient:@"Mechatron" Impersomator:meepleTitleImp];
                    if( activeImp != mechatronImp) [renderLoop updateTextIngredient:[speciesDocs objectAtIndex:5] Impersomator:speciesDescriptionImp];
                    activeImp = mechatronImp;
                } else if(drs[0] && !drs[1] && !drs[2] && !drs[3]) {
                    [[gollumerImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :0] ];
                    [gollumerMover setActive:walk];
                    [renderLoop updateTextIngredient:@"Gollumer" Impersomator:meepleTitleImp];
                    if( activeImp != gollumerImp) [renderLoop updateTextIngredient:[speciesDocs objectAtIndex:2] Impersomator:speciesDescriptionImp];
                    activeImp = gollumerImp;
                } else if(drs[0] && !drs[1] && !drs[2] && drs[3]) {
                    [[pakerImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :0] ];
                    [pakerMover setActive:walk];
                    [renderLoop updateTextIngredient:@"Paker" Impersomator:meepleTitleImp];
                    if( activeImp != pakerImp) [renderLoop updateTextIngredient:[speciesDocs objectAtIndex:6] Impersomator:speciesDescriptionImp];
                    activeImp = pakerImp;
                } else if(!drs[0] && !drs[1] && !drs[2] && drs[3]) {
                    [[spheroidImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :0] ];
                    [spheroidMover setActive:walk];
                    [renderLoop updateTextIngredient:@"Spheroid" Impersomator:meepleTitleImp];
                    if( activeImp != spheroidImp) [renderLoop updateTextIngredient:[speciesDocs objectAtIndex:7] Impersomator:speciesDescriptionImp];
                    activeImp = spheroidImp;
                } else if(!drs[0] && drs[1] && !drs[2] && drs[3]) {
                    [[humanoidImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :0] ];
                    [humanoidMover setActive:walk];
                    [renderLoop updateTextIngredient:@"Humanoid" Impersomator:meepleTitleImp];
                    if( activeImp != humanoidImp) [renderLoop updateTextIngredient:[speciesDocs objectAtIndex:3] Impersomator:speciesDescriptionImp];
                    activeImp = humanoidImp;
                } else if(!drs[0] && drs[1] && !drs[2] && !drs[3]) {
                    [[leggitImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :0] ];
                    [leggitMover setActive:walk];
                    [renderLoop updateTextIngredient:@"Leggit" Impersomator:meepleTitleImp];
                    if( activeImp != leggitImp) [renderLoop updateTextIngredient:[speciesDocs objectAtIndex:4] Impersomator:speciesDescriptionImp];
                    activeImp = leggitImp;
                } else if(!drs[0] && drs[1] && drs[2] && !drs[3]) {
                    [[flapperImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :0] ];
                    [flapperMover setActive:walk];
                    [renderLoop updateTextIngredient:@"Flapper" Impersomator:meepleTitleImp];
                    if( activeImp != flapperImp) [renderLoop updateTextIngredient:[speciesDocs objectAtIndex:1] Impersomator:speciesDescriptionImp];
                    activeImp = flapperImp;
                }
                
                
                if(activeImp != mechatronImp )[mechatronMover reset];
                if(activeImp != gollumerImp )[gollumerMover reset];
                if(activeImp != pakerImp )[pakerMover reset];
                if(activeImp != bonzoidImp )[bonzoidMover reset];
                if(activeImp != spheroidImp )[spheroidMover reset];
                if(activeImp != flapperImp )[flapperMover reset];
                if(activeImp != leggitImp )[leggitMover reset];
                if(activeImp != humanoidImp )[humanoidMover reset];

                // play sound for changed meeple
                if(changeDetectionImp != activeImp) {
                    [soundCollector playForImp:activeImp Sound:[soundCollector getSoundId:@"Pickup"]];
                    changeDetectionImp = activeImp;
                }
                
            }
        }
    }];
    
    
    // for mouse
    [meepleSelect addListener:^(float sp, NSNumber *event, int message) {
        
        if([gameContext deviceIdforPlayer:activePlayer] != 1000)
            return; // don't care
        
        YAImpersonator* ballImp = [ballImps objectAtIndex:ballColor];
        [ballImp setVisible:true];
        
        
        event_keyPressed ev = (event_keyPressed)event.intValue;
        if(ev == MOUSE_DOWN && [gameContext deviceIdforPlayer:activePlayer] == 1000) {
            if(message == sensorStart ) {
                [buttonStart setState:@"pressed"];
                
                if (activeImp != nil) {
                    [soundCollector playForImp:activeImp Sound:[soundCollector getSoundId:@"Pickup"]];
                    nextPlayer = true;
                }
                return; // goodby
                
            } else if (message == flapperId) {
                [[flapperImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :0] ];
                [flapperMover setActive:walk];
                [renderLoop updateTextIngredient:@"Flapper" Impersomator:meepleTitleImp];
                if( activeImp != flapperImp) [renderLoop updateTextIngredient:[speciesDocs objectAtIndex:1] Impersomator:speciesDescriptionImp];
                [[ballImp translation] setX:-4]; [[ballImp translation] setZ:-4];
                activeImp = flapperImp;
                [soundCollector playForImp:activeImp Sound:[soundCollector getSoundId:@"Pickup"]];
            } else if (message == leggitId) {
                [[leggitImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :0] ];
                [leggitMover setActive:walk];
                [renderLoop updateTextIngredient:@"Leggit" Impersomator:meepleTitleImp];
                if( activeImp != leggitImp) [renderLoop updateTextIngredient:[speciesDocs objectAtIndex:4] Impersomator:speciesDescriptionImp];
                [[ballImp translation] setX:0]; [[ballImp translation] setZ:-4];
                activeImp = leggitImp;
                [soundCollector playForImp:activeImp Sound:[soundCollector getSoundId:@"Pickup"]];
            } else if (message == humanoidId) {
                [[humanoidImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :0] ];
                [humanoidMover setActive:walk];
                [renderLoop updateTextIngredient:@"Humanoid" Impersomator:meepleTitleImp];
                if( activeImp != humanoidImp) [renderLoop updateTextIngredient:[speciesDocs objectAtIndex:3] Impersomator:speciesDescriptionImp];
                [[ballImp translation] setX:4]; [[ballImp translation] setZ:-4];
                activeImp = humanoidImp;
                [soundCollector playForImp:activeImp Sound:[soundCollector getSoundId:@"Pickup"]];
            } else if (message == bonzoidId) {
                [[bonzoidImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :0] ];
                [bonzoidMover setActive:walk];
                [renderLoop updateTextIngredient:@"Bonzoid" Impersomator:meepleTitleImp];
                if( activeImp != bonzoidImp) [renderLoop updateTextIngredient:[speciesDocs objectAtIndex:0] Impersomator:speciesDescriptionImp];
                [[ballImp translation] setX:-4]; [[ballImp translation] setZ:0];
                activeImp = bonzoidImp;
                [soundCollector playForImp:activeImp Sound:[soundCollector getSoundId:@"Pickup"]];
            } else if (message == spheroidId) {
                [[spheroidImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :0] ];
                [spheroidMover setActive:walk];
                [renderLoop updateTextIngredient:@"Spheroid" Impersomator:meepleTitleImp];
                if( activeImp != spheroidImp) [renderLoop updateTextIngredient:[speciesDocs objectAtIndex:7] Impersomator:speciesDescriptionImp];
                [[ballImp translation] setX:4]; [[ballImp translation] setZ:0];
                activeImp = spheroidImp;
                [soundCollector playForImp:activeImp Sound:[soundCollector getSoundId:@"Pickup"]];
            } else if (message == mechatronId) {
                [[mechatronImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :0] ];
                [mechatronMover setActive:walk];
                [renderLoop updateTextIngredient:@"Mechatron" Impersomator:meepleTitleImp];
                if( activeImp != mechatronImp) [renderLoop updateTextIngredient:[speciesDocs objectAtIndex:5] Impersomator:speciesDescriptionImp];
                [[ballImp translation] setX:-4]; [[ballImp translation] setZ:4];
                activeImp = mechatronImp;
            } else if (message == gollumerId) {
                [[gollumerImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :0] ];
                [gollumerMover setActive:walk];
                [renderLoop updateTextIngredient:@"Gollumer" Impersomator:meepleTitleImp];
                if( activeImp != gollumerImp) [renderLoop updateTextIngredient:[speciesDocs objectAtIndex:2] Impersomator:speciesDescriptionImp];
                [[ballImp translation] setX:0]; [[ballImp translation] setZ:4];
                activeImp = gollumerImp;
                [soundCollector playForImp:activeImp Sound:[soundCollector getSoundId:@"Pickup"]];
            } else if (message == pakerId) {
                [[pakerImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :0] ];
                [pakerMover setActive:walk];
                [renderLoop updateTextIngredient:@"Paker" Impersomator:meepleTitleImp];
                if( activeImp != pakerImp) [renderLoop updateTextIngredient:[speciesDocs objectAtIndex:6] Impersomator:speciesDescriptionImp];
                [[ballImp translation] setX:4]; [[ballImp translation] setZ:4];
                activeImp = pakerImp;
                [soundCollector playForImp:activeImp Sound:[soundCollector getSoundId:@"Pickup"]];
            }
            
            [textIntroImp setVisible:false];
            [meepleTitleImp setVisible:true];
            [speciesDescriptionImp setVisible:true];
            
            
            
            if( activeImp != mechatronImp)
            { [mechatronMover setActive:none]; [mechatronMover reset]; [[mechatronImp translation] setVector:[[YAVector3f alloc] initVals:-4  :0 :4] ]; }
            if( activeImp != gollumerImp)
            { [gollumerMover setActive:none]; [gollumerMover reset]; [[gollumerImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :4] ];}
            if( activeImp != pakerImp)
            { [pakerMover setActive:none]; [pakerMover reset]; [[pakerImp translation] setVector:[[YAVector3f alloc] initVals:4  :0 :4] ];}
            if( activeImp != bonzoidImp)
            { [bonzoidMover setActive:none]; [bonzoidMover reset]; [[bonzoidImp translation] setVector:[[YAVector3f alloc] initVals:-4  :0 :0] ];}
            if( activeImp != spheroidImp)
            { [spheroidMover setActive:none]; [spheroidMover reset]; [[spheroidImp translation] setVector:[[YAVector3f alloc] initVals:4  :0 :0] ];}
            if( activeImp != flapperImp)
            { [flapperMover setActive:none]; [flapperMover reset]; [[flapperImp translation] setVector:[[YAVector3f alloc] initVals:-4  :0 :-4] ];}
            if( activeImp != leggitImp)
            { [leggitMover setActive:none]; [leggitMover reset]; [[leggitImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :-4] ];}
            if( activeImp != humanoidImp)
            { [humanoidMover setActive:none]; [humanoidMover reset];  [[humanoidImp translation] setVector:[[YAVector3f alloc] initVals:4  :0 :-4] ];}
            
            
        } else if(ev == MOUSE_UP) {
            [buttonStart setState:@"released"];
        }
    }];
    
    [meepleSelect addListener:^(float sp, NSNumber *event, int message) {
        [[activeImp rotation] setY:-sp * 360.0];
    }];
    
    
    // alternative use __weak  reference and set to once
    __block bool lookForInput = true;
    
    [meepleSelect addListener:^(float sp, NSNumber *event, int message) {
        
        if(!lookForInput)
            return;
        
        if(nextPlayer == true && activeImp != nil) {
            NSString* speciesName = [activeImp ingredientName];
            int player = activePlayer;
            // NSLog(@"Player %d chose %@", player, speciesName);
            [gameContext setSpecies:speciesName forPlayer:player];
        } // beware no else
        
        if(nextPlayer == true && activePlayer + 1 < [gameContext playerNumber] ) {
            activeImp = nil;
            [meepleTitleImp setVisible:false];
            [speciesDescriptionImp setVisible:false];
            [textIntroImp setVisible:true];
            
            [[mechatronImp translation] setVector:[[YAVector3f alloc] initVals:-4  :0 :4] ];
            [[gollumerImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :4] ];
            [[pakerImp translation] setVector:[[YAVector3f alloc] initVals:4  :0 :4] ];
            [[bonzoidImp translation] setVector:[[YAVector3f alloc] initVals:-4  :0 :0] ];
            [[spheroidImp translation] setVector:[[YAVector3f alloc] initVals:4  :0 :0] ];
            [[flapperImp translation] setVector:[[YAVector3f alloc] initVals:-4  :0 :-4] ];
            [[leggitImp translation] setVector:[[YAVector3f alloc] initVals:0  :0 :-4] ];
            [[humanoidImp translation] setVector:[[YAVector3f alloc] initVals:4  :0 :-4] ];
            
            [[mechatronImp rotation] setY:0];
            [[gollumerImp rotation] setY:0];
            [[pakerImp rotation] setY:0];
            [[bonzoidImp rotation] setY:0];
            [[spheroidImp rotation] setY:0];
            [[flapperImp rotation] setY:0];
            [[leggitImp rotation] setY:0];
            [[humanoidImp rotation] setY:0];
            
            [mechatronMover setActive:none];
            [gollumerMover setActive:none];
            [pakerMover setActive:none];
            [bonzoidMover setActive:none];
            [spheroidMover setActive:none];
            [flapperMover setActive:none];
            [leggitMover setActive:none];
            [humanoidMover setActive:none];
            
            [mechatronMover reset];
            [gollumerMover reset];
            [pakerMover reset];
            [bonzoidMover reset];
            [spheroidMover reset];
            [flapperMover reset];
            [leggitMover reset];
            [humanoidMover reset];
            
            nextPlayer = false;
            activePlayer++;
            [renderLoop updateTextIngredient:[NSString stringWithFormat:@"Player %d", activePlayer + 1] Impersomator:textPlayerImp];
            
            [[ballImps objectAtIndex:ballColor] setVisible:false];
            ballColor = [gameContext getColorForPlayer:activePlayer];
            
            if([gameContext deviceIdforPlayer:activePlayer] == 1000)
                [buttonStart setVisible:true];
            else
                [buttonStart setVisible:false];
        } else if (nextPlayer == true ) {
            lookForInput = false;
            [_stateMachine nextState];
        }
    }];
    
    buttonStart = [[YAImpGroup alloc] init];
    [self genButton: &(sensorStart) group:buttonStart];
    [buttonStart setTranslation:[[YAVector3f alloc] initVals:7.2 :0.01 : 0]];

    [renderLoop setSkyMap:@"LR"];

    [renderLoop freeOpenGLContextFromThread];

    [renderLoop changeImpsSortOrder:SORT_MODEL];
    [renderLoop resetAnimators];
    [renderLoop setActiveAnimation:true];
    [renderLoop setDrawScene:true];
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
              @"BallColorA", @"BallColorB", @"BallColorC", @"BallColorD", @"BallColorE", @"BallColorF", @"BallColorG", @"BallColorH" , nil ];
    
    for(id model in models) {
        ingredient = [renderLoop createIngredient:model];
        [ingredient setModelWithShader:model shader:@"billboard"];
    }

     // NSLog(@"Done loading models");
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
    [button addModifier:@"pressed" Impersonator:buttonId Modifier:@"translation" Value:[[YAVector3f alloc] initVals: 0: 0.02f : 0]];
    
    [button setRotation:[[YAVector3f alloc] initVals:0 :0 :0] ];
    [button setSize:[[YAVector3f alloc] initVals:0.7 :0.7 :0.7]];
    [button setState:@"released"];
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

@end
