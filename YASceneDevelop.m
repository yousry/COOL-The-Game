//
//  YASceneDevelop.m
//
//  Created by Yousry Abdallah.
//  Copyright 2013 yousry.de. All rights reserved.


#import "YAGouradLight.h"
#import "YASpotLight.h"
#import "YALight.h"

#import "YAOpenAL.h"

#import "YAPerspectiveProjectionInfo.h"
#import "YATransformator.h"

#import "YABasicAnimator.h"
#import "YABlockAnimator.h"

#import "YAMaterial.h"
#import "YAAvatar.h"
#import "YAVector3f.h"
#import "YAIngredient.h"
#import "YAImpersonator.h" 


#import "YALog.h"
#import "YARenderLoop.h"
#import "YASceneDevelop.h" 

static const NSString* TAG = @"YAScene";

@implementation YASceneDevelop : NSObject 

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

    YAIngredient* maskIngredient = [renderLoop createIngredient:@"mask"];
    [maskIngredient setModelWithShader:@"mask" shader:@"gourad_reflect"];
    int maskId = [renderLoop createImpersonator:@"mask"];
    __block YAImpersonator* maskImp = [renderLoop getImpersonator: maskId];

    maskImp.backfaceCulling = NO;
    maskImp.clickable = YES;

    [maskImp resize: 1];
    maskImp.rotation.x = -90;
    maskImp.translation.y = 0;


    [[[maskImp material] phongAmbientReflectivity] setValues: 0.0 : 0.3 : 0.2];
    maskImp.material.phongShininess = 25;
    maskImp.material.specIntensity = 10;        
    maskImp.material.reflection = 0.025;
    maskImp.material.refraction = 0;

    YABlockAnimator* anim = [renderLoop createBlockAnimator];
    [anim addListener:^(float spanPos, NSNumber* event, int message) 
     {
        event_keyPressed ev = event.intValue;

       int evBin = message & 255;
       int deviceId = message >> 16;
       float evVal = (float)(message & 255) / 255.0f - 0.5f;

        switch(ev) {
            case GAMEPAD_LEFT_X:
                maskImp.rotation.y = evVal *  100;
                break;
            case GAMEPAD_LEFT_Y:               
                maskImp.rotation.x = -90 + evVal *  - 100;
                break;
             case GAMEPAD_BUTTON_A:
                // NSLog(@"A: %d", evBin);
             break;   
             case GAMEPAD_BUTTON_OK:
                // NSLog(@"%d", deviceId);
             break;   
            default: 
                break;
        }
     }];


     [anim addListener:^(float spanPos, NSNumber* event, int message) 
     {

        switch ([event intValue]) {
            case MOUSE_DOWN:
                // NSLog(@"Message: %d %d", message , maskId);
                break;
            default:
                break;
        }
     }];



    NSArray* lights = [renderLoop lights];
    __block YAGouradLight* light;
    __block YASpotLight* spotLight;

    for (YALight* lit in lights) {
        if([[lit name] isEqualToString:@"YAGouradLight"])
            light = (YAGouradLight*)lit;
        else if([[lit name] isEqualToString:@"YASpotLight"]) {
            spotLight = (YASpotLight*)lit;
        }
    }
    
    [[spotLight position] setValues:1 :2 :-5.5];
    [spotLight setExponent:50];
    [spotLight spotAt:maskImp.translation];
    [[spotLight intensity] setVector:[[YAVector3f alloc] initVals: 1.0 : 1.0 : 1.0 ]];
    
    [[light position] setValues:0 :-1 :-1.5];
    [light setDirectional:NO];
    [[light intensity] setVector:[[YAVector3f alloc] initVals: 1.0: 1.0 : 1.0 ]];

    __block YAAvatar* avatar = [renderLoop avatar];
    avatar.position.z = -3.5;
    avatar.position.y = 0.5;
    [avatar lookAt:maskImp.translation];

    anim = [renderLoop createBlockAnimator];
    anim.asyncProcessing = NO;
    anim.progress = harmonic;
    [anim addListener:^(float sp, NSNumber* event, int message) 
    {
        // YAVector3f* la = [[YAVector3f alloc] initCopy: maskImp.translation];
        YAVector3f* la = [[YAVector3f alloc] init];
        la.y +=  sp * 0.15;
        [avatar lookAt:la];
    }];


    renderLoop.transformer.projectionInfo.zNear = 1.0;
    renderLoop.transformer.projectionInfo.zFar = 1000.0;
    [[renderLoop transformer] recalcCam];

    [renderLoop setSkyMap:@"CH"];
    [renderLoop changeImpsSortOrder:SORT_SHADER];
	[renderLoop resetAnimators];
    [renderLoop setActiveAnimation:true];
	renderLoop.drawScene = YES;
}

@end