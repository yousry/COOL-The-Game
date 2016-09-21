//
//  YATexture.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 21.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#define GLFW_INCLUDE_NONE
#import <GL/glcorearb.h>
#import <GLFW/glfw3.h>

#import "YAHeightMap.h"
#import <Foundation/Foundation.h>

@interface YATexture : NSObject {
@protected
    NSString* _imageName;
    GLuint textureId;

    GLuint pixelWidth;
    GLuint pixelHeight;

}

@property (readwrite) BOOL createCompressedTextures;

@property(readonly) GLuint pixelWidth;
@property(readonly) GLuint pixelHeight;

@property(readonly) NSString* name;

- (id) initWithName: (NSString*) imageName;
- (id) initWithFilename: (NSString*) fileName;

- (bool) generate: (id<YAHeightMap>) heightmap;
- (bool) update: (id<YAHeightMap>) heightmap;

- (bool) load;
- (bool) loadMipMap;

- (void) bind: (GLenum) position;
- (void) destroy;

@end
