//
//  YAShadowMap.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 28.11.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES
#define GLCOREARB_PROTOTYPES
#import <GL/glcorearb.h>

#import "YAShader.h"
#import "YALog.h"
#import "YAShadowMap.h"

@implementation YAShadowMap

@synthesize width, height;

static const NSString* TAG = @"YAShadowMap";

- (id) initResolution: (int) pixel;
{
    self = [super init];
    if (self) {
        
        
        [YALog debug:TAG message:@"Init"];
        
        width = pixel;
        height = pixel;
        
        GLfloat border[] = {1.0f, 0.0f,0.0f,0.0f };
 
        glGenTextures(1, &shadowTextureId);
        glBindTexture(GL_TEXTURE_2D, shadowTextureId);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);
        glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, border);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE, GL_COMPARE_REF_TO_TEXTURE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_FUNC, GL_LESS);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT16, width, height, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_BYTE, NULL);

        
        glGenFramebuffers(1, &fbo);

        glBindFramebuffer(GL_DRAW_FRAMEBUFFER,fbo);
        
        GLenum drawBuffers[] = {GL_NONE};
        glDrawBuffers(1, drawBuffers);

        glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, shadowTextureId, 0);
        
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (status != GL_FRAMEBUFFER_COMPLETE) 
            [YALog debug:TAG message:[NSString stringWithFormat:@"Shadowbuffer not OK: %x", status]];
        else 
            [YALog debug:TAG message:@"Shadowbuffer created succesfully!"];
        
        [YALog isGLStateOk:TAG message:@"Init"]; 
    }
    
    return self;
}

- (void)destroy 
{
    [YALog debug:TAG message:@"destroy"];
    glDeleteTextures(1, &shadowTextureId);
    glBindFramebuffer(GL_FRAMEBUFFER,0);
    glDeleteFramebuffers(1, &fbo);
    [YALog isGLStateOk:TAG message:@"destroy"]; 
}

- (void) dealloc
{
    [self destroy];
}


- (bool) setupWrite
{
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, shadowTextureId);  
    
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER,fbo);
    glDrawBuffer(GL_NONE);    
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER); // GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT
    if (status != GL_FRAMEBUFFER_COMPLETE) 
        [YALog debug:TAG message:[NSString stringWithFormat:@"Shadowbuffer not OK: %x", status]];
    
    return [YALog isGLStateOk:TAG message:@"setupWrite"]; 
}

- (bool) bind: (YAShader*) shader
{
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, shadowTextureId);  
    
    GLuint loc = shader.locShadowMap;

    if(loc != -1) {
        glUniform1i(loc, 3);
    }

    return [YALog isGLStateOk:TAG message:@"shader"]; 
}




@end
