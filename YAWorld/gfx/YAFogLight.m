//
//  YAFogLight.m
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
#import "YAGouradLight.h"

#import "YAFogLight.h"

@implementation YAFogLight

static const NSString* TAG = @"YAFogLight";

- (id)init
{
    self = [super init];
    if (self) {
        color = [[YAVector3f alloc] initVals:0.0f :0.0f :0.0f];
        maxDistance = 20.0f;
        minDistance = 5.0f;
    }
    return self;
}

- (void) shine: (YAShader*) shader transformator: (YATransformator*) transformator
{
    [super shine:shader transformator:transformator];
    
    GLuint location = shader.locFogMaxDist;
    if (location != -1) 
        glUniform1f(location, maxDistance);
    
    location = shader.locFogMinDist;
    if (location != -1) 
        glUniform1f(location, minDistance);

    location = shader.locFogColor;
    if (location != -1) 
        glUniform3f(location, color.x, color.y, color.z);

    [YALog isGLStateOk:TAG message:@"shine"];
    
}


@end
