//
//  YAGLExtensions.m
//  YAWorld
//
//  Created by Yousry Abdallah on 07.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES
#define GLCOREARB_PROTOTYPES
#import <GL/glcorearb.h>

#import "YALog.h"
#import "YAGLExtensions.h"

@implementation YAGLExtensions

static const NSString* TAG = @"YATexture";

+ (BOOL) extensionSupported: (NSString*) extension
{
    const char * pExtension = [ extension UTF8String ];
    
    
    const GLubyte *extensions = NULL;
    
    const GLubyte *start;
    
    GLubyte *where, *terminator;
    /* Extension names should not have spaces. */
    
    where = (GLubyte *) strchr(pExtension, ' ');
    
    if (where || *pExtension == '\0')
        return 0;
    
    GLint extensionCount;
    glGetIntegerv(GL_NUM_EXTENSIONS, &extensionCount);
    
    for(int i = 0; i < extensionCount; i++) {
        extensions = glGetStringi(GL_EXTENSIONS, i);
        
        start = extensions;
        for (;;) {
            
            where = (GLubyte *) strstr((const char *) start, pExtension);
            
            if (!where)
                
                break;
            
            terminator = where + strlen(pExtension);
            
            if (where == start || *(where - 1) == ' ')
                
                if (*terminator == ' ' || *terminator == '\0')
                    
                    return 1;
            
            start = terminator;
            
        }
    }
    [YALog isGLStateOk:TAG message:@"load / init FAILED"];
    return 0;
}

@end
