//
//  YA3DFileFormat.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 01.10.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import "YAPreferences.h"
#import "fuTypes.h"
#import "NSData+RangeAdditions.h"
#import "YALog.h"
#import "YA3DFileFormat.h"

@interface YA3DFileFormat() 
- (NSRange)findLabel: (const NSString*) label startFrom: (unsigned long) cursor;

- (NSString*)readValueString: (unsigned long) cursor;
- (unsigned int)readValueNumber: (unsigned long) cursor;

- (void) printVBO;
- (void) printIBO;

@end

@implementation YA3DFileFormat

@synthesize vboData;
@synthesize iboData;
@synthesize modelFormat;
@synthesize textureName;
@synthesize normalName;

static const NSString* HEADER_STRING = @"YA3D";
static const NSString* VERSION_STRING = @"VERSION:";
static const NSString* TEXTURE_STRING = @"TEXTURE:";
static const NSString* NORMAL_STRING = @"NORMAL:";

static const NSString* FORMAT_STRING = @"FORMAT:";
static const NSString* DATA_STRING = @"DATA:";

static const NSString* TAG = @"YA3DFileFormat";
static const NSString* MODEL_FILETYPE = @"Y3D";
static const NSString* MODEL_DIRECTORY_NAME = @"model";


- (id) initWithResource: (NSString*) filename
{
    self = [super init];
    if (self) {
        _filename = filename;
        modelData = nil;
        textureName = nil;
        normalName = nil;
        vboElemLength = 8;
    }
    
    return self;
}

- (bool) load
{
    YAPreferences* prefs = [[YAPreferences alloc] init];
    NSString* pathName = [NSString stringWithFormat:@"%@/%@/%@.%@", prefs.resourceDir, MODEL_DIRECTORY_NAME, _filename, MODEL_FILETYPE];
    [YALog debug:TAG message:[NSString stringWithFormat:@"Try loading: %@", pathName]];

    modelData = [NSData dataWithContentsOfFile:pathName];
    [YALog debug:TAG message:[NSString stringWithFormat:@"Model Data Length: %ld", modelData.length ]];
    
    // everything ok
    return true;
}

- (bool)setup
{
    NSRange labelPos = [self findLabel: HEADER_STRING startFrom: 0];
    if(labelPos.location == NSNotFound) {
        [YALog debug:TAG message:[NSString stringWithFormat:@"Header YA3D not found." ]];
        return false;
    }
    
    
    labelPos = [self findLabel: VERSION_STRING startFrom: 0];
    if(labelPos.location == NSNotFound) {
        [YALog debug:TAG message:[NSString stringWithFormat:@"Version info not Found" ]];
    } else {
        const unsigned int versionNumber = [self readValueNumber:labelPos.location + labelPos.length];
        [YALog debug:TAG message:[NSString stringWithFormat:@"File Version: %d", versionNumber]];
        
    }
    
    
    labelPos = [self findLabel: TEXTURE_STRING startFrom: 0];
    if(labelPos.location == NSNotFound) {
        [YALog debug:TAG message:[NSString stringWithFormat:@"Model texture not found." ]];
    } else {
        textureName = [self readValueString: labelPos.location + labelPos.length];
        if([textureName isEqualToString: @"UNSET"])
            [YALog debug:TAG message:[NSString stringWithFormat:@"Model without Texture"]];
        else        
            [YALog debug:TAG message:[NSString stringWithFormat:@"Model contains Texture: %@", textureName]];
    }

    labelPos = [self findLabel: NORMAL_STRING startFrom: 0];
    if(labelPos.location == NSNotFound) {
        [YALog debug:TAG message:[NSString stringWithFormat:@"Model normal map not found." ]];
    } else {
        normalName = [self readValueString: labelPos.location + labelPos.length];
        if([normalName isEqualToString: @"UNSET"])
            [YALog debug:TAG message:[NSString stringWithFormat:@"Model without normal  map"]];
        else        
            [YALog debug:TAG message:[NSString stringWithFormat:@"Model contains Normal map: %@", normalName]];
    }
    
    
    labelPos = [self findLabel: FORMAT_STRING startFrom: 0];
    if(labelPos.location == NSNotFound) {
        [YALog debug:TAG message:@"Format Definition not found."];
        return false;
    } 
    
    modelFormat = [self readValueString: labelPos.location + labelPos.length];
    [YALog debug:TAG message:[NSString stringWithFormat:@"Model Format: %@", modelFormat]];
    

    if([modelFormat isEqualToString:@"vcnI"]) 
        vboElemLength = 9;
    else if ([modelFormat isEqualToString:@"vtnbI"])
        vboElemLength = 11;
    
    labelPos = [self findLabel: DATA_STRING startFrom: 0];
    if(labelPos.location == NSNotFound) {
        [YALog debug:TAG message:@"VBO DATA not found"];
        return false;
    } 

    unsigned int dataLength = [self readValueNumber:labelPos.location + labelPos.length];
    [YALog debug:TAG message:[NSString stringWithFormat:@"VBO Block with length: %d", dataLength]];
    
    NSRange vboRange = {labelPos.location + labelPos.length + sizeof(unsigned int), dataLength * sizeof(float)};
    vboData = [modelData subdataWithRange:vboRange];

    labelPos = [self findLabel: DATA_STRING startFrom: (vboRange.location + vboRange.length) - vboElemLength * sizeof(float)];
    if(labelPos.location == NSNotFound) {
        [YALog debug:TAG message:@"VBI DATA not found"];
        return false;
    } 
    
    dataLength = [self readValueNumber:labelPos.location + labelPos.length];
    
    NSRange iboRange = {labelPos.location + labelPos.length + sizeof(unsigned int), dataLength * sizeof(unsigned int)};
    iboData = [modelData subdataWithRange:iboRange];
    
    [YALog debug:TAG message:[NSString stringWithFormat:@"vboData: %ld", vboData.length]];
    [YALog debug:TAG message:[NSString stringWithFormat:@"iboData: %ld", iboData.length]];

    return true;
}


- (void) printVBO
{
    for(int cursor = 0; cursor < vboData.length; cursor += vboElemLength*4) {
        float x = 0, y = 0, z = 0, u = 0, v = 0, nx = 0, ny = 0, nz = 0, r = 0, g = 0, b = 0;
        [vboData getBytes:&x range:(NSRange){cursor,     4}];
        [vboData getBytes:&y range:(NSRange){cursor + 4, 4}];
        [vboData getBytes:&z range:(NSRange){cursor + 8, 4}];
        
        
        if(vboElemLength == 8) {
            [vboData getBytes:&u range:(NSRange){cursor + 12, 4}];
            [vboData getBytes:&v range:(NSRange){cursor + 16, 4}];
            [vboData getBytes:&nx range:(NSRange){cursor + 20, 4}];
            [vboData getBytes:&ny range:(NSRange){cursor + 24, 4}];
            [vboData getBytes:&nz range:(NSRange){cursor + 28, 4}];
            // NSLog(@"VBO: x:%f y:%f z:%f u:%f v:%f nx:%f ny:%f nz:%f", x, y, z, u, v, nx, ny, nz);
        } else {
            [vboData getBytes:&r range:(NSRange){cursor + 12, 4}];
            [vboData getBytes:&g range:(NSRange){cursor + 16, 4}];
            [vboData getBytes:&b range:(NSRange){cursor + 20, 4}];
            [vboData getBytes:&nx range:(NSRange){cursor + 24, 4}];
            [vboData getBytes:&ny range:(NSRange){cursor + 28, 4}];
            [vboData getBytes:&nz range:(NSRange){cursor + 32, 4}];
            // NSLog(@"VBO: x:%f y:%f z:%f r:%f g:%f b:%f nx:%f ny:%f nz:%f", x, y, z, r, g, b, nx, ny, nz);

        }


    }
    
}


- (void) printIBO 
{
    for(int cursor = 0; cursor < iboData.length; cursor += 3*4) {
        unsigned int a = 0, b = 0, c = 0;
        [iboData getBytes:&a range:(NSRange){cursor, sizeof(unsigned int)}];
        [iboData getBytes:&b range:(NSRange){cursor + 4, sizeof(unsigned int)}];
        [iboData getBytes:&c range:(NSRange){cursor + 8, sizeof(unsigned int)}];

        // NSLog(@"IBO: a:%d b:%d c:%d", a, b, c);
    }    

    
}


- (NSRange) findLabel: (const NSString*) label startFrom: (unsigned long) cursor
{
    NSData *labelData = [label dataUsingEncoding:NSASCIIStringEncoding];
    NSRange searchRange = {cursor, modelData.length - cursor};
    if(cursor + labelData.length  >  modelData.length) {
        return (NSRange){NSNotFound,0};
    }
    
    return [modelData rangeOfData:labelData options:0l range:searchRange];
}

- (NSString*)readValueString: (unsigned long) cursor 
{
    unsigned long destCursor = cursor;
    Byte *oneByte = (Byte*)[modelData bytes];
    do {
        destCursor++;
    }while(oneByte[destCursor] != 0);
    
    NSData *textureFilenameData = [modelData subdataWithRange:(NSRange){cursor, destCursor - cursor}];
    return [[NSString alloc] initWithData:textureFilenameData encoding:NSASCIIStringEncoding];
}

- (unsigned int)readValueNumber: (unsigned long) cursor
{
    unsigned int value = 0;
    
    [modelData getBytes:&value range:(NSRange){cursor, sizeof(unsigned int)}];
    
//    value = NSSwapLittleIntToHost(value);
    return value;
}

@end
