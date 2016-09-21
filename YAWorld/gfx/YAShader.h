//
//  Shader.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 14.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YATexture;

#define shaderNotFoundException @"Ressource bundle corrupt."

@interface YAShader : NSObject {
@private
    NSString* name;
    
    GLuint fragmentShaderId, vertexShaderId, geometryShaderId;
    GLuint programId;
    
    NSString* lightType;
    
}


@property(strong, readonly) NSString* name;

@property (readonly) GLint locWorld;

@property (readonly) GLint locFogMaxDist;
@property (readonly) GLint locFogMinDist;
@property (readonly) GLint locFogColor;
@property (readonly) GLint locLightPosition;
@property (readonly) GLint locLightIntensity;
@property (readonly) GLint locTextureMap;
@property (readonly) GLint locNormalMap;
@property (readonly) GLint locDirectionalLightColor;
@property (readonly) GLint locDirectionalLightAmbientIntensity;
@property (readonly) GLint locDirectionalLightDiffuseIntensity;
@property (readonly) GLint locDirectionalLightDirection;

@property (readonly) GLint locEyePos;
@property (readonly) GLint locMatSpecularIntensity;
@property (readonly) GLint locMatSpecularPower;
@property (readonly) GLint locMaterialKa;
@property (readonly) GLint locMaterialKd;
@property (readonly) GLint locMaterialKs;
@property (readonly) GLint locMaterialShininess;
@property (readonly) GLint locMaterialReflection;
@property (readonly) GLint locMaterialRefraction;
@property (readonly) GLint locMaterialEta;
@property (readonly) GLint locLightLa;
@property (readonly) GLint locLightLd;
@property (readonly) GLint locLightLs;
@property (readonly) GLint locShadowMap;
@property (readonly) GLint locPosition;
@property (readonly) GLint locSkyMap;
@property (readonly) GLint locDiffuseMap;
@property (readonly) GLint locSpecularMap;
@property (readonly) GLint locSpotLightPosition;
@property (readonly) GLint locSpotLightIntensity;
@property (readonly) GLint locSpotLightDirection;
@property (readonly) GLint locSpotLightExponent;
@property (readonly) GLint locSpotLightCutoff;
@property (readonly) GLint locTexture;
@property (readonly) GLint locNormal;
@property (readonly) GLint locMVP;
@property (readonly) GLint locGObjectIndex;
@property (readonly) GLint locGDrawIndex;
@property (readonly) GLint locNormalMapFactor;
@property (readonly) GLint locShapeShifter;
@property (readonly) GLint locModel;
@property (readonly) GLint locEye;
@property (readonly) GLint locRatio;
@property (readonly) GLint locProjectionMatrix;
@property (readonly) GLint locModelViewMatrix;
@property (readonly) GLint locNormalMatrix;
@property (readonly) GLint locShadowMVP;
@property (readonly) GLint locNow;

- (id)initResource: (NSString*) shaderName light: (NSString*) light;

- (void)destroy;

- (void) activate;

- (GLuint) programId;

- (NSString*) requiredLight;

@end
