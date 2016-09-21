//
//  Animator.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 17.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES
#define GLCOREARB_PROTOTYPES
#import <GL/glcorearb.h>

#import "YAVector3f.h"
#import "YAShader.h"
#import "YAModel.h"
#import "YAMatrix4f.h"
#import "YATransformator.h"
#import "YALog.h"
#import "YAAnimator.h"

@interface YAAnimator()

- (void)computePositionOffsets;


@end

@implementation YAAnimator

const NSString* TAG = @"Animator";

@synthesize transformator;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initSetup: (NSString*) name shader: (YAShader*) shader model: (YAModel*) model
{
    [YALog debug:TAG message:@"setup" ];
    [YALog isGLStateOk:TAG message:@"setup / start FAILED"];
    
    self = [super init];
    if (self) {
        _shader = shader;
        _name = name;
        _model = model;
        
        lastComputation = 0;
        maxDuration = 0;
        
        transformator = [[YATransformator alloc] init];
        
    }
    
    return self;
}

- (void)computePositionOffsets
{
    const float fLoopDuration = 5.0f;
    const float fScale = 3.14159f * 2.0f / fLoopDuration;
    
    float fElapsedTime = _stageTime;
    
    if(lastComputation == 0) {
        lastComputation = fElapsedTime;
        [YALog debug:TAG message:@"Init Time" ];
    }
    
    float thisDuration = fElapsedTime - lastComputation;
    
    if(thisDuration > maxDuration ) {
        [YALog debug:TAG message:[NSString stringWithFormat:@"Maximum loop interval: %f", thisDuration ]  ];
        maxDuration = thisDuration; 
    }
    
    lastComputation = fElapsedTime;
    
    
    float fCurrTimeThroughLoop = fmodf(fElapsedTime, fLoopDuration);
    
    xOffset = cosf(fCurrTimeThroughLoop * fScale) * 0.5f;
    yOffset = sinf(fCurrTimeThroughLoop * fScale) * 0.5f;
}



- (void)pose
{
 
    YAVector3f* rotate = [transformator rotate];
    [rotate setX:-90];
    [rotate setY:180];
    [rotate setZ:0];

    YAVector3f* scale = [transformator scale];
    [scale setX:10];
    [scale setY:10];
    [scale setZ:1];

    YAVector3f* translate = [transformator translate];
    [translate setX:0];
    [translate setY:-2];
    [translate setZ:5.0f];
    
    const YAMatrix4f* world = [transformator transform];
    
    [_shader activate];
    const GLint gWorldLocation = _shader.locWorld;
    
    glUniformMatrix4fv(gWorldLocation, 1, GL_TRUE, &(world->m[0][0]));
    [YALog isGLStateOk:TAG message:@"setup / glUniformMatrix4fv FAILED"];
}

- (void)stage: (float)stageTime
{
    _stageTime = stageTime;
    [self computePositionOffsets];
    [_shader activate];
    
    
    
    YAVector3f* rotate = [transformator rotate];
    [rotate setX:0];
    [rotate setY:yOffset * 360];
    [rotate setZ:-yOffset * 360];
    
    
    YAVector3f* scale = [transformator scale];
    [scale setX:0.4];
    [scale setY:0.4];
    [scale setZ:0.4];
    
    YAVector3f* translate = [transformator translate];
        [translate setX:0];
        [translate setY:0];
        [translate setZ:5.0f];
    
    
    const YAMatrix4f* world = [transformator transform];
    
    [_shader activate];
    const GLint gWorldLocation = _shader.locWorld;
    
    
    
    glUniformMatrix4fv(gWorldLocation, 1, GL_TRUE, &(world->m[0][0]));
    [YALog isGLStateOk:TAG message:@"setup / glUniformMatrix4fv FAILED"];
    
}

@end
