//
//  YAGouradLight.m
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

@implementation YAGouradLight
@synthesize position, intensity, directional;

static const NSString* TAG = @"YAGouradLight";

- (id)init
{
    self = [super init];
    if (self) {
        directional = false;
        position = [[YAVector3f alloc] initVals:00.0f :10.0f :0.0f];
        intensity = [[YAVector3f alloc] initVals:0.8f :0.8f :0.8f];
    }
    return self;
}


- (void) shine: (YAShader*) shader transformator: (YATransformator*) transformator
{
    GLuint location = shader.locLightPosition;
    if (location != -1) {
        if (directional) 
            glUniform4f(location, position.x, position.y, position.z, 0.0f);
        else
            glUniform4f(location, position.x, position.y, position.z, 1.0f);
   }
    
    location = shader.locLightIntensity;
    if (location != -1) 
        glUniform3f(location, [intensity x], [intensity y], [intensity z]);
}

- (NSString *)description
{
    NSString* result = [NSString stringWithFormat: @"Object: %@ Position: %@ \n Directional: %d",
                        TAG,
                        position,
                        directional];
    
    return result;
}

@end
