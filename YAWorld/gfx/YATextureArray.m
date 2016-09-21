//
//  YATextureArray.m
//  YAWorld
//
//  Created by Yousry Abdallah on 31.07.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES
#define GLCOREARB_PROTOTYPES
#import <GL/glcorearb.h>

#import <SOIL.h>

#import "YAPreferences.h"
#import "YALog.h"
#import "YATexture.h"
#import "YATextureArray.h"

@implementation YATextureArray

static const NSString* TAG = @"YATextureArray";
static const NSString* TEXTURE_DIRECTORY_NAME = @"compiled";
static const NSString* TEXTURE_DIRECTORY_SOURCE_NAME = @"texture";


- (id) initWithFilenames: (NSArray*) fileNames
{
    self = [super init];
    
    if(self) {
        pixelWidth  = 128;
        pixelHeight = 128;
        
        _imageNames = [[NSMutableArray alloc] init];
        
        for(NSString* fileName in fileNames)
            [_imageNames addObject:[fileName substringToIndex:fileName.length - 4]];
    }
    
    return self;
}



- (bool)load
{
    [YALog debug:TAG message:@"load"];
    [YALog isGLStateOk:TAG message:@"load / init FAILED"];

    glGenTextures(1, &textureId);
    [YALog isGLStateOk:TAG message:@"Could not generate textureId."];
    glBindTexture(GL_TEXTURE_2D_ARRAY, textureId);
    [YALog isGLStateOk:TAG message:@"Could not bind texture."];

    glTexParameteri (GL_TEXTURE_2D_ARRAY, GL_TEXTURE_BASE_LEVEL, 0);
    glTexParameteri (GL_TEXTURE_2D_ARRAY, GL_TEXTURE_MAX_LEVEL, 4);
    
    glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    
    BOOL GlOk = true;
    glTexImage3D(GL_TEXTURE_2D_ARRAY, 0, GL_COMPRESSED_RGBA , pixelWidth, pixelHeight, (GLsizei)[_imageNames count], 0, GL_BGRA, GL_UNSIGNED_BYTE, NULL);
    GlOk = [YALog isGLStateOk:TAG message:[NSString stringWithFormat:@"@Could not specify texture %d", textureId]];
    if(!GlOk)
        glTexImage3D(GL_TEXTURE_2D_ARRAY, 0, GL_RGBA , pixelWidth, pixelHeight, (GLsizei)[_imageNames count], 0, GL_BGRA, GL_UNSIGNED_BYTE, NULL);
    
    [YALog isGLStateOk:TAG message:[NSString stringWithFormat:@"@Could not specify texture %d", textureId]];
    
    int index = 0;
    for(_imageName in _imageNames) {

    YAPreferences* prefs = [[YAPreferences alloc] init];    
    NSString* imageURL = [NSString stringWithFormat:@"%@/%@/%@.%@", prefs.resourceDir, TEXTURE_DIRECTORY_SOURCE_NAME, _imageName, @"png"];
    [YALog debug:TAG message:[NSString stringWithFormat:@"imageURL %@.", imageURL]];
        
    int width, height, channels;
    unsigned char* imageData = SOIL_load_image( [imageURL UTF8String], &width, &height, &channels, SOIL_LOAD_RGBA);
    [self flipTexture: imageData Width:width Height:height Channels: channels];



    [YALog debug:TAG message:[NSString stringWithFormat:@"image %@ dimensions: %d, %d", _imageName, pixelWidth, pixelHeight ]];

        
        // overwerite defaults if bitmap size differs
        if(pixelWidth != width  || pixelHeight !=  height) {
            pixelWidth =  width;
            pixelHeight = height;
            glTexImage3D(GL_TEXTURE_2D_ARRAY, 0, GL_RGBA , pixelWidth, pixelHeight, (GLsizei)[_imageNames count], 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
            [YALog isGLStateOk:TAG message:[NSString stringWithFormat:@"@Could not specify texture %d", textureId]];
        }
        
        [YALog debug:TAG message:[NSString stringWithFormat:@"image %@ dimensions: %d, %d", _imageName, pixelWidth, pixelHeight ]];
        
        glTexSubImage3D(GL_TEXTURE_2D_ARRAY, 0, 0, 0, index++, pixelWidth, pixelHeight, 1, GL_RGBA, GL_UNSIGNED_BYTE, imageData);

        SOIL_free_image_data(imageData);
        [YALog isGLStateOk:TAG message:@"Could not load image."];
    }
    
    glGenerateMipmap(GL_TEXTURE_2D_ARRAY);
    return [YALog isGLStateOk:TAG message:@"Could not create mipmap"];
}

- (void) bind: (GLenum) position
{
    [YALog isGLStateOk:TAG message:@"bind / init FAILED"];
    glActiveTexture(position);
    glBindTexture(GL_TEXTURE_2D_ARRAY, textureId);
    [YALog isGLStateOk:TAG message:@"Could not bind image."];
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
