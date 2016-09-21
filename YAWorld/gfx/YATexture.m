//
//  YATexture.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 21.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES
#define GLCOREARB_PROTOTYPES
#import <GL/glcorearb.h>

#import "YAPreferences.h"
#import "fuTypes.h"
#import "YALog.h"
#import "YATexture.h"

#import <SOIL.h>

#define SEA_LEVEL (-1.0f)

@implementation YATexture

@synthesize pixelWidth, pixelHeight;
@synthesize name = _imageName;
@synthesize createCompressedTextures;

static const NSString* TAG = @"YATexture";

static const NSString* TEXTURE_DIRECTORY_NAME = @"compiled";
static const NSString* TEXTURE_DIRECTORY_SOURCE_NAME = @"texture";

- (id)init
{
    self = [super init];
    if (self) {
        _imageName = @"FirstCGTExture";
        createCompressedTextures = YES; //[YALog isDebug];
    }

    return self;
}

- (id) initWithFilename: (NSString*) fileName
{
    [YALog debug:TAG message:@"initWithName"];

    self = [super init];
    if (self) {
        pixelWidth  = 0;
        pixelHeight = 0;
        _imageName =[fileName substringToIndex:fileName.length - 4];
        createCompressedTextures = YES; //[YALog isDebug];
    }
    return self;
}

- (id) initWithName: (NSString*) imageName
{
    [YALog debug:TAG message:@"initWithName"];

    self = [super init];
    if (self) {
        pixelWidth  = 0;
        pixelHeight = 0;
        _imageName = imageName;
        createCompressedTextures = YES; //[YALog isDebug];
    }

    return self;
}


- (bool) update: (id<YAHeightMap>) heightmap
{
    [YALog debug:TAG message:@"update"];
    [YALog isGLStateOk:TAG message:@"load / init FAILED"];

    glBindTexture(GL_TEXTURE_2D, textureId);

    pixelWidth =  heightmap.terrainDimension;
    pixelHeight = heightmap.terrainDimension;
    [YALog debug:TAG message:[NSString stringWithFormat:@"Heightmap %@ dimensions: %d, %d", _imageName, pixelWidth, pixelHeight ]];

    Byte *imageData = calloc(pixelWidth * 4 * 4, pixelHeight);

    for (int z = 0; z < pixelHeight; z++)
        for (int x = 0; x < pixelWidth; x++) {
            float height = [heightmap heightAt:x :z];

            if(height < SEA_LEVEL)
                height = SEA_LEVEL;

            int channel = height < 0 ? 1 : 2;
            imageData[(x * 4) + channel + (pixelWidth * 4) * z] = (unsigned char) (abs((int)height));
        }

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA , pixelWidth, pixelHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, imageData);
    [YALog isGLStateOk:TAG message:[NSString stringWithFormat:@"@Could not specify texture %d", textureId]];

    free(imageData);
    return [YALog isGLStateOk:TAG message:@"Could not create image."];
}


- (bool) generate: (id<YAHeightMap>) heightmap
{
    [YALog debug:TAG message:@"generate"];
    [YALog isGLStateOk:TAG message:@"load / init FAILED"];

    pixelWidth =  heightmap.terrainDimension;
    pixelHeight = heightmap.terrainDimension;
    [YALog debug:TAG message:[NSString stringWithFormat:@"Heightmap %@ dimensions: %d, %d", _imageName, pixelWidth, pixelHeight ]];

    Byte *imageData = calloc(pixelWidth * 4 * 4, pixelHeight);

    glGenTextures(1, &textureId);
    [YALog isGLStateOk:TAG message:@"Could not generate textureId."];
    glBindTexture(GL_TEXTURE_2D, textureId);
    [YALog isGLStateOk:TAG message:@"Could not bind texture."];


    for (int z = 0; z < pixelHeight; z++)
        for (int x = 0; x < pixelWidth; x++) {

            float height = [heightmap heightAt:x :z];

            if(height < SEA_LEVEL)
                height = SEA_LEVEL;

            int channel = height < 0 ? 1 : 2;
            imageData[(x * 4) + channel + (pixelWidth * 4) * z] = (unsigned char) (abs((int)height));

        }

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA , pixelWidth, pixelHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, imageData);
    [YALog isGLStateOk:TAG message:[NSString stringWithFormat:@"@Could not specify texture %d", textureId]];

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

    free(imageData);
    return [YALog isGLStateOk:TAG message:@"Could not create image."];
}

- (bool) loadMipMap
{
    [YALog debug:TAG message:@"loadMipMap"];
    [YALog isGLStateOk:TAG message:@"load / init FAILED"];

    if(createCompressedTextures) {
        // Create TempDir if it doesn't exist

        NSData* cachedImage = [self loadCachedTexture];

        if(cachedImage) {
            GLuint* glInfo = (GLuint*) [cachedImage bytes];
            pixelWidth = glInfo[0];
            pixelHeight = glInfo[1];
            GLuint compressedFormat = glInfo[2];
            GLuint size = glInfo[3];

            int rangeStart = sizeof(GLuint) * 4;
            NSUInteger length = [cachedImage length];

            NSRange imageRange = NSMakeRange (rangeStart, length - rangeStart);

            NSData* imageDataData = [cachedImage subdataWithRange:imageRange];
            GLuint* imageData = (GLuint*)[imageDataData bytes];

            // Create texture from compressed Data
            glGenTextures(1, &textureId);
            [YALog isGLStateOk:TAG message:@"Could not generate textureId."];
            glBindTexture(GL_TEXTURE_2D, textureId);
            [YALog isGLStateOk:TAG message:@"Could not bind texture."];

            glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL, 0);
            glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, 4);

            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);

            glCompressedTexImage2D(GL_TEXTURE_2D, 0, compressedFormat, pixelWidth, pixelHeight, 0, size, imageData);
            glGenerateMipmap(GL_TEXTURE_2D);

            return [YALog isGLStateOk:TAG message:[NSString stringWithFormat:@"Could not load image: %@ .", _imageName]];
        }
    }

    YAPreferences* prefs = [[YAPreferences alloc] init];

    NSString* imageURL = [NSString stringWithFormat:@"%@/%@/%@.%@", prefs.resourceDir ,TEXTURE_DIRECTORY_SOURCE_NAME, _imageName, @"png"];
    [YALog debug:TAG message:[NSString stringWithFormat:@"imageURL %@.", imageURL]];


    int width, height, channels;
    unsigned char* imageData = SOIL_load_image( [imageURL UTF8String], &width, &height, &channels, SOIL_LOAD_RGBA );

    pixelWidth = (GLuint) width;
    pixelHeight =(GLuint) height;

    [YALog debug:TAG message:[NSString stringWithFormat:@"image %@ dimensions: %d, %d", _imageName, pixelWidth, pixelHeight ]];

    glGenTextures(1, &textureId);
    [YALog isGLStateOk:TAG message:@"Could not generate textureId."];
    glBindTexture(GL_TEXTURE_2D, textureId);
    [YALog isGLStateOk:TAG message:@"Could not bind texture."];

    glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL, 0);
    glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, 4);

    BOOL GlOk = true;
    glHint(GL_TEXTURE_COMPRESSION_HINT, GL_NICEST);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGBA , pixelWidth, pixelHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    GlOk = [YALog isGLStateOk:TAG message:[NSString stringWithFormat:@"@Could not specify texture %d", textureId]];
    if(!GlOk) {
        createCompressedTextures = false;
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA , pixelWidth, pixelHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, imageData);
    }

    [YALog isGLStateOk:TAG message:[NSString stringWithFormat:@"@Could not specify texture %d", textureId]];

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);

    glGenerateMipmap(GL_TEXTURE_2D);

    free(imageData);
    if(![YALog isGLStateOk:TAG message:[NSString stringWithFormat:@"Could not load image: %@ .", _imageName]])
        return false;

    if(createCompressedTextures) {
        GLint textureSize;
        glGetTexLevelParameteriv(GL_TEXTURE_2D, 0,
                                 GL_TEXTURE_COMPRESSED_IMAGE_SIZE,
                                 &textureSize);
        [YALog isGLStateOk:TAG message:@"get texture size."];

        if ((textureSize > 0) && (textureSize < 100000000)) {
            GLubyte *compressedData = malloc(sizeof(GLubyte) * textureSize);
            glGetCompressedTexImage(GL_TEXTURE_2D, 0, compressedData);
            [YALog isGLStateOk:TAG message:@"Load texture into cpu."];

            GLint internalFormat;
            glGetTexLevelParameteriv(GL_TEXTURE_2D , 0, GL_TEXTURE_INTERNAL_FORMAT, &internalFormat);
            [YALog isGLStateOk:TAG message:@"Read Internal Format."];

            [self saveTextureWithSize:textureSize
                       compressedData:compressedData
                                width:pixelWidth
                               height:pixelHeight
                       internalFormat:internalFormat];

            SOIL_free_image_data(compressedData);
        }

    }

    return true;
}

- (bool)load
{
    [YALog debug:TAG message:@"load"];
    [YALog isGLStateOk:TAG message:@"load / init FAILED"];

    if(createCompressedTextures) {

        NSData* cachedImage = [self loadCachedTexture];

        if(cachedImage) {
            GLuint* glInfo = (GLuint*) [cachedImage bytes];
            pixelWidth = glInfo[0];
            pixelHeight = glInfo[1];
            GLuint compressedFormat = glInfo[2];
            GLuint size = glInfo[3];

            int rangeStart = sizeof(GLuint) * 4;
            NSUInteger length = [cachedImage length];

            NSRange imageRange = NSMakeRange (rangeStart, length - rangeStart);

            NSData* imageDataData = [cachedImage subdataWithRange:imageRange];
            GLuint* imageData = (GLuint*)[imageDataData bytes];

            // Create texture from compressed Data
            glGenTextures(1, &textureId);
            [YALog isGLStateOk:TAG message:@"Could not generate textureId."];
            glBindTexture(GL_TEXTURE_2D, textureId);
            [YALog isGLStateOk:TAG message:@"Could not bind texture."];

            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            [YALog isGLStateOk:TAG message:@"Could not scale texture."];

            glCompressedTexImage2D(GL_TEXTURE_2D, 0, compressedFormat, pixelWidth, pixelHeight, 0, size, imageData);
            return [YALog isGLStateOk:TAG message:[NSString stringWithFormat:@"Could not load image: %@ .", _imageName]];
        }

    }

    YAPreferences* prefs = [[YAPreferences alloc] init];
    NSString* imageURL = [NSString stringWithFormat:@"%@/%@/%@.%@", prefs.resourceDir,TEXTURE_DIRECTORY_SOURCE_NAME, _imageName, @"png"];
    [YALog debug:TAG message:[NSString stringWithFormat:@"imageURL %@.", imageURL]];

    if(![[NSFileManager defaultManager] fileExistsAtPath: imageURL]) {
        [YALog debug:TAG message:@"File does not exist."];
        return false;
    }

    int width, height, channels;
    unsigned char* imageData = SOIL_load_image( [imageURL UTF8String], &width, &height, &channels, SOIL_LOAD_RGBA);
    [self flipTexture: imageData Width:width Height:height Channels: channels];

    pixelWidth = (GLuint) width;
    pixelHeight =(GLuint) height;
    [YALog debug:TAG message:[NSString stringWithFormat:@"image %@ dimensions: %d, %d [%d]", _imageName, pixelWidth, pixelHeight, channels]];

    glGenTextures(1, &textureId);

    [YALog isGLStateOk:TAG message:@"Could not generate textureId."];
    glBindTexture(GL_TEXTURE_2D, textureId);
    [YALog isGLStateOk:TAG message:@"Could not bind texture."];

    BOOL GlOk = true;
    glHint(GL_TEXTURE_COMPRESSION_HINT, GL_NICEST);


    glTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGBA , pixelWidth, pixelHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    GlOk = [YALog isGLStateOk:TAG message:[NSString stringWithFormat:@"@Could not specify texture %d", textureId]];
    if(!GlOk) {
        createCompressedTextures = false;
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA , pixelWidth, pixelHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, imageData);
    }

    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    SOIL_free_image_data(imageData);

    if(![YALog isGLStateOk:TAG message:[NSString stringWithFormat:@"Could not load image: %@ .", _imageName]])
        return false;

    if(createCompressedTextures) {
        GLint textureSize;
        glGetTexLevelParameteriv(GL_TEXTURE_2D, 0,
                                 GL_TEXTURE_COMPRESSED_IMAGE_SIZE,
                                 &textureSize);
        if(![YALog isGLStateOk:TAG message:@"Get texture size failed."])
            return true; // stop texture compression here

        if ((textureSize > 0) && (textureSize < 100000000)) {
            GLubyte *compressedData = malloc(sizeof(GLubyte) * textureSize);
            glGetCompressedTexImage(GL_TEXTURE_2D, 0, compressedData);
            [YALog isGLStateOk:TAG message:@"Load texture into cpu."];


            GLint internalFormat;
            glGetTexLevelParameteriv(GL_TEXTURE_2D , 0, GL_TEXTURE_INTERNAL_FORMAT, &internalFormat);
            [YALog isGLStateOk:TAG message:@"Read Internal Format."];

            [self saveTextureWithSize:textureSize
                       compressedData:compressedData
                                width:pixelWidth
                               height:pixelHeight
                       internalFormat:internalFormat];

            free(compressedData);
        }

    }

    return true;
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

- (void) bind: (GLenum) position
{
    [YALog isGLStateOk:TAG message:@"bind / init FAILED"];
    glActiveTexture(position);
    glBindTexture(GL_TEXTURE_2D, textureId);
    [YALog isGLStateOk:TAG message:@"Could not bind image."];
}

- (void) dealloc
{
    [self destroy];
}

- (void)destroy
{
    [YALog isGLStateOk:TAG message:@"destroy / ENTRY"];
    glDeleteTextures(1, &textureId);
    [YALog isGLStateOk:TAG message:@"destroy / glDeleteTExtures FAILED"];

}

#pragma mark -
#pragma mark Private methods for caching compressed textures
#pragma mark -

-(void) saveTextureWithSize: (int) compressedSize compressedData: (GLubyte*) compressedData width: (int) width height: (int) height internalFormat: (int) internalFormat
{

    YAPreferences* prefs = [[YAPreferences alloc] init];

    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSData* imageData = [NSData dataWithBytes:compressedData length:compressedSize];

    GLuint info[4];
    info[0] = width;
    info[1] = height;
    info[2] = internalFormat;
    info[3] = compressedSize;

    NSMutableData* saveData = [NSMutableData dataWithBytes:info length: sizeof(GLuint) * 4];
    [saveData appendData:imageData];

    NSString* textureDirectory = [NSString stringWithFormat:@"%@/%@", prefs.resourceDir, TEXTURE_DIRECTORY_NAME];
    NSString *fullPath = [textureDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.data", _imageName]];

    [fileManager createFileAtPath:fullPath contents:saveData attributes:nil];
}

-(NSData*) loadCachedTexture
{
    YAPreferences* prefs = [[YAPreferences alloc] init];
    NSString* textureDirectory = [NSString stringWithFormat:@"%@/%@", prefs.resourceDir, TEXTURE_DIRECTORY_NAME];
    NSString *fullPath = [textureDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.data", _imageName]];
    return [NSData dataWithContentsOfFile:fullPath];
}

@end
