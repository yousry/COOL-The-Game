//
//  YAPickMap.m
//  YAWorld
//
//  Created by Yousry Abdallah on 18.06.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES
#define GLCOREARB_PROTOTYPES
#import <GL/glcorearb.h>

#import "YAShader.h"
#import "YALog.h"
#import "YAPickMap.h"

@implementation YAPickMap
@synthesize width, height;

static const NSString* TAG = @"YAPickMap";


- (id)init
{
    self = [super init];
    if (self) {
        [YALog debug:TAG message:@"Init"];
        
        width = 512;
        height = 512;
        
        GLfloat border[] = {1.0f, 0.0f,0.0f,0.0f };
        
        glGenTextures(1, &colorTextureId);
        glBindTexture(GL_TEXTURE_2D, colorTextureId);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

        // glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB32F, width, height, 0, GL_RGB, GL_FLOAT, NULL);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB32UI, width, height, 0, GL_RGB_INTEGER, GL_UNSIGNED_INT, NULL);
        
        glGenTextures(1, &shadowTextureId);
        glBindTexture(GL_TEXTURE_2D, shadowTextureId);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);
        glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, border);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE, GL_COMPARE_REF_TO_TEXTURE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_FUNC, GL_LESS);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, width, height, 0, GL_DEPTH_COMPONENT, GL_FLOAT, NULL);

        
        glGenFramebuffers(1, &fbo);
        
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER,fbo);
        
        glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, colorTextureId, 0);
        glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, shadowTextureId, 0);

        
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (status != GL_FRAMEBUFFER_COMPLETE) 
            [YALog debug:TAG message:[NSString stringWithFormat:@"Pick Buffer not OK: %x", status]];
        else 
            [YALog debug:TAG message:@"Pick Buffer created succesfully!"];
        
        [YALog isGLStateOk:TAG message:@"Init"]; 
    }
    
    return self;
}

- (bool) setupWrite 
{
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, shadowTextureId);  
    
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER,fbo);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) 
        [YALog debug:TAG message:[NSString stringWithFormat:@"Shadowbuffer not OK: %x", status]];
    
    return [YALog isGLStateOk:TAG message:@"setupWrite"]; 
};

- (bool) bind: (YAShader*) shader
{
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, shadowTextureId);  
    
    GLuint loc = shader.locShadowMap;
    
    
    
    if(loc != -1) {
        glUniform1i(loc, 4);
    }

    return [YALog isGLStateOk:TAG message:@"shader"]; 
};

- (int) getImpAtX: (int) x Y: (int) y
{
    glBindFramebuffer(GL_READ_FRAMEBUFFER,fbo);
    glReadBuffer(GL_COLOR_ATTACHMENT0);
    
    int Pixel[3];
    // GLfloat Pixel[3];

    // glReadPixels(x, y, 1, 1, GL_RGB, GL_FLOAT, &Pixel);
    glReadPixels(x, y, 1, 1, GL_RGB_INTEGER, GL_UNSIGNED_INT, &Pixel);

    glReadBuffer(GL_NONE);
    glBindFramebuffer(GL_READ_FRAMEBUFFER, 0);

    return abs(Pixel[0]);
}

@end
