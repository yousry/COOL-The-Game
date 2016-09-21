//
//  YAMaterial.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 04.10.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES
#define GLCOREARB_PROTOTYPES
#import <GL/glcorearb.h>

#import "YAModel.h"
#import "YATransformator.h"
#import "YAShader.h" 
#import "YAVector3f.h"
#import "YAMaterial.h"
#import "YALog.h"

@implementation YAMaterial {
    YAVector3f* gammaMaterial;
}

@synthesize phongAmbientReflectivity, phongDiffuseReflectivity, phongSpecularReflectivity, phongShininess, reflection, refraction, eta;


@synthesize specIntensity, specPower;

static const NSString* TAG = @"YAMaterial";

- (id) init
{
    self = [super init];
    if (self) {
        specIntensity = 1.0f;
        specPower = 10.0f;


        phongAmbientReflectivity = [[YAVector3f alloc] initVals:0.0f :0.2f :0.0f];
        phongDiffuseReflectivity = [[YAVector3f alloc] initVals:0.0f :0.4f :0.0f];
        phongSpecularReflectivity = [[YAVector3f alloc] initVals:0.0f :0.4f :0.0f];
        phongShininess = 4.0f;
        
        reflection = 0.5f;
        refraction = 0.5f;
        eta = 0.5f;
        
        gammaMaterial = [[YAVector3f alloc] init];
    }
    return self;
}


- (void)setup: (YAShader*)shader 
transformator: (YATransformator*) transformator 
GammaCorrection: (float) gammaCorrection
Model: (YAModel*) model
{
    const float gammaFix = gammaCorrection != -1 ? 1.0f / 1.0f + gammaCorrection : 1.0f;
    
    GLuint eyePosID =  shader.locEyePos;
    GLuint specIntID = shader.locMatSpecularIntensity;
    GLuint specPowerID = shader.locMatSpecularPower;
    
    if(eyePosID != -1) {
        YAVector3f* eyePos = [transformator eyePos];
        glUniform3f(eyePosID, eyePos.x, eyePos.y, eyePos.z);
    }
    
    if (specIntID != -1)
        glUniform1f(specIntID, specIntensity);
    
    if(specPowerID != -1)
        glUniform1f(specPowerID, specPower);
    
    [gammaMaterial setVector:phongAmbientReflectivity];
    gammaMaterial.x = powf(gammaMaterial.x, gammaFix);
    gammaMaterial.y = powf(gammaMaterial.y, gammaFix);
    gammaMaterial.z = powf(gammaMaterial.z, gammaFix);

    GLuint location = shader.locMaterialKa;
    if (location != -1) {
        glUniform3f(location, gammaMaterial.x, gammaMaterial.y, gammaMaterial.z);
    } 

    // [model writeClientMaterialKa:gammaMaterial];
    

    [gammaMaterial setVector:phongDiffuseReflectivity];
    gammaMaterial.x = powf(gammaMaterial.x, gammaFix);
    gammaMaterial.y = powf(gammaMaterial.y, gammaFix);
    gammaMaterial.z = powf(gammaMaterial.z, gammaFix);

    location =  shader.locMaterialKd;
    if (location != -1) {
        glUniform3f(location, gammaMaterial.x, gammaMaterial.y, gammaMaterial.z);
    }

    // [model writeClientMaterialKd:gammaMaterial];


    [gammaMaterial setVector:phongSpecularReflectivity];
    gammaMaterial.x = powf(gammaMaterial.x, gammaFix);
    gammaMaterial.y = powf(gammaMaterial.y, gammaFix);
    gammaMaterial.z = powf(gammaMaterial.z, gammaFix);
    
    location =  shader.locMaterialKs;
    if (location != -1) {
        glUniform3f(location, gammaMaterial.x, gammaMaterial.y, gammaMaterial.z);
    }

    // [model writeClientMaterialKs:gammaMaterial];
        
    location = shader.locMaterialShininess;
    if (location != -1)
        glUniform1f(location, phongShininess);

    // [model writeClientMaterialShininess:phongShininess];

    
    location =  shader.locMaterialReflection;
    if (location != -1)
        glUniform1f(location, reflection);

    // [model writeClientMaterialReflection:reflection];

    
    location =  shader.locMaterialRefraction;
    if (location != -1)
        glUniform1f(location, refraction);

    // [model writeClientMaterialRefraction:refraction];

    
    location =  shader.locMaterialEta;
    if (location != -1)
        glUniform1f(location, eta);

    // [model writeClientMaterialEta:eta];
    
    [YALog isGLStateOk:TAG message:@"setup FAILED"];
}

@end
