//
//  YALog.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 14.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES
#define GLCOREARB_PROTOTYPES
#import <GL/glcorearb.h>

#import "YAPreferences.h"

#import "YALog.h"

@implementation YALog

NSDictionary* dictionary = nil;

#if defined(DEBUG)
static bool _isDebug = true;
#else
static bool _isDebug = false;
#endif

+ (bool) isDebug
{
    return _isDebug;
}

+ (void) setDebug: (bool)debug
{
    _isDebug = debug;
}

+ (void) debug: (NSString*) tag message: (NSString*) message
{
    if(_isDebug /* && ![tag isEqualToString:@"YAText2D"] && ![tag isEqualToString:@"YATextModel"] */) {
        NSLog(@"[%@] %@", tag, message);
    }
}

+ (void) log: (NSString*) tag message: (NSString*) message 
{
    NSLog(@"[%@] %@", tag, message);
}

+ (bool) isGLStateOk: (NSString*) tag message: (NSString*) message
{
    if(!_isDebug)
        return true;
    
    GLenum error = glGetError();
    if(GL_NO_ERROR == error) {
        return true;
    } else {
        
        NSString* errorType = nil;

        switch (error) {
            case GL_INVALID_ENUM:
                errorType = @"GL_INVALID_ENUM"; 
                break;
            case GL_INVALID_VALUE:
                errorType = @"GL_INVALID_VALUE"; 
                break;
            case GL_INVALID_OPERATION:
                errorType = @"GL_INVALID_OPERATION"; 
                break;
            case GL_OUT_OF_MEMORY:
                errorType = @"GL_OUT_OF_MEMORY"; 
                break;
            default:
                errorType = [NSString stringWithFormat:@"UNKNOWN %d", error];
                break;
        }
        
        NSLog(@"[%@] %@  [OpenGL] %@", tag, message, errorType);

        glfwTerminate();
        exit(0);
        
        return false;
    }
}

+ decode: (NSString*) code
{
    @synchronized(self) {

    if(dictionary == nil) {
        YAPreferences* prefs = [[YAPreferences alloc] init];

        NSString* locs = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Localizable.strings", prefs.resourceDir]];
        dictionary = [locs propertyListFromStringsFileFormat];
    }     

    NSString* result=[dictionary objectForKey:code];
    return result;

    }   


}

@end
