//
//  YADynamicGLAccess.m
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

#import "YAShader.h"
#import "YADynamicGLAccess.h"

@implementation YADynamicGLAccess

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


+ (NSArray*) getshaderAttribs: (YAShader*) shader
{
    return [YADynamicGLAccess shaderInputs: shader active:GL_ACTIVE_ATTRIBUTES maxLength:GL_ACTIVE_ATTRIBUTE_MAX_LENGTH];
}

+ (NSArray*) getshaderUniforms: (YAShader*) shader;
{
    return [YADynamicGLAccess shaderInputs: shader active:GL_ACTIVE_UNIFORMS maxLength:GL_ACTIVE_UNIFORM_MAX_LENGTH];
}


+ (NSArray*) shaderInputs: (YAShader*) shader active: (GLenum) activeE maxLength: (GLenum) maxLengthE
{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    GLint maxLength, nAttribs, written, size;
    GLenum type;
    
    glGetProgramiv([shader programId], activeE, &nAttribs);
    glGetProgramiv([shader programId], maxLengthE, &maxLength);
    
    GLchar* attribName = (GLchar*) malloc(maxLength);
    for (int i = 0; i < nAttribs; i++) {
        
        //WOOT: NO I WILL NOT PASS A FUNCTION POINTER 
        if (activeE == GL_ACTIVE_ATTRIBUTES) 
            glGetActiveAttrib([shader programId], i, maxLength, &written, &size, &type, attribName);
        else
            glGetActiveUniform([shader programId], i, maxLength, &written, &size, &type, attribName);
        
        
        
        NSString* name = [NSString stringWithUTF8String:attribName];
        // location = glGetAttribLocation([shader programId], attribName);
        [result addObject:name];
    }
    free(attribName);
    return [NSArray arrayWithArray:result];
}



@end
