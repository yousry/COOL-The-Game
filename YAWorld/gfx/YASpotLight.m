//
//  YASpotLight.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 11.11.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES
#define GLCOREARB_PROTOTYPES
#import <GL/glcorearb.h>

#import "YATransformator.h"
#import "YADynamicGLAccess.h"
#import "YAVector3f.h"
#import "YAVector4f.h"
#import "YAShader.h"
#import "YALog.h"
#import "YAMatrix4f.h"
#import "YASpotLight.h"

@implementation YASpotLight

@synthesize position, cutoff, exponent, intensity;
static const NSString* TAG = @"YASpotLight";

- (id)init
{
    self = [super init];
    if (self) {
        position = [[YAVector3f alloc] initVals:0.0f :10.0f :0.0f];
        direction = [[YAVector3f alloc] initVals: 0.0f :-1.0f :0.0f];
        [direction normalize];
        intensity = [[YAVector3f alloc] initVals:1.0f :1.0f :1.0f];
        exponent = 40.0f;
        cutoff = 15.0f;
        
    }
    return self;
}


- (void) shine: (YAShader*) shader transformator: (YATransformator*) transformator
{
    positionID = shader.locSpotLightPosition;
    intensityID = shader.locSpotLightIntensity;
    directionID = shader.locSpotLightDirection;
    exponentID =  shader.locSpotLightExponent;
    cutoffID = shader.locSpotLightCutoff;
    
    if (positionID != -1)
        glUniform4f(positionID, position.x, position.y, position.z, 1);
    
    if (intensityID != -1)
        glUniform3f(intensityID, [intensity x], [intensity y], [intensity z]);
    
    if (directionID != -1)
        glUniform3f(directionID, [direction x], [direction y], [direction z]);
    
    if (exponentID != -1)
        glUniform1f(exponentID, exponent);
    
    if (cutoffID != -1)
        glUniform1f(cutoffID, cutoff);
    
    [YALog isGLStateOk:TAG message:@"shine"];
    
}

- (void) spotAt: (YAVector3f*) target
{
    direction = [[YAVector3f alloc] initVals:target.x -position.x :target.y - position.y :target.z - position.z];
    [direction normalize];
}

- (NSString *)description
{
    NSString* result = [NSString stringWithFormat: @"Position: %@ \n Direction: %@, \n Exponent: %f, \n Cutoff: %f",
                        position,
                        direction,
                        exponent,
                        cutoff];
    
    return result;
}

@end
