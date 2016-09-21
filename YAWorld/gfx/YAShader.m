//
//  Shader.m
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

#import "fuTypes.h"
#import "YALog.h"
#import "YATexture.h"
#import "YAShader.h"
#import "YAPreferences.h"


@interface YAShader()

- (GLuint)createShader: (NSString*) filename shaderType: (GLenum) shaderType;
- (bool) compileWithDebug: (GLuint) shader;
- (bool) linkWithDebug;
- (void) initLocations;
@end 

@implementation YAShader

static const NSString* TAG = @"YAShader";
static const NSString* SHADER_DIR = @"shader";

static YAShader* ACTIVE_SHADER;

@synthesize name;


@synthesize locWorld, locFogMaxDist, locFogMinDist, locFogColor,
            locLightPosition, locLightIntensity,
            locTextureMap, locNormalMap,
            locDirectionalLightColor, locDirectionalLightAmbientIntensity, locDirectionalLightDiffuseIntensity, locDirectionalLightDirection,
            locEyePos, locMatSpecularIntensity, locMatSpecularPower, locMaterialKa ,locMaterialKd,locMaterialKs,locMaterialShininess,
            locMaterialReflection, locMaterialRefraction, locMaterialEta,
            locLightLa, locLightLd, locLightLs,
            locShadowMap, locPosition, locSkyMap, locDiffuseMap, locSpecularMap,
            locSpotLightPosition, locSpotLightIntensity, locSpotLightDirection, locSpotLightExponent, locSpotLightCutoff,
            locTexture, locNormal, locMVP, locGObjectIndex, locGDrawIndex,
            locNormalMapFactor, locShapeShifter,
            locModel, locEye, locRatio, locProjectionMatrix, locModelViewMatrix, locNormalMatrix,
            locShadowMVP, locNow;

- (id)initResource: (NSString*) shaderName light: (NSString*) light
{
    [YALog debug:TAG message:@"initResource"];
    self = [super init];
    if (self) {
        
        name = shaderName;
        lightType = light;
        
        fragmentShaderId = 0, vertexShaderId = 0, geometryShaderId = 0;
        programId = 0;
        
        vertexShaderId = [self createShader:shaderName shaderType:GL_VERTEX_SHADER];
        [self compileWithDebug:vertexShaderId];
        fragmentShaderId = [self createShader:shaderName shaderType:GL_FRAGMENT_SHADER]; 
        [self compileWithDebug:fragmentShaderId];
        geometryShaderId = [self createShader:shaderName shaderType:GL_GEOMETRY_SHADER]; 
        if(geometryShaderId > 0) {
            [self compileWithDebug:geometryShaderId];
        }
        
        [self linkWithDebug];
        
        glDeleteShader(vertexShaderId);
        [YALog isGLStateOk:TAG message:@"initResource / glDeleteShader(vertexShader)"];
        glDeleteShader(fragmentShaderId);
        [YALog isGLStateOk:TAG message:@"initResource / glDeleteShader(fragmentShader)"];
        
        if(geometryShaderId > 0) {
            glDeleteShader(geometryShaderId);
            [YALog isGLStateOk:TAG message:@"initResource / glDeleteShader(geometryShaderId)"];
        }
        
        
        [self initLocations];
        
    }
    
    return self;
}

- (void) initLocations
{
    [YALog debug:TAG message:@"initLocations"];
    [YALog isGLStateOk:TAG message:@"initLocations / start"];
    
    glUseProgram(programId);
    [YALog isGLStateOk:TAG message:@"initLocations / use program"];
    
    locWorld = glGetUniformLocation(programId, "world");
    locFogMaxDist = glGetUniformLocation(programId, "clientFog.maxDist");
    locFogMinDist = glGetUniformLocation(programId, "clientFog.minDist");
    locFogColor = glGetUniformLocation(programId, "clientFog.color");

    locLightPosition = glGetUniformLocation(programId, "clientLight.Position");
    locLightIntensity = glGetUniformLocation(programId, "clientLight.Intensity");
 
    locTextureMap = glGetUniformLocation(programId , "textureMap");
    locNormalMap = glGetUniformLocation(programId , "normalMap");
    locDirectionalLightColor =  glGetUniformLocation(programId,  "directionalLight.color");
    locDirectionalLightAmbientIntensity = glGetUniformLocation(programId,  "directionalLight.ambientIntensity");
    locDirectionalLightDiffuseIntensity = glGetUniformLocation(programId,  "directionalLight.diffuseIntensity");
    locDirectionalLightDirection = glGetUniformLocation(programId,  "directionalLight.direction");
    locEyePos =  glGetUniformLocation(programId,  "eyePos");
    locMatSpecularIntensity =  glGetUniformLocation(programId,  "matSpecularIntensity");
    locMatSpecularPower =  glGetUniformLocation(programId,  "matSpecularPower");
    locMaterialKa =  glGetUniformLocation(programId, "clientMaterial.Ka");
    locMaterialKd =  glGetUniformLocation(programId, "clientMaterial.Kd");
    locMaterialKs =  glGetUniformLocation(programId, "clientMaterial.Ks");
    locMaterialShininess =  glGetUniformLocation(programId, "clientMaterial.Shininess");
    locMaterialReflection =  glGetUniformLocation(programId, "clientMaterial.Reflection");
    locMaterialRefraction =  glGetUniformLocation(programId, "clientMaterial.Refraction");
    locMaterialEta =  glGetUniformLocation(programId, "clientMaterial.Eta");
    
    locLightLa = glGetUniformLocation(programId, "clientLight.La");
    locLightLd = glGetUniformLocation(programId, "clientLight.Ld");
    locLightLs = glGetUniformLocation(programId, "clientLight.Ls");


    locShadowMap = glGetUniformLocation(programId, "shadowMap");
    locSkyMap = glGetUniformLocation(programId, "clientSkyMap");
    locDiffuseMap = glGetUniformLocation(programId, "clientDiffuseMap");
    locSpecularMap = glGetUniformLocation(programId, "clientSpecularMap");
    locSpotLightPosition = glGetUniformLocation(programId, "clientSpotLight.position");
    locSpotLightIntensity = glGetUniformLocation(programId, "clientSpotLight.intensity");
    locSpotLightDirection = glGetUniformLocation(programId, "clientSpotLight.direction");
    locSpotLightExponent = glGetUniformLocation(programId, "clientSpotLight.exponent");
    locSpotLightCutoff = glGetUniformLocation(programId, "clientSpotLight.cutoff");
    locNormal = glGetUniformLocation(programId, "clientNormal");
    locMVP = glGetUniformLocation(programId, "clientMVP");
    locGObjectIndex = glGetUniformLocation(programId, "gObjectIndex");
    locGDrawIndex = glGetUniformLocation(programId, "gDrawIndex");
    locNormalMapFactor = glGetUniformLocation(programId, "clientNormalMapFactor");
    locShapeShifter = glGetUniformLocation(programId, "clientShapeShifter");
    locModel = glGetUniformLocation(programId, "clientModel");
    locEye = glGetUniformLocation(programId, "clientEye");
    locRatio = glGetUniformLocation(programId, "clientRatio");
    locProjectionMatrix = glGetUniformLocation(programId, "clientProjectionMatrix");
    locModelViewMatrix = glGetUniformLocation(programId, "clientModelViewMatrix");
    locNormalMatrix = glGetUniformLocation(programId, "clientNormalMatrix");
    locShadowMVP = glGetUniformLocation(programId, "clientShadowMVP");
    locNow = glGetUniformLocation(programId, "clientNow");
    locPosition = glGetAttribLocation(programId, "clientPosition");
    locTexture = glGetAttribLocation(programId, "clientTexture");
    
    [YALog isGLStateOk:TAG message:@"initLocations / exit FAILED"];
}


- (GLuint)createShader: (NSString*) filename shaderType: (GLenum) shaderType 
{
    [YALog isGLStateOk:TAG message:@"createShader / start"];


    GLuint shader;
   
    NSString* filetype = nil;
    
    switch (shaderType) {
        case GL_FRAGMENT_SHADER:
            [YALog debug:TAG message:[NSString stringWithFormat:@"Create Fragment Shader: %@", filename]];
            filetype = @"fsh";
            break;
        case GL_VERTEX_SHADER:
            [YALog debug:TAG message:[NSString stringWithFormat:@"Create Vertex Shader: %@", filename]];
            filetype = @"vsh";
            break;
        case GL_GEOMETRY_SHADER:
            [YALog debug:TAG message:[NSString stringWithFormat:@"Create Geometry Shader: %@", filename]];
            filetype = @"gsh";
            break;
        default:
            filetype = nil;
            break;
    }

    if(nil == filetype)
        [NSException raise:shaderNotFoundException format:@"Illegal shader type: %@", filename];

    YAPreferences* prefs = [[YAPreferences alloc] init];
    NSString* pathName = [NSString stringWithFormat:@"%@/%@/%@.%@", prefs.resourceDir , SHADER_DIR, filename, filetype];

    [YALog debug:TAG message:[NSString stringWithFormat:@"Try loading: %@", pathName]];

    NSString* sourceString = [NSString stringWithContentsOfFile:pathName  encoding:NSASCIIStringEncoding error:nil];
   
    const GLchar *source = (GLchar*)[sourceString cStringUsingEncoding:NSASCIIStringEncoding];
     
    if(nil == source) {
        if (shaderType  == GL_GEOMETRY_SHADER) {
            [YALog debug:TAG message:@"Geometry Shader not found."];
            return 0; // optional
        } else
            [NSException raise:shaderNotFoundException format:@"Could not create shader: %@", filename];

    }

    shader = glCreateShader(shaderType);
    [YALog isGLStateOk:TAG message:@"createShader / glCreateShader"];

    glShaderSource(shader, 1, &source, NULL);
    [YALog isGLStateOk:TAG message:@"createShader / glShaderSource"];
    
    return shader;
}

- (bool) compileWithDebug: (GLuint) shader
{
    GLint status;
    glCompileShader(shader);
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if(status == GL_FALSE) {
        GLint logSize;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logSize);
        
        GLchar *logString = malloc((size_t)logSize); 
        glGetShaderInfoLog(shader, logSize, NULL, logString);
        
        [YALog debug:TAG message:[NSString stringWithFormat:@"GLSL compiler error: %s", logString]];
        
        free(logString);
        return false;
    } else {
        [YALog debug:TAG message: @"Shader compiled" ];
        return true;
    }
}  
    
    
- (bool) linkWithDebug
{
    [YALog debug:TAG message:@"linkWithDebug"];
    programId = glCreateProgram();
    
    glAttachShader(programId, vertexShaderId);
    glAttachShader(programId, fragmentShaderId);

    if (geometryShaderId > 0) 
        glAttachShader(programId, geometryShaderId);

    
    glLinkProgram(programId);
    
    GLint status;
    glGetProgramiv(programId, GL_LINK_STATUS, &status);
    
    if(status == GL_FALSE) {
        GLint logSize;
        glGetProgramiv(programId, GL_INFO_LOG_LENGTH, &logSize);
 
        GLchar *logString = malloc((size_t)logSize);
        glGetProgramInfoLog(programId, logSize, NULL, logString);
        [YALog debug:TAG message:[NSString stringWithFormat:@"GLSL linker error: %s", logString]];
        
        free(logString);
        
        return false;
        
    }
    
    [YALog debug:TAG message: [NSString stringWithFormat:@"GLSL program [%d] linked.", programId] ];
    return true;
}

- (void)destroy
{
    [YALog isGLStateOk:TAG message:@"destroy / init"];
    glDetachShader(programId, vertexShaderId);
    glDetachShader(programId, fragmentShaderId);
    
    if(geometryShaderId > 0)
        glDetachShader(programId, geometryShaderId);

    glDeleteProgram(programId);
    [YALog isGLStateOk:TAG message:@"destroy / could not be destroyed."];
}

- (void) dealloc
{
    [self destroy];
}


- (void) activate {
    
    if(ACTIVE_SHADER != self) {
        glUseProgram(programId);
        ACTIVE_SHADER = self;
    } 
    
    [YALog isGLStateOk:TAG message:@"Activate FAILED"];
}

- (GLuint) programId
{
    return programId;
}


- (NSString*) requiredLight
{
    return lightType;
}

@end
