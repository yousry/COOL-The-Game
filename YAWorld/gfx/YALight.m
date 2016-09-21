//
//  YALight.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 23.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES
#define GLCOREARB_PROTOTYPES
#import <GL/glcorearb.h>



#import "YAVector3f.h"
#import "YAShader.h"
#import "YALog.h"
#import "YALight.h"

@implementation YALight

@synthesize ambientColor;
@synthesize ambientIntensity;
@synthesize direction;
@synthesize diffuseIntensity;

static const NSString* TAG = @"YALight";

- (id)init
{
    self = [super init];
    if (self) {
        ambientIntensity = 0.2f;
        ambientColor = [[YAVector3f alloc] initVals:1.0f :1.0f :1.0f];
        
        diffuseIntensity = 0.2f;
        direction = [[YAVector3f alloc] initVals:-1.0f :0.0f :0.0f];

    }
    
    return self;
}

- (void) shine: (YAShader*) shader transformator: (YATransformator*) transformator
{
    GLuint acolorL = shader.locDirectionalLightColor;
    GLuint aIntensL = shader.locDirectionalLightAmbientIntensity;

    GLuint dIntensL = shader.locDirectionalLightDiffuseIntensity;
    GLuint ddirectL = shader.locDirectionalLightDirection;
    
    glUniform1f(aIntensL, ambientIntensity);
    glUniform3f(acolorL, ambientColor.x, ambientColor.y, ambientColor.z);

    
    

    glUniform1f(dIntensL, diffuseIntensity);
    [direction normalize];
    glUniform3f(ddirectL, direction.x, direction.y, direction.z);
    
    [YALog isGLStateOk:TAG message:@"shine"];
    
}

- (const NSString*) name
{
    return [self className];
}


@end
