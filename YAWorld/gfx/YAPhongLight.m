//
//  YAPhongLight.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 09.11.11.
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
#import "YAPhongLight.h"

@implementation YAPhongLight

@synthesize position, ambientLightIntensity, diffuseLightIntensity, specularLightIntensity;

static const NSString* TAG = @"YAPhongLight";

- (id)init
{
    self = [super init];
    if (self) {
        
        position = [[YAVector4f alloc] initVals:5.0f :0.0f :-10.0f :1.0f];
        
        ambientLightIntensity = [[YAVector3f alloc] initVals:0.3f :0.3f :0.3f];
        diffuseLightIntensity = [[YAVector3f alloc] initVals:0.4f :0.4f :0.4f];
        specularLightIntensity = [[YAVector3f alloc] initVals:0.3f :0.3f :0.3f];

    }
    
    return self;
}


- (void) shine: (YAShader*) shader transformator: (YATransformator*) transformator
{
    GLuint location = shader.locLightPosition;
    if (location != -1) {
        YAVector4f* lighteyePos = [[transformator viewMatrix] mulVector4f:position];
        glUniform4f(location, lighteyePos.x, lighteyePos.y, lighteyePos.z, lighteyePos.w);
    }
     
    location = shader.locLightLa;
    if (location != -1) 
        glUniform3f(location, [ambientLightIntensity x], [ambientLightIntensity y], [ambientLightIntensity z]);

    location = shader.locLightLd;
    if (location != -1) 
        glUniform3f(location, [diffuseLightIntensity x], [diffuseLightIntensity y], [diffuseLightIntensity z]);
    
    location = shader.locLightLs;
    if (location != -1) 
        glUniform3f(location, [specularLightIntensity x], [specularLightIntensity y], [specularLightIntensity z]);
    
    [YALog isGLStateOk:TAG message:@"shine"];
}

@end
