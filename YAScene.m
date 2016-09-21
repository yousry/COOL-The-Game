//
//  YAScene.h
//
//  Created by Yousry Abdallah.
//  Copyright 2013 yousry.de. All rights reserved.

#import "YAOpenAL.h"
#import "YASoundCollector.h"
#import "YAGollumerMover.h"
#import "YAHumanoidMover.h"
#import "YALeggitMover.h"
#import "YAMechatronMover.h"
#import "YAPackerMover.h"
#import "YASpheroidMover.h"
#import "YAFlapperMover.h"
#import "YABonzoidMover.h"
#import "YAImpGroup.h"
#import "YAGameContext.h"
#import "YADromedarMover.h"
#import "YAGouradLight.h"
#import "YASpotLight.h"
#import "YALight.h"
#import "YAAvatar.h"
#import "YAMaterial.h"
#import "YABasicAnimator.h"
#import "YABlockAnimator.h"
#import "YAVector3f.h"
#import "YAIngredient.h"
#import "YAImpersonator.h" 
#import "YAPerspectiveProjectionInfo.h"
#import "YATransformator.h"
#import "YARenderLoop.h"
#import "YALog.h"
#import "YAScene.h"

static const NSString* TAG = @"YAScene";

@implementation YAScene : NSObject 

- (id) initIn: (YARenderLoop*) loop
{
	self = [super init];

	if(self) {
		renderLoop = loop;
	}

	return self;    
}

- (void) setup
{
	[YALog debug:TAG message:@"setup scene"];
    [renderLoop removeAllIngredients];
    [self loadModels];

    soundCollector = [[YASoundCollector alloc] initInWorld:renderLoop];
    int jingleId = [soundCollector getJingleId:@"BusinessInSpace"];
    [soundCollector playJingle: jingleId];

    gameContext = [[YAGameContext alloc] init];
    [gameContext setPlayerNumber:4];
    [gameContext setGameDifficulty:3];

    const float buttonBottomLine = -1.9;
    const float labelBottomLine = -2.0;
    const float buttonXAlign = -1.2;
    const float buttonYSpace = 0.6;
    const float buttonLabelSeperator = 0.5;
    const float rowSeperator = 2.1;
    __block const float logoBottomLine = 1.3;
    const float camMovementStart = 2.0;
    const float labelMovementStart  = 3.5;  
    const float labelMovementSpeed  = 0.5;  

    buttonStart = [[YAImpGroup alloc] init];
    [self genButton: &(sensorStart) group:buttonStart]; 
    [buttonStart setTranslation:[[YAVector3f alloc] initVals:buttonXAlign :0 : buttonBottomLine]];

    buttonNumberOfPlayer = [[YAImpGroup alloc] init];
    [self genButton: &(sensorNumPlayer) group: buttonNumberOfPlayer];
    [buttonNumberOfPlayer setTranslation:[[YAVector3f alloc] initVals:buttonXAlign :0 :buttonBottomLine + buttonYSpace]];
    
    buttonDifficulty = [[YAImpGroup alloc] init];
    [self genButton: &(sensorDifficulty) group:buttonDifficulty];
    [buttonDifficulty setTranslation:[[YAVector3f alloc] initVals:buttonXAlign :0 :buttonBottomLine + buttonYSpace * 2]];

    // labe row 1
    __block YAImpersonator* textStartImp = [self genText:@"Start"];
    [[textStartImp translation] setVector: [[YAVector3f alloc] initVals: buttonXAlign + buttonLabelSeperator : 0 : labelBottomLine]];
    [[[textStartImp material] phongAmbientReflectivity] setValues:0.7 :0.1 :0.2];
    textStartImp.material.eta = 0;
    
    __block YAImpersonator* textNumPlayersImp = [self genText:@"Player"];
    [[textNumPlayersImp translation] setVector: [[YAVector3f alloc] initVals: buttonXAlign + buttonLabelSeperator : 0 : labelBottomLine + buttonYSpace]];
    [[[textNumPlayersImp material] phongAmbientReflectivity] setValues:0.7 :0.1 :0.2];
    textNumPlayersImp.material.eta = 0;
    
    __block YAImpersonator* textDifficultyImp = [self genText:@"Difficulty"];
    [[textDifficultyImp translation] setVector: [[YAVector3f alloc] initVals: buttonXAlign + buttonLabelSeperator : 0 : labelBottomLine + buttonYSpace * 2]];
    [[[textDifficultyImp material] phongAmbientReflectivity] setValues:0.7 :0.1 :0.2];
    textDifficultyImp.material.eta = 0;
    
    // label row 2
    NSString* level = @"Beginner";
    if(gameContext.gameDifficulty == 1)
        level =  @"Standard"; 
    else if(gameContext.gameDifficulty == 2)
        level = @"Tournament"; 
    
    __block YAImpersonator* textDifficultValueImp = [self genText:level];
    [[textDifficultValueImp translation] setVector: [[YAVector3f alloc] initVals: buttonXAlign + buttonLabelSeperator + rowSeperator : 0 : labelBottomLine + buttonYSpace * 2]];
    [[[textDifficultValueImp material] phongAmbientReflectivity] setValues:0.7 :0.1 :0.2];
    textDifficultValueImp.material.eta = 0;

    
    __block YAImpersonator* textNumPlayerValueImp = [self genText:[NSString stringWithFormat:@"%d", gameContext.playerNumber]];
    [[textNumPlayerValueImp translation] setVector: [[YAVector3f alloc] initVals: buttonXAlign + buttonLabelSeperator + rowSeperator : 0 : labelBottomLine + buttonYSpace * 1]];
    [[[textNumPlayerValueImp material] phongAmbientReflectivity] setValues:0.7 :0.1 :0.2];
    textNumPlayerValueImp.material.eta = 0;

    int logoId = [renderLoop createImpersonator: @"Logo"];
    __block YAImpersonator* logoImp = [renderLoop getImpersonator:logoId];
    
    [[logoImp translation] setVector: [[YAVector3f alloc] initVals: 0 : 0.8 : logoBottomLine]];
    [[logoImp rotation] setVector: [[YAVector3f alloc] initVals: 270: 0 : 0]];
    
    YABlockAnimator* atarilRotator = [renderLoop createBlockAnimator];
    [atarilRotator setInterval:15.0f]; // sec
    [atarilRotator setDelay:0];
    [atarilRotator setProgress:harmonic];
    
    [atarilRotator addListener:^(float spanPos, NSNumber* event, int message) 
     {
         [logoImp setNormalMapFactor:5 - spanPos * 5];
     }];

    int dromedarId = [renderLoop createImpersonatorWithShapeShifter: @"Dromedar"];
    YAImpersonator* dromedarImp = [renderLoop getImpersonator:dromedarId];
    [[dromedarImp translation] setVector: [[YAVector3f alloc] initVals: 0 : 0 : 0]];
    [[dromedarImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 90 : 0]];
    [dromedarImp resize:0.225];
    [[[dromedarImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[dromedarImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[dromedarImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[dromedarImp material] setPhongShininess: 20];
    
    __block YADromedarMover* dromedarMover = [[YADromedarMover alloc] initWithImp:dromedarImp inWorld:renderLoop]; 
    [dromedarMover setActive:parade];

    int deskId = [renderLoop createImpersonator:@"Desk"];
    YAImpersonator* deskImp = [renderLoop getImpersonator:deskId];
    [[deskImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
    [[deskImp translation] setVector: [[YAVector3f alloc] initVals: 0: -0.0001 : 0]];
    [[[deskImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.1 : 0.12 : 0.1 ]];
    [[[deskImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.6f : 0.6f : 0.6f ]];
    [[[deskImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    
    __block YAAvatar* avatar = [renderLoop avatar];
    [avatar setPosition: [[YAVector3f alloc] initVals:0.0f :9.0f :0.0f ]]; 
    [avatar setAtlas:90.0f axis:00.0f];

    YABlockAnimator* introRoll = [renderLoop createBlockAnimator];
    [introRoll setOnce:true];
    [introRoll setInterval:1.5f]; // sec
    [introRoll setDelay:0];
    [introRoll setProgress:damp];
    [introRoll addListener:^(float spanPos, NSNumber* event, int message) 
     {
         [avatar setAtlas:90 axis:spanPos * 360];
     }];

    YABlockAnimator* camAnim = [renderLoop createBlockAnimator];
    [camAnim setOnce:true];
    [camAnim setInterval:1.0f]; // sec
    [camAnim setDelay:camMovementStart];
    [camAnim addListener:^(float spanPos, NSNumber* event, int message) 
     {
         const float cM = 50.0f; // degrees 
         YAVector3f* pos = [[YAVector3f alloc] initVals:0.0f :9.0f :0.0f ];
         [pos rotate:- spanPos * cM axis:[[YAVector3f alloc] initXAxe]];
         [avatar setAtlas:90.0f - spanPos * (cM + 1.8) axis:00.0f];
         [avatar setPosition:pos];
     }];

    YABlockAnimator* logoAnim = [renderLoop createBlockAnimator];
    [logoAnim setOnce:true];
    [logoAnim setInterval:1.0f]; // sec
    [logoAnim setDelay:camMovementStart];
    [logoAnim addListener:^(float spanPos, NSNumber* event, int message) 
     {
         const float cM = 50.0f; // degrees 
         [[logoImp rotation] setX:270 - spanPos * cM];
         [[logoImp translation] setY: 0.8f + spanPos / 2.0 ];
         
         
     }];

    YABlockAnimator* labelAnim = [renderLoop createBlockAnimator];
    [labelAnim setOnce:true];
    [labelAnim setInterval:labelMovementSpeed]; // sec
    [labelAnim setDelay:labelMovementStart];
    [labelAnim addListener:^(float spanPos, NSNumber* event, int message) 
     {
         const float cM = 50.0f; // degrees 
         [[textStartImp rotation] setX: 90  - spanPos * cM];
         [[textNumPlayersImp  rotation] setX: 90  - spanPos * cM];
         [[textNumPlayerValueImp  rotation] setX: 90  - spanPos * cM];
         [[textDifficultyImp  rotation] setX: 90  - spanPos * cM];
         [[textDifficultValueImp  rotation] setX: 90  - spanPos * cM];
     }];

    YABlockAnimator* dromedarStops = [renderLoop createBlockAnimator];
    [dromedarStops setOnce:true];
    [dromedarStops setDelay:5];
    [dromedarStops setInterval:0.1f];
    [dromedarStops addListener:^(float spanPos, NSNumber* event, int message) 
     {
         [dromedarMover setActive:none];
         [dromedarMover reset];
     }];

    YABlockAnimator* dromedarRuns = [renderLoop createBlockAnimator];
    [dromedarRuns setProgress:accelerate];
    [dromedarRuns setOnce:true];
    [dromedarRuns setDelay:6]; 
    [dromedarRuns setProgress:cyclic];
    [dromedarRuns setInterval:2.5];
    [dromedarRuns addListener:^(float spanPos, NSNumber* event, int message) 
     {
         [dromedarMover setActive:walk];
         [[dromedarImp translation]setX:spanPos * 5.8];
     }];
    
    
    YABlockAnimator* dromedarIsOutOfScrees = [renderLoop createBlockAnimator];
    [dromedarIsOutOfScrees setOnce:true];
    [dromedarIsOutOfScrees setDelay:9.0];
    [dromedarIsOutOfScrees setInterval:0.1];
    [dromedarIsOutOfScrees addListener:^(float spanPos, NSNumber* event, int message) 
     {
         [dromedarMover setActive:none];
         [dromedarImp setVisible:false];
     }];
    
    
    // @"Bonzoid",  @"Flapper",  @"Gollumer",  @"Humanoid",  @"Leggit",  @"Mechatron",  @"Paker", @"Spheroid"
    
    
    int bonzoidId = [renderLoop createImpersonatorWithShapeShifter: @"Bonzoid"];
    __block YAImpersonator* bonzoidImp = [renderLoop getImpersonator:bonzoidId];
    
    [bonzoidImp resize:0.08];
    [bonzoidImp setVisible:false];
    [[bonzoidImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :90 :0] ];
    [[bonzoidImp translation] setVector:[[YAVector3f alloc] initVals:2.5 :0 :0] ];
    [[[bonzoidImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[bonzoidImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[bonzoidImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[bonzoidImp material] setPhongShininess: 20];
    
    __block YABonzoidMover* bonzoidMover = [[YABonzoidMover alloc] initWithImp:bonzoidImp inWorld:renderLoop]; 
    [bonzoidMover setActive:walk];
    
    int flapperId = [renderLoop createImpersonatorWithShapeShifter: @"Flapper"];
    __block YAImpersonator* flapperImp = [renderLoop getImpersonator:flapperId];
    
    [flapperImp resize:0.06];
    [flapperImp setVisible:false];
    [[flapperImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :90 :0] ];
    [[flapperImp translation] setVector:[[YAVector3f alloc] initVals:1.8 :0 :0] ];
    [[[flapperImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[flapperImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[flapperImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[flapperImp material] setPhongShininess: 20];
    
    __block YAFlapperMover* flapperMover = [[YAFlapperMover alloc] initWithImp:flapperImp inWorld:renderLoop]; 
    [flapperMover setActive:walk];
    
    
    int gollumerId = [renderLoop createImpersonatorWithShapeShifter: @"Gollumer"];
    __block YAImpersonator* gollumerImp = [renderLoop getImpersonator:gollumerId];
    
    [gollumerImp resize:0.06];
    [gollumerImp setVisible:false];
    [[gollumerImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :90 :0] ];
    [[gollumerImp translation] setVector:[[YAVector3f alloc] initVals:1.2 :0 :0] ];
    [[[gollumerImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[gollumerImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[gollumerImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[gollumerImp material] setPhongShininess: 20];
    
    __block YAGollumerMover* gollumerMover = [[YAGollumerMover alloc] initWithImp:gollumerImp inWorld:renderLoop]; 
    [gollumerMover setActive:walk];
    
    
    int humanoidId = [renderLoop createImpersonatorWithShapeShifter: @"Humanoid"];
    __block YAImpersonator* humanoidImp = [renderLoop getImpersonator:humanoidId];
    
    [humanoidImp resize:0.24];
    [humanoidImp setVisible:false];
    [[humanoidImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :90 :0] ];
    [[humanoidImp translation] setVector:[[YAVector3f alloc] initVals:0.6 :0 :0] ];
    [[[humanoidImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[humanoidImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[humanoidImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[humanoidImp material] setPhongShininess: 20];
    
    __block YAHumanoidMover* humanoidMover = [[YAHumanoidMover alloc] initWithImp:humanoidImp inWorld:renderLoop]; 
    [humanoidMover setActive:walk];
    
    
    int leggitId = [renderLoop createImpersonatorWithShapeShifter: @"Leggit"];
    __block YAImpersonator* leggitImp = [renderLoop getImpersonator:leggitId];
    
    [leggitImp resize:0.075];
    [leggitImp setVisible:false];
    [[leggitImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :90 :0] ];
    [[leggitImp translation] setVector:[[YAVector3f alloc] initVals:-0.1 :0 :0] ];
    [[[leggitImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[leggitImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[leggitImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[leggitImp material] setPhongShininess: 20];
    
    __block YALeggitMover* leggitMover = [[YALeggitMover alloc] initWithImp:leggitImp inWorld:renderLoop]; 
    [leggitMover setActive:walk];
    
    int mechatronId = [renderLoop createImpersonatorWithShapeShifter: @"Mechatron"];
    __block YAImpersonator* mechatronImp = [renderLoop getImpersonator:mechatronId];
    
    [mechatronImp resize:0.075];
    [mechatronImp setVisible:false];
    [[mechatronImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :90 :0] ];
    [[mechatronImp translation] setVector:[[YAVector3f alloc] initVals:-0.9 :0 :0] ];
    [[[mechatronImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[mechatronImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[mechatronImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[mechatronImp material] setPhongShininess: 20];
    
    __block YAMechatronMover* mechatronMover = [[YAMechatronMover alloc] initWithImp:mechatronImp inWorld:renderLoop]; 
    [mechatronMover setActive:walk];
    
    int pakerId = [renderLoop createImpersonatorWithShapeShifter: @"Paker"];
    __block YAImpersonator* pakerImp = [renderLoop getImpersonator:pakerId];
    
    [pakerImp resize:0.075];
    [pakerImp setVisible:false];
    [[pakerImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :90 :0] ];
    [[pakerImp translation] setVector:[[YAVector3f alloc] initVals:-1.6 :0 :0.2] ];
    [[[pakerImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[pakerImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[pakerImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[pakerImp material] setPhongShininess: 20];
    
    __block YAPackerMover* pakerMover = [[YAPackerMover alloc] initWithImp:pakerImp inWorld:renderLoop]; 
    [pakerMover setActive:walk];
    
    int spheroidId = [renderLoop createImpersonatorWithShapeShifter: @"Spheroid"];
    __block YAImpersonator* spheroidImp = [renderLoop getImpersonator:spheroidId];
    
    [spheroidImp resize:0.11];
    [spheroidImp setVisible:false];
    [[spheroidImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :90 :0] ];
    [[spheroidImp translation] setVector:[[YAVector3f alloc] initVals:-2.3 :0 :0] ];
    [[[spheroidImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[spheroidImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[spheroidImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[spheroidImp material] setPhongShininess: 20];
    
    __block YASpheroidMover* spheroidMover = [[YASpheroidMover alloc] initWithImp:spheroidImp inWorld:renderLoop]; 
    [spheroidMover setActive:walk];
    
    
    YABlockAnimator* aliensFirstWave = [renderLoop createBlockAnimator];
    [aliensFirstWave setOnce:true];
    [aliensFirstWave setDelay:9.0];
    [aliensFirstWave setInterval:11.0];
    [aliensFirstWave addListener:^(float spanPos, NSNumber* event, int message) 
     {
         float intervalStretch = 20.0f;
         float origin = -4;
         float alienDist = 2.5;
         
         [humanoidImp setVisible:true];
         [[humanoidImp translation] setX:origin + spanPos * intervalStretch];
         
         [leggitImp setVisible:true];
         [[leggitImp translation] setX:origin - (1 * alienDist) + spanPos * intervalStretch];
         
         [pakerImp setVisible:true];
         [[pakerImp translation] setX:origin - (2 * alienDist) + spanPos * intervalStretch];
         
         [spheroidImp setVisible:true];
         [[spheroidImp translation] setX:origin - (3 * alienDist) + spanPos * intervalStretch];
         
         [bonzoidImp setVisible:true];
         [[bonzoidImp translation] setX:origin - (4 * alienDist) + spanPos * intervalStretch];
         
     }];
    
    
    YABlockAnimator* aliensRemove = [renderLoop createBlockAnimator];
    [aliensRemove setOnce:true];
    [aliensRemove setDelay:19.1];
    [aliensRemove setInterval:0.1];
    [aliensRemove addListener:^(float spanPos, NSNumber* event, int message) 
     {
         [humanoidImp setVisible:false];
         [leggitImp setVisible:false];
         [pakerImp setVisible:false];
         [spheroidImp setVisible:false];
         [bonzoidImp setVisible:false];
     }];



    YABlockAnimator* DromedarAndMuleComeBack = [renderLoop createBlockAnimator];
    [DromedarAndMuleComeBack setProgress:damp];
    [DromedarAndMuleComeBack setOnce:true];
    [DromedarAndMuleComeBack setDelay:19.5];
    [DromedarAndMuleComeBack setInterval:2.3];
    [DromedarAndMuleComeBack addListener:^(float spanPos, NSNumber* event, int message) 
     {
         
         float intervalStretch = 4.5f;
         float origin = -1;
         float alienDist = 2.0;
         
         [flapperImp setVisible:true];
         [dromedarImp setVisible:true];
         [dromedarMover setActive:walk];
         
         [[flapperImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :-90 :0]];
         [[dromedarImp rotation] setVector:[[YAVector3f alloc] initVals:-90 :-90 :0]];
         
         [[flapperImp translation] setX:origin + (1 - spanPos) * intervalStretch];
         [[dromedarImp translation] setX:origin + alienDist + (1 - spanPos) * intervalStretch];
         
     }];
    
    YABlockAnimator* DromedarAndMuleStop = [renderLoop createBlockAnimator];
    [DromedarAndMuleStop setProgress:damp];
    [DromedarAndMuleStop setOnce:true];
    [DromedarAndMuleStop setDelay:21.8];
    [DromedarAndMuleStop setInterval:0.1];
    [DromedarAndMuleStop addListener:^(float spanPos, NSNumber* event, int message) 
     {
         [dromedarMover setActive:parade];
         [flapperMover setActive:parade];
     }];
    
    
    YABlockAnimator* DromedarRotateToViewer = [renderLoop createBlockAnimator];
    [DromedarRotateToViewer setOnce:true];
    [DromedarRotateToViewer setDelay:22.2];
    [DromedarRotateToViewer setInterval:0.8];
    [DromedarRotateToViewer addListener:^(float spanPos, NSNumber* event, int message) 
     {
         [[dromedarImp rotation]setY: -90 + (spanPos * 90)];
     }];
    
    
    YABlockAnimator* FlapperRotateToViewer = [renderLoop createBlockAnimator];
    [FlapperRotateToViewer setOnce:true];
    [FlapperRotateToViewer setDelay:22.0];
    [FlapperRotateToViewer setInterval:0.5];
    [FlapperRotateToViewer addListener:^(float spanPos, NSNumber* event, int message) 
     {
         [[flapperImp rotation] setY: -90 + (spanPos * 90) ];
     }];
    
    
    int tileSocketId = [renderLoop createImpersonatorWithShapeShifter: @"tileSocket"];
    YAImpersonator* tileSocketImp = [renderLoop getImpersonator:tileSocketId];
    [[tileSocketImp translation] setVector: [[YAVector3f alloc] initVals: 1 : 0 : 0]];
    [[tileSocketImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
    [[tileSocketImp size] setVector: [[YAVector3f alloc] initVals: 0.15: 0.15 : 0.15]];
    [[[tileSocketImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2 : 0.2 : 0.5 ]];
    [[[tileSocketImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[tileSocketImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[tileSocketImp material] setPhongShininess: 20];
    [tileSocketImp setVisible:false];
    
    YABlockAnimator* tileSocketIsFallingDown = [renderLoop createBlockAnimator];
    [tileSocketIsFallingDown setOnce:true];
    [tileSocketIsFallingDown setDelay:24];
    [tileSocketIsFallingDown setProgress:damp];
    [tileSocketIsFallingDown setInterval:0.4];
    [tileSocketIsFallingDown addListener:^(float spanPos, NSNumber* event, int message) 
     {
         
         float distance = 4;
         
         [tileSocketImp setVisible:true];
         [[tileSocketImp translation] setY:distance * (1 - spanPos)];
         
     }];
    
    
    int farmhouseId = [renderLoop createImpersonatorWithShapeShifter: @"FarmhouseTile"];
    YAImpersonator* farmhouseImp = [renderLoop getImpersonator:farmhouseId];
    [[farmhouseImp translation] setVector: [[YAVector3f alloc] initVals: 1 : 0 : 0]];
    [[farmhouseImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 90 : 0]];
//    [[farmhouseImp size] setVector: [[YAVector3f alloc] initVals: 0.20: 0.20 : 0.20]];
    [farmhouseImp resize:0.15];
    
    [[[farmhouseImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4 : 0.5 : 0.5 ]];
    [[[farmhouseImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[farmhouseImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.1f : 0.1f : 0.1f ]];
    [[farmhouseImp material] setPhongShininess: 200];
    [farmhouseImp setVisible:false];
    
    
    YABlockAnimator* farmHouseIsFallingDown = [renderLoop createBlockAnimator];
    [farmHouseIsFallingDown setOnce:true];
    [farmHouseIsFallingDown setDelay:24.2];
    [farmHouseIsFallingDown setProgress:damp];
    [farmHouseIsFallingDown setInterval:0.4];
    [farmHouseIsFallingDown addListener:^(float spanPos, NSNumber* event, int message) 
     {
         
         float distance = 4;
         
         [farmhouseImp setVisible:true];
         [[farmhouseImp translation] setY:0.04f + distance * (1 - spanPos)];
         
     }];
    
    
    YABlockAnimator* removeDromedar = [renderLoop createBlockAnimator];
    [removeDromedar setOnce:true];
    [removeDromedar setDelay:24.2];
    [removeDromedar setInterval:0.1];
    [removeDromedar addListener:^(float spanPos, NSNumber* event, int message) 
     {
         [dromedarImp setVisible:false];
     }];
    
    
    YABlockAnimator* farmHouseAndFlapperIsflyingaway = [renderLoop createBlockAnimator];
    [farmHouseAndFlapperIsflyingaway setOnce:true];
    [farmHouseAndFlapperIsflyingaway setDelay:30.0];
    [farmHouseAndFlapperIsflyingaway setProgress:accelerate];
    [farmHouseAndFlapperIsflyingaway setInterval:0.4];
    [farmHouseAndFlapperIsflyingaway addListener:^(float spanPos, NSNumber* event, int message) 
     {
         
         float distance = 6.0;
         
         [[farmhouseImp translation] setY:0.04f + distance * spanPos];
         [[flapperImp translation] setY:distance * spanPos];
         
         
     }];
    
    YABlockAnimator* tileSocketIsflyingaway = [renderLoop createBlockAnimator];
    [tileSocketIsflyingaway setOnce:true];
    [tileSocketIsflyingaway setDelay:30.2];
    [tileSocketIsflyingaway setProgress:accelerate];
    [tileSocketIsflyingaway setInterval:0.4];
    [tileSocketIsflyingaway addListener:^(float spanPos, NSNumber* event, int message) 
     {
         float distance = 6.0;
         [[tileSocketImp translation] setY:distance * spanPos];
     }];
    
    
    YABlockAnimator* removeForFinale = [renderLoop createBlockAnimator];
    [removeForFinale setOnce:true];
    [removeForFinale setDelay:30.65];
    [removeForFinale setInterval:0.1];
    [removeForFinale addListener:^(float spanPos, NSNumber* event, int message) 
     {
         [farmhouseImp setVisible:false];
         [tileSocketImp setVisible:false];
         [flapperImp setVisible:false];
     }];
    
    
    YABlockAnimator* finaleAnim = [renderLoop createBlockAnimator];
    [finaleAnim setDelay:35.0];
    [finaleAnim setInterval:11.0];
    [finaleAnim addListener:^(float spanPos, NSNumber* event, int message) 
     {
         float intervalStretch = 20.0f;
         float origin = -4;
         float alienDist = 2.5;
         
         [humanoidImp setVisible:true];
         [[humanoidImp translation] setX:origin + spanPos * intervalStretch];
         
         [leggitImp setVisible:true];
         [[leggitImp translation] setX:origin - (1 * alienDist) + spanPos * intervalStretch];
         
         [pakerImp setVisible:true];
         [[pakerImp translation] setX:origin - (2 * alienDist) + spanPos * intervalStretch];
         
         [spheroidImp setVisible:true];
         [[spheroidImp translation] setX:origin - (3 * alienDist) + spanPos * intervalStretch];
         
         [bonzoidImp setVisible:true];
         [[bonzoidImp translation] setX:origin - (4 * alienDist) + spanPos * intervalStretch];
         
     }];
    
    
    // Spaceship
    
    int spaceshipId = [renderLoop createImpersonatorWithShapeShifter: @"SpaceShip"];
    __block YAImpersonator* spaceshipImp = [renderLoop getImpersonator:spaceshipId];
    [[spaceshipImp translation] setVector: [[YAVector3f alloc] initVals: 0 : 3 : 6]];
    [[spaceshipImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 180 : 0]];
    [[spaceshipImp size] setVector: [[YAVector3f alloc] initVals: 0.8: 0.8 : 0.8]];
    [[[spaceshipImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.6 : 0.6 : 0.6 ]];
    [[[spaceshipImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[spaceshipImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[spaceshipImp material] setPhongShininess: 200];
    [spaceshipImp setVisible:false];
    
    
    YABlockAnimator* spaceshipAnim = [renderLoop createBlockAnimator];
    [spaceshipAnim setOnce:true];
    [spaceshipAnim setDelay:0.5];
    [spaceshipAnim setInterval:1.8];
    [spaceshipAnim addListener:^(float spanPos, NSNumber* event, int message) 
     {
         [spaceshipImp setVisible:true];
         [[spaceshipImp translation] setZ: 6 - ((1 - spanPos) * 20) ];
         
     }];
    
    
    YABlockAnimator* spaceshipAnimRepose = [renderLoop createBlockAnimator];
    [spaceshipAnimRepose setOnce:true];
    [spaceshipAnimRepose setDelay:2.4];
    [spaceshipAnimRepose setInterval:0.1];
    [spaceshipAnimRepose addListener:^(float spanPos, NSNumber* event, int message) 
     {
         [[spaceshipImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
         [spaceshipImp resize:0.5];
         [[spaceshipImp translation] setZ:3.5];
         [[spaceshipImp translation] setX:2.5];
         [spaceshipImp setVisible:false];
         
     }];
    
    
    
    YABlockAnimator* spaceshipAnimLand = [renderLoop createBlockAnimator];
    [spaceshipAnimLand setOnce:true];
    [spaceshipAnimLand setDelay:10];
    [spaceshipAnimLand setInterval:1.0];
    [spaceshipAnimLand setProgress:accelerate];
    [spaceshipAnimLand addListener:^(float spanPos, NSNumber* event, int message) 
     {
         [spaceshipImp setVisible:true];
         [[spaceshipImp translation] setY: 0.7 + ((1 - spanPos) * 5) ];
         
     }];
    
    
    YABlockAnimator* spaceshipGravityWobble = [renderLoop createBlockAnimator];
    [spaceshipGravityWobble setDelay:5];
    [spaceshipGravityWobble setInterval:4.0];
    [spaceshipGravityWobble setProgress:harmonic];
    [spaceshipGravityWobble addListener:^(float spanPos, NSNumber* event, int message) 
     {
         [[spaceshipImp rotation] setZ: spanPos * 4.0 ];        
         
     }];
    
    
    
    int playboardId = [renderLoop createImpersonator:@"PlayboardTitle"];
    YAImpersonator* playboardImp = [renderLoop getImpersonator:playboardId];
    [[playboardImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
    [playboardImp resize:0.5];
    [playboardImp setShadowCaster:false];
    [[playboardImp translation] setVector: [[YAVector3f alloc] initVals: -2.5 : 0 : 1.8]];
    [[[playboardImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4 :0.4 :0.4 ]];
    [[[playboardImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[playboardImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[playboardImp material] setPhongShininess: 10.0f];
    
   
    int dromiId = [renderLoop createImpersonatorWithShapeShifter: @"Dromedar"];
    YAImpersonator* dromiImp = [renderLoop getImpersonator:dromiId];
    [[dromiImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 90 : 0]];
    [dromiImp resize:0.08];
    [[[dromiImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[dromiImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[dromiImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[dromiImp material] setPhongShininess: 20];
    
    [[dromiImp translation] setVector: [[YAVector3f alloc] initVals: -2.5 : 0.05 : 1.8]];
    __block YADromedarMover* dromiMover = [[YADromedarMover alloc] initWithImp:dromiImp inWorld:renderLoop]; 
    [dromiMover setActive:walk];
    
    
    int mechiId = [renderLoop createImpersonatorWithShapeShifter: @"Mechatron"];
    YAImpersonator* mechiImp = [renderLoop getImpersonator:mechiId];
    [[mechiImp translation] setVector: [[YAVector3f alloc] initVals: -2.85 : 0.05 : 1.3]];
    [[mechiImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 90 : 0]];
    [mechiImp resize:0.04];
    [[[mechiImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[mechiImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[mechiImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[mechiImp material] setPhongShininess: 20];
    
    __block YAMechatronMover* mechiMover = [[YAMechatronMover alloc] initWithImp:mechiImp inWorld:renderLoop]; 
    [mechiMover setActive:walk];
    
    float treeSize = 1.2;
    YAVector3f* treePos = [[YAVector3f alloc] initVals:-2 :0 : 2.2 ];
    
    int treeId = [renderLoop createImpersonatorWithShapeShifter: @"TreeA"];
    YAImpersonator* treeImp = [renderLoop getImpersonator:treeId];
    [[treeImp translation] setVector: treePos];
    [[treeImp rotation] setVector: [[YAVector3f alloc] initVals: -180: 40 : 0]];
    [treeImp resize:treeSize];
    [[[treeImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[treeImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[treeImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[treeImp material] setPhongShininess: 20];
    
    int leafId = [renderLoop createImpersonatorWithShapeShifter: @"LeafA"];
    YAImpersonator* leadImp = [renderLoop getImpersonator:leafId];
    [[leadImp translation] setVector: treePos];
    [[leadImp rotation] setVector: [[YAVector3f alloc] initVals: -180: 40 : 0]];
    [leadImp resize:treeSize];
    [leadImp setBackfaceCulling:false];
    [[[leadImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[leadImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[leadImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[leadImp material] setPhongShininess: 20];
    
    NSArray* lights = [renderLoop lights];
    __block YASpotLight* sLight;
    
    for (YALight* lit in lights) {
        if([[lit name] isEqualToString:@"YASpotLight"]) {
            sLight = (YASpotLight*)lit;
        }
    }
    
    [sLight setCutoff:55];
    [sLight setExponent:6];
    sLight.position.y = 5;
    sLight.position.x = 1;
    sLight.position.z = -2;
    [sLight spotAt:[[YAVector3f alloc] initVals:0 :0 :0]];

    
    YABlockAnimator* buttonPress = [renderLoop createBlockAnimator];
    [buttonPress addListener:^(float spanPos, NSNumber* event, int message) {
        
        int evBin = message & 255;
        
        switch ([event intValue]) {
            case GAMEPAD_BUTTON_A:
                if(evBin == 1) {
                    [soundCollector playForImp:logoImp Sound:[soundCollector getSoundId:@"Pickup"]];
                    if(gameContext.gameDifficulty < 2)
                        [gameContext setGameDifficulty: gameContext.gameDifficulty + 1];
                    else
                        [gameContext setGameDifficulty: 0];
                    
                    NSString* level = @"Beginner";
                    if(gameContext.gameDifficulty == 1)
                        level = @"Standard";
                    else if(gameContext.gameDifficulty == 2)
                        level = @"Tournament";
                    
                    [renderLoop updateTextIngredient:level Impersomator:textDifficultValueImp];
                    [buttonDifficulty setState:@"pressed"];
                } else {
                    [buttonStart setState:@"released"];
                    [buttonNumberOfPlayer setState:@"released"];
                    [buttonDifficulty setState:@"released"];
                }
                break;
            case GAMEPAD_BUTTON_B:
                if(evBin == 1) {
                    [soundCollector playForImp:logoImp Sound:[soundCollector getSoundId:@"Pickup"]];
                    if(gameContext.playerNumber > 1)
                        [gameContext setPlayerNumber:gameContext.playerNumber - 1];
                    else
                        [gameContext setPlayerNumber:4];
                    
                    [renderLoop updateTextIngredient:[NSString stringWithFormat:@"%d",gameContext.playerNumber] Impersomator:textNumPlayerValueImp];
                    [buttonNumberOfPlayer setState:@"pressed"];
                } else {
                    [buttonStart setState:@"released"];
                    [buttonNumberOfPlayer setState:@"released"];
                    [buttonDifficulty setState:@"released"];
                }
                break;
            case GAMEPAD_BUTTON_OK:
                if(evBin == 1) {
                    [soundCollector playForImp:logoImp Sound:[soundCollector getSoundId:@"Pickup"]];
                    [renderLoop startEvent:USER message:0];
                    [buttonStart setState:@"pressed"];
                } else {
                    [buttonStart setState:@"released"];
                    [buttonNumberOfPlayer setState:@"released"];
                    [buttonDifficulty setState:@"released"];
                }
                break;
            case MOUSE_DOWN:
                if(message == sensorStart ) {
                    [soundCollector playForImp:logoImp Sound:[soundCollector getSoundId:@"Pickup"]];
                    [renderLoop startEvent:USER message:0];
                    [buttonStart setState:@"pressed"];
                } else if (message == sensorNumPlayer) {
                    [soundCollector playForImp:logoImp Sound:[soundCollector getSoundId:@"Pickup"]];
                    if(gameContext.playerNumber > 1)
                        [gameContext setPlayerNumber:gameContext.playerNumber - 1];
                    else
                        [gameContext setPlayerNumber:4];
                    
                    [renderLoop updateTextIngredient:[NSString stringWithFormat:@"%d",gameContext.playerNumber] Impersomator:textNumPlayerValueImp];
                    [buttonNumberOfPlayer setState:@"pressed"];
                } else if (message == sensorDifficulty) {
                    [soundCollector playForImp:logoImp Sound:[soundCollector getSoundId:@"Pickup"]];
                    if(gameContext.gameDifficulty < 2)
                        [gameContext setGameDifficulty: gameContext.gameDifficulty + 1];
                    else
                        [gameContext setGameDifficulty: 0];
                    
                    NSString* level = @"Beginner";
                    if(gameContext.gameDifficulty == 1)
                        level = @"Standard";
                    else if(gameContext.gameDifficulty == 2)
                        level = @"Tournament";
                    
                    [renderLoop updateTextIngredient:level Impersomator:textDifficultValueImp];
                    [buttonDifficulty setState:@"pressed"];
                }
                break;
            case MOUSE_UP:
                [buttonStart setState:@"released"];
                [buttonNumberOfPlayer setState:@"released"];
                [buttonDifficulty setState:@"released"];
                break;
            default:
                break;
        }
        
    }];  

    YABlockAnimator* userEvent = [renderLoop createBlockAnimator];
    [userEvent addListener:^(float spanPos, NSNumber* event, int message) {
        if (([event intValue] == USER  && message == 0)) {
            NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
            [standardUserDefaults setInteger:gameContext.playerNumber forKey:@"players"];
            [standardUserDefaults setInteger:gameContext.gameDifficulty forKey:@"difficulty"];
            [standardUserDefaults synchronize];            
            // [_stateMachine nextState];
        }
    }];    



    [renderLoop setSkyMap:@"LR"];
    [renderLoop changeImpsSortOrder:SORT_SHADER];
	[renderLoop resetAnimators];
    [renderLoop setMultiSampling:true];
    [renderLoop setActiveAnimation:true];
	renderLoop.drawScene = YES;
}

- (void) loadModels
{

    YAIngredient* ingredient;
    ingredient = [renderLoop createIngredient:@"GameButton"];
    [ingredient setModelWithShader:@"GameButton" shader:@"gourad"];
    
    ingredient = [renderLoop createIngredient:@"SpaceShip"];
    [ingredient setModelWithShader:@"SpaceShip" shader:@"ads_texture"];
    
    
    ingredient = [renderLoop createIngredient:@"GameButtonSocket"];
    [ingredient setModelWithShader:@"GameButtonSocket" shader:@"gourad"];
    ingredient = [renderLoop createIngredient:@"Logo"];
    [ingredient setModelWithShader:@"Logo" shader:@"logo"];
    ingredient = [renderLoop createIngredient:@"Desk"];
    

    [ingredient setAutoMipMap:true];
    [ingredient setModelWithShader:@"Desk" shader:@"ads_texture_normal_spotlight"];

    ingredient = [renderLoop createIngredient:@"FarmhouseTile"];
    [ingredient setModelWithShader:@"FarmhouseTile" shader:@"ads_texture_spotlight"];
    ingredient = [renderLoop createIngredient:@"tileSocket"];
    [ingredient setModelWithShader:@"tileSocket" shader:@"gourad"];
    
    ingredient = [renderLoop createIngredient:@"PlayboardTitle"];
    [ingredient setModelWithShader:@"PlayboardTitle" shader:@"ads_texture_normal_spotlight"];
    
    ingredient = [renderLoop createIngredient:@"TreeA"];
    [ingredient setModelWithShader:@"TreeA" shader:@"ads_texture"];
    
    ingredient = [renderLoop createIngredient:@"LeafA"];
    [ingredient setModelWithShader:@"LeafA" shader:@"ads_texture"];
    
    ingredient = [renderLoop createIngredient:@"Dromedar"];
    [ingredient setModelWithShader:@"DROMEDAR" shader:@"ads_texture_bones"];
    [renderLoop addShapeShifter:@"DROMEDAR_O"];
    
    NSArray* models = [[NSArray alloc] initWithObjects: 
     @"Bonzoid",  @"Flapper",  @"Gollumer",  @"Humanoid",  @"Leggit",  @"Mechatron",  @"Paker", @"Spheroid", nil ]; 
    
    for(id model in models) {
        ingredient = [renderLoop createIngredient:model];
        [ingredient setModelWithShader:model shader:@"ads_texture_bones"];
        [renderLoop addShapeShifter:model];
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
    
    [button addModifier:@"released" Impersonator:buttonId Modifier:@"translation" Value:[[YAVector3f alloc] initVals: 0: 0.06f : 0]];
    [button addModifier:@"pressed" Impersonator:buttonId Modifier:@"translation" Value:[[YAVector3f alloc] initVals: 0: 0.02f : 0]];
    
    [button setRotation:[[YAVector3f alloc] initVals:0 :0 :0] ];
    [button setSize:[[YAVector3f alloc] initVals:0.2 :0.2 :0.2]];
    [button setState:@"released"];
    
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