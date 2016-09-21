//
//  YASkyMap.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 23.11.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES
#define GLCOREARB_PROTOTYPES
#import <GL/glcorearb.h>

#import "YAPreferences.h"
#import "YAShader.h"
#import "YALog.h"
#import "YASkyMap.h"

#import <SOIL.h>

static const NSString* TEXTURE_DIRECTORY_NAME = @"compiled";
static const NSString* TEXTURE_DIRECTORY_SOURCE_NAME = @"texture";


@interface YASkyMap()
- (bool)loadImage: (NSString*) imageName target: (GLuint) target;

@end

@implementation YASkyMap

static const NSString *TAG = @"YASkyMap";



- (id) initResource: (NSString*) skyMapName shader: (YAShader*) shader;
{
    self = [super init];
    if (self) {
        orientations = [NSArray arrayWithObjects:@"Back", @"Bottom", @"Front", @"Left", @"Right", @"Top" , nil]; 
        name = skyMapName;
        _shader = shader;
    }
    
    return self; 
}

- (bool)load
{
    // no specials at the moment
    glActiveTexture(GL_TEXTURE2);
    
    glGenTextures(3, texId);

    glBindTexture(GL_TEXTURE_CUBE_MAP, texId[0]);

    GLuint targets[] = {
        GL_TEXTURE_CUBE_MAP_NEGATIVE_Z,
        GL_TEXTURE_CUBE_MAP_NEGATIVE_Y,
        GL_TEXTURE_CUBE_MAP_POSITIVE_Z,
        GL_TEXTURE_CUBE_MAP_NEGATIVE_X,
        GL_TEXTURE_CUBE_MAP_POSITIVE_X,
        GL_TEXTURE_CUBE_MAP_POSITIVE_Y,
    };
    
    for (int i = 0; i < 6; i++) {
        NSString *texName = [NSString stringWithFormat:@"%@%@", name, [orientations objectAtIndex: i] ];
        [self loadImage:texName target: targets[i]];
    }
    
    glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);

    [_shader activate];
    const GLuint loc = _shader.locTextureMap;
    if(loc != -1) {
        glUniform1i(loc, 0);
    }
    
    
    // diffuse map
      glActiveTexture(GL_TEXTURE4);
      glBindTexture(GL_TEXTURE_CUBE_MAP, texId[1]);
    
    for (int i = 0; i < 6; i++) {
        NSString *texName = [NSString stringWithFormat:@"D_%@%@", name, [orientations objectAtIndex: i] ];
        [self loadImage:texName target: targets[i]];
    }
    
    glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
    
    // diffuse map
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_CUBE_MAP, texId[2]);
    
    for (int i = 0; i < 6; i++) {
        NSString *texName = [NSString stringWithFormat:@"S_%@%@", name, [orientations objectAtIndex: i] ];
        [self loadImage:texName target: targets[i]];
    }
    
    glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
    
    return [YALog isGLStateOk:TAG message:@"Could not load skymap."];
}


/** 
 Generate a  cube because i dont have default primitives.
*/ 
- (bool) setupBuffer 
{
    [YALog debug:TAG message:@"setupBuffer" ];
    [YALog isGLStateOk:TAG message:@"setupBuffer / init"];
    
    glGenVertexArrays(1, &vaoId);
    glBindVertexArray(vaoId);

    GLfloat vertices[] = {    
    -1.0, -1.0f, -1.0f,
    -1.0f, -1.0f, 1.0f,
    -1.0, -1.0f, -1.0f,
    1.0f,-1.0f, -1.0f,
    1.0f, 1.0f, -1.0f,
    1.0f,-1.0f, -1.0f,
    1.0f, -1.0f, 1.0f,
    -1.0f, -1.0f, 1.0f,
    1.0f, -1.0f, 1.0f,
    1.0f, 1.0f, 1.0f,
    1.0f, 1.0f, -1.0f,
    -1.0f, 1.0f, -1.0f, 
    -1.0, -1.0f, -1.0f,
    -1.0f, 1.0f, -1.0f,
    -1.0f, -1.0f, 1.0f,
    -1.0f, 1.0f, -1.0f, 
    -1.0, 1.0f, 1.0f,
    1.0f, 1.0f, 1.0f,
    -1.0f, -1.0f, 1.0f
    };

    
    glGenBuffers(1, &vboId);
    glBindBuffer(GL_ARRAY_BUFFER, vboId);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    GLuint attribVertexLocation = _shader.locPosition;
    if(attribVertexLocation != - 1) {
        glVertexAttribPointer(attribVertexLocation, 3, GL_FLOAT, GL_FALSE, 0, 0);
        glEnableVertexAttribArray(attribVertexLocation);
        [YALog debug:TAG message:@"attribVertexLocation assigned" ];
    }   
    
    glBindVertexArray(0);
      return [YALog isGLStateOk:TAG message:@"setupBuffer / Could not create buffer."];
}


/***
 texture injection for foreign objects
 ***/
- (void) bind: (YAShader*) shader
{
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_CUBE_MAP, texId[0]);
    GLuint loc = shader.locSkyMap;
    if(loc != -1) {
        glUniform1i(loc, 2);
    }
    
    // bind diffusemap
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_CUBE_MAP, texId[1]);
    loc = shader.locDiffuseMap;
    if(loc != -1) {
        glUniform1i(loc, 4);
    }

    // bind diffusemap
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_CUBE_MAP, texId[2]);
    loc = shader.locSpecularMap;
    if(loc != -1) {
        glUniform1i(loc, 5);
    }
}

- (void) draw
{
    [YALog isGLStateOk:TAG message:@"bind / init FAILED"];
    [_shader activate];
    glBindVertexArray(vaoId);

    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_CUBE_MAP, texId[0]);

    if(_shader.locSkyMap != -1)
        glUniform1i(_shader.locSkyMap, 2);
       
    glDrawArrays(GL_TRIANGLE_STRIP , 0, 19);
    glBindVertexArray(0);
    
    [YALog isGLStateOk:TAG message:@"Could not draw skymap."];
}

- (void) dealloc
{
    [self destroy];
}

- (void) destroy
{
    [YALog debug:TAG message:@"destroy"];
    glBindVertexArray(vaoId);
    glDisableVertexAttribArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glDeleteBuffers(1, &vboId);
    glDeleteTextures(2, &texId[0]);
    glBindVertexArray(0);
    glDeleteVertexArrays(1, &vaoId);
    [YALog isGLStateOk:TAG message:@"destroy / glDeleteTExtures FAILED"];
}

/***
 * loadImage: load image from resources
 ***/
- (bool)loadImage: (NSString*) imageName target: (GLuint) target
{
    [YALog debug:TAG message: [NSString stringWithFormat:@"Load image: %@", imageName]];
    [YALog isGLStateOk:TAG message:@"load / init FAILED"];

    YAPreferences* prefs = [[YAPreferences alloc] init];
    NSString* imageURL = [NSString stringWithFormat:@"%@/%@/skymap/%@.%@", prefs.resourceDir ,TEXTURE_DIRECTORY_SOURCE_NAME, imageName, @"png"];
    [YALog debug:TAG message:[NSString stringWithFormat:@"imageURL %@.", imageURL]];

    int width, height, channels;
    unsigned char* imageData = SOIL_load_image( [imageURL UTF8String], &width, &height, &channels, SOIL_LOAD_RGBA );
    [self flipTexture: imageData Width:width Height:height Channels: channels];

    BOOL GlOk = true;
    glTexImage2D(target, 0, GL_COMPRESSED_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    GlOk = [YALog isGLStateOk:TAG message:[NSString stringWithFormat:@"@Could not specify texture %d", target]];
    if(!GlOk)
        glTexImage2D(target, 0, GL_RGBA , width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    [YALog isGLStateOk:TAG message:[NSString stringWithFormat:@"@Could not specify texture %d", texId[0]]];
    
    SOIL_free_image_data(imageData);
    return [YALog isGLStateOk:TAG message:@"Could not load image."];
}

- (void) flipTexture: (unsigned char*) img  Width: (int) width Height: (int) height Channels: (int) channels
{
    int i, j;
    for( j = 0; j*2 < height; ++j )
    {
        int index1 = j * width * channels;
        int index2 = (height - 1 - j) * width * channels;
        for( i = width * channels; i > 0; --i )
        {
            unsigned char temp = img[index1];
            img[index1] = img[index2];
            img[index2] = temp;
            ++index1;
            ++index2;
        }
    }
}

@end



