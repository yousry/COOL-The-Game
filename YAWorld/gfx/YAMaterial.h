//
//  YAMaterial.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 04.10.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YAShader, YATransformator, YAVector3f, YAModel;

@interface YAMaterial : NSObject {
    float specIntensity;
    float specPower;
    
    YAVector3f* phongAmbientReflectivity;
    YAVector3f* phongDiffuseReflectivity;
    YAVector3f* phongSpecularReflectivity;
    float phongShininess;
    
    float reflection;
    float refraction;
    float eta;
}


@property (strong, readonly) YAVector3f* phongAmbientReflectivity;
@property (strong, readonly) YAVector3f* phongDiffuseReflectivity;
@property (strong, readonly) YAVector3f* phongSpecularReflectivity;
@property (assign, readwrite) float phongShininess;
@property (assign, readwrite) float reflection;
@property (assign, readwrite) float refraction;
@property (assign, readwrite) float eta;


@property (assign, readwrite) float specIntensity;
@property (assign, readwrite) float specPower;

- (void)setup: (YAShader*)shader 
transformator: (YATransformator*) transformator 
GammaCorrection: (float) gammaCorrection
Model: (YAModel*) model;

@end
