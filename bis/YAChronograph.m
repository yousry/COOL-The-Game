//
//  YAChronograph.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 04.03.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#define GLFW_INCLUDE_NONE
#import <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES 1
#define GL3_PROTOTYPES 1
#import <GL/glcorearb.h>

#import "YAChronograph.h"

@implementation YAChronograph

- (id) init
{
    self = [super init];
    if (self) {
        POI = glfwGetTime();
    }
    return self;
}

- (void) start
{
    POI = glfwGetTime();
}

-(double) getTime
{
    const double now =  glfwGetTime();
    return now - POI;
}

- (void) wait: (float) seconds
{
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow: seconds];
    [NSThread sleepUntilDate:runUntil];
}

- (void)dealloc
{
    currentLoop = nil;
    [timer invalidate];
}

@end
