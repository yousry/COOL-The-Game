//
//  YATransformator.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 19.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <math.h>
#define ToRadian(x) ((x) * M_PI / 180.0f)
#define ToDegree(x) ((x) * 180.0f / M_PI)

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES
#define GLCOREARB_PROTOTYPES
#import <GL/glcorearb.h>

#import "YAVector3f.h"
#import "YAMatrix4f.h"
#import "YAPerspectiveProjectionInfo.h"
#import "YALog.h"
#import "YATransformator.h"


@interface YATransformator()

- (void) setRotateTransform: (float)rotateX : (float)rotateY : (float)rotateZ;

@end

@implementation YATransformator

static const NSString* TAG = @"YATransformator";

@synthesize modelMatrix = modelM;
@synthesize viewMatrix = viewM;
@synthesize projectionMatrix = projectionM;
@synthesize modelviewMatrix = modelViewM;
@synthesize scale, rotate, translate;
@synthesize eyePos, eyeFocus, eyeUp;
@synthesize renderWidth, renderHeight;
@synthesize projectionInfo;
@synthesize rotateQuatMatrix;

- (id)init
{
    self = [super init];
    if (self) {
        [YALog debug:TAG message:[NSString stringWithFormat:@"Init" ]];
        // for speed improvements these are only initialized once
        rotateM = [[YAMatrix4f alloc] init];
        rx = [[YAMatrix4f alloc]init];
        ry = [[YAMatrix4f alloc]init];
        rz = [[YAMatrix4f alloc]init];
        
        rotateQuatMatrix = nil;

        modelViewM = [[YAMatrix4f alloc] init];
        viewM = [[YAMatrix4f alloc] init];
        modelM = [[YAMatrix4f alloc] init];
        tempM = [[YAMatrix4f alloc] init];
        
        // ------------------------------------------------------
        
        scale = [[YAVector3f alloc] initVals:1.0f :1.0f :1.0f];
        rotate = [[YAVector3f alloc] initVals:0.0f :0.0f :0.0f];
        translate = [[YAVector3f alloc] initVals:0.0f :0.0f :0.0f];
        
        projectionInfo = [[YAPerspectiveProjectionInfo alloc] init];
        
        [projectionInfo setFieldOfView:30.0f];
        [projectionInfo setWidth:560.0f];
        [projectionInfo setHeight:325.0f];
        [projectionInfo setZNear:1.0f];
        [projectionInfo setZFar:100.0f];
        
        renderWidth = 560;
        renderHeight = 325;
        
        
        projectionM = [[YAMatrix4f alloc] initPerspectiveProjectionTransform:projectionInfo];
        
        eyePos = [[YAVector3f alloc] initVals:0.0f :0.0f :0.0f];
        eyeFocus = [[YAVector3f alloc] initVals:0.0f :0.0f :1.0f];
        eyeUp = [[YAVector3f alloc] initVals:0.0f :1.0f :0.0f];
        
        
        [self recalcCam];
    }
    return self;
}

- (void)recalcCam
{
    cameraM = [[YAMatrix4f alloc] initCameraTransform:eyeFocus up:eyeUp];
    cameraTM = [[YAMatrix4f alloc] initTranslationTransform: -[eyePos x] :-[eyePos y] :-[eyePos z]];
    
    projectionM = [[YAMatrix4f alloc] initPerspectiveProjectionTransform:projectionInfo];

}


- (const YAMatrix4f*) transform 
{
    YAMatrix4f* scaleM = [[YAMatrix4f alloc] initScaleTransform:[scale x] :[scale y] :[scale z]];

    if(rotateQuatMatrix == nil)
        [self setRotateTransform: [rotate x] :[rotate y]  :[rotate z] ];
    else
        [rotateM setMatrix:rotateQuatMatrix];
    
    YAMatrix4f* translateM = [[YAMatrix4f alloc] initTranslationTransform:[translate x] :[translate y] :[translate z]];
    
    [translateM mulMatrix4f:rotateM into: tempM];
    [tempM mulMatrix4f:scaleM into:modelM];
    
    [cameraM mulMatrix4f: cameraTM into: viewM];
    [viewM mulMatrix4f: modelM into:modelViewM];
    
    return [projectionM mulMatrix4f: modelViewM]; 
}

- (void)setDisplaySize: (int)width height:(int)height {
    
    renderWidth = width;
    renderHeight = height;
    
    [projectionInfo setWidth:(float)width];
    [projectionInfo setHeight:(float)height];
    projectionM = [[YAMatrix4f alloc] initPerspectiveProjectionTransform:projectionInfo];
}

- (YAMatrix4f*) cameraTransformationMatrix {
    return [cameraM mulMatrix4f: cameraTM];
}


- (void)setRotateTransform: (float)rotateX : (float)rotateY : (float)rotateZ
{
    const float x = ToRadian(rotateX);
    const float sinX = sin(x);
    const float cosX = cos(x);

    const float y = ToRadian(rotateY);
    const float sinY = sin(y);
    const float cosY = cos(y);
    
    const float z = ToRadian(rotateZ);
    const float sinZ = sin(z);
    const float cosZ = cos(z);
    
    rx->m[0][0] = 1.0f; rx->m[0][1] = 0.0f   ; rx->m[0][2] = 0.0f    ; rx->m[0][3] = 0.0f;
    rx->m[1][0] = 0.0f; rx->m[1][1] = cosX   ; rx->m[1][2] = -sinX   ; rx->m[1][3] = 0.0f;
    rx->m[2][0] = 0.0f; rx->m[2][1] = sinX   ; rx->m[2][2] = cosX    ; rx->m[2][3] = 0.0f;
    rx->m[3][0] = 0.0f; rx->m[3][1] = 0.0f   ; rx->m[3][2] = 0.0f    ; rx->m[3][3] = 1.0f;
    
    ry->m[0][0] = cosY   ; ry->m[0][1] = 0.0f; ry->m[0][2] = -sinY   ; ry->m[0][3] = 0.0f;
    ry->m[1][0] = 0.0f   ; ry->m[1][1] = 1.0f; ry->m[1][2] = 0.0f    ; ry->m[1][3] = 0.0f;
    ry->m[2][0] = sinY   ; ry->m[2][1] = 0.0f; ry->m[2][2] = cosY    ; ry->m[2][3] = 0.0f;
    ry->m[3][0] = 0.0f   ; ry->m[3][1] = 0.0f; ry->m[3][2] = 0.0f    ; ry->m[3][3] = 1.0f;
    
    rz->m[0][0] = cosZ   ; rz->m[0][1] = -sinZ   ; rz->m[0][2] = 0.0f; rz->m[0][3] = 0.0f;
    rz->m[1][0] = sinZ   ; rz->m[1][1] = cosZ    ; rz->m[1][2] = 0.0f; rz->m[1][3] = 0.0f;
    rz->m[2][0] = 0.0f   ; rz->m[2][1] = 0.0f    ; rz->m[2][2] = 1.0f; rz->m[2][3] = 0.0f;
    rz->m[3][0] = 0.0f   ; rz->m[3][1] = 0.0f    ; rz->m[3][2] = 0.0f; rz->m[3][3] = 1.0f;
    
    [rz mulMatrix4f: ry into:tempM];
    [tempM mulMatrix4f: rx into: rotateM];
}

- (NSArray*) trapezoid
{
    NSArray* result = [[NSArray alloc] init];

    YAVector3f* pZNear = [[YAVector3f alloc] initCopy:eyeFocus];
    [pZNear mulScalar: projectionInfo.zNear];
    [pZNear addVector:eyePos];

    YAVector3f* pZFar = [[YAVector3f alloc] initCopy:eyeFocus];
    [pZFar mulScalar: projectionInfo.zFar];
    [pZFar addVector:eyePos];

    const float fovRadeanTan = tan(ToRadian(projectionInfo.fieldOfView));
    float zUpNear = projectionInfo.zNear * fovRadeanTan;
    float zUpFar = projectionInfo.zFar * fovRadeanTan;
    
    float ar = projectionInfo.width / projectionInfo.height;
    float zRightNear = zUpNear * ar;
    float zRightFar = zUpFar * ar;

    YAVector3f* right = [[YAVector3f alloc]initCopy:eyeFocus];
    [right crossVector:eyeUp];
    [right normalize];
    
    YAVector3f* nearUp = [[YAVector3f alloc] initCopy:eyeUp];
    [nearUp mulScalar:zUpNear];
    YAVector3f* nearRight = [[YAVector3f alloc] initCopy:right];
    [nearRight mulScalar:zRightNear];

    YAVector3f* farUp = [[YAVector3f alloc] initCopy:eyeUp];
    [farUp mulScalar:zUpFar];
    YAVector3f* farRight = [[YAVector3f alloc] initCopy:right];
    [farRight mulScalar:zRightFar];

    // near calculations
    YAVector3f* vec = [[YAVector3f alloc] initCopy:pZNear];
    [vec subVector:nearRight];
    [vec addVector:nearUp];
    result = [result arrayByAddingObject:vec];
    
    vec = [[YAVector3f alloc] initCopy:pZNear];
    [vec addVector:nearRight];
    [vec addVector:nearUp];
    result = [result arrayByAddingObject:vec];

    vec = [[YAVector3f alloc] initCopy:pZNear];
    [vec addVector:nearRight];
    [vec subVector:nearUp];
    result = [result arrayByAddingObject:vec];
    
    vec = [[YAVector3f alloc] initCopy:pZNear];
    [vec subVector:nearRight];
    [vec subVector:nearUp];
    result = [result arrayByAddingObject:vec];

    // far Calulations
    vec = [[YAVector3f alloc] initCopy:pZFar];
    [vec subVector:farRight];
    [vec addVector:farUp];
    result = [result arrayByAddingObject:vec];
    
    vec = [[YAVector3f alloc] initCopy:pZFar];
    [vec addVector:farRight];
    [vec addVector:farUp];
    result = [result arrayByAddingObject:vec];
    
    vec = [[YAVector3f alloc] initCopy:pZFar];
    [vec addVector:farRight];
    [vec subVector:farUp];
    result = [result arrayByAddingObject:vec];
    
    vec = [[YAVector3f alloc] initCopy:pZFar];
    [vec subVector:farRight];
    [vec subVector:farUp];
    result = [result arrayByAddingObject:vec];
    
    // also add centers
    result = [result arrayByAddingObject:pZNear];
    result = [result arrayByAddingObject:pZFar];
    
    return result;
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"EyePos: %@, eyeFocus: %@, eyeUp: %@", eyePos, eyeFocus, eyeUp];
}

@end
