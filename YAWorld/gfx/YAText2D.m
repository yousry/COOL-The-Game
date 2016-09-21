//
//  YAText2D.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 03.12.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import "fuTypes.h"
#import <Foundation/NSTextCheckingResult.h>

#import "YAPreferences.h"

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES
#define GLCOREARB_PROTOTYPES
#import <GL/glcorearb.h>

#import "YATexture.h"
#import "YALog.h"
#import "YAShader.h"
#import "YAText2D.h"


@interface YAText2D()
- (void)loadCharacterMap;
- (NSPoint) calcUVCoords: (int) x : (int) y; 
@end

@implementation YAText2D

@synthesize vbos;


const static NSString* TAG = @"YAText2D";

const static NSString* ELEM_X_POS = @"x";
const static NSString* ELEM_Y_POS = @"y";
const static NSString* ELEM_WIDTH = @"width";
const static NSString* ELEM_HEIGHT = @"height";
const static NSString* ELEM_X_OFFSET = @"xOffset";
const static NSString* ELEM_Y_OFFSET = @"yOffset";


static const NSString* TEXTURE_DIRECTORY_NAME = @"compiled";
static const NSString* TEXTURE_DIRECTORY_SOURCE_NAME = @"texture";
static const NSString* FONT_DIRECTORY_SOURCE_NAME = @"texture/font";


static NSMutableDictionary* characterMap = nil;
static YATexture* _texture;

// need something for proportions:  max = 1
static float maxHeight = 0;
static float maxWidth = 0;

+ (void) setupText: (YATexture*) texture
{
    // [YALog debug:TAG message:@"setupText"];
    characterMap = [[NSMutableDictionary alloc] initWithCapacity:255];
    _texture = texture;
}

- (id)initText:(NSString *) text
{
    // [YALog debug:TAG message:@"initText"];
    self = [super init];
    
    if (self) {
        vbos = [[NSMutableData alloc] init];
        
        if ([characterMap count] == 0)
            [self loadCharacterMap];
        
        [self setText:text];
        
    }
    
    return self;
}

- (void) setText:(NSString *)text
{
    GLfloat vertices[] = {    
        0.0f, 0.0f, 
        0.0f, 1.0f,
        1.0f, 0.0f,
        
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f
    };

    float x = 0;
    float y = 0;
    for(int i = 0; i < [text length]; i++ ) {
        char c = [text characterAtIndex:i];
        
        // [YALog debug:TAG message:[NSString stringWithFormat:@"Encoding: %c", c]];
        
        if ( c == '\n') {
            y -= 1.5f;
            x = 0;
        }
        else {
            NSDictionary* uvData = [characterMap objectForKey:[NSNumber numberWithInt:c]];
            // [YALog debug:TAG message:[NSString stringWithFormat:@"Data: %@", uvData]];
            
            for (int j = 0; j < 12; j += 2) {
                
                float xCoord = vertices[j] * (([[uvData objectForKey:ELEM_WIDTH] floatValue] +  [[uvData objectForKey:ELEM_X_OFFSET] floatValue])/ maxWidth) + x;
                float yCoord = vertices[j+1] * ([[uvData objectForKey:ELEM_HEIGHT] floatValue] + [[uvData objectForKey:ELEM_Y_OFFSET] floatValue]/ maxHeight) + y;
                float zCoord = 0;
                
                float u = [[uvData objectForKey:ELEM_X_POS] floatValue];
                float v = 1.0f - ([[uvData objectForKey:ELEM_Y_POS] floatValue] + [[uvData objectForKey:ELEM_HEIGHT] floatValue]);
                
                const int vI = j / 2; // the virtual index of the calculated vertex
                
                // calculate the uv mapping
                if (vI == 2 | vI == 3 | vI == 5)
                    u += [[uvData objectForKey:ELEM_WIDTH] floatValue];
                
                if (vI == 1 | vI == 4 | vI == 5)
                    v += [[uvData objectForKey:ELEM_HEIGHT] floatValue];

                
                [vbos appendBytes:&xCoord length:sizeof(float)];
                [vbos appendBytes:&yCoord length:sizeof(float)];
                [vbos appendBytes:&zCoord length:sizeof(float)];

                [vbos appendBytes:&u length:sizeof(float)];
                [vbos appendBytes:&v length:sizeof(float)];
                
                // [YALog debug:TAG message:[NSString stringWithFormat:@"x: %f y: %f z: %f u: %f v: %f", xCoord, yCoord, zCoord, u, v]];
                
            }
            
            x += ([[uvData objectForKey:ELEM_WIDTH] floatValue] / maxWidth);
            
            if(c == ' ') x += 0.2;
        }
    }
}

- (void)loadCharacterMap
{
    [YALog debug:TAG message:@"loadCharacterMap"];

    YAPreferences* prefs = [[YAPreferences alloc] init];
    NSString* path = [NSString stringWithFormat:@"%@/%@/%@.%@", prefs.resourceDir ,FONT_DIRECTORY_SOURCE_NAME, @"Knewave-Regular.ttf_sdf", @"txt"];
    [YALog debug:TAG message:[NSString stringWithFormat:@"Path  url: %@.", path]];

    NSString* rawContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    NSArray* lines =  [rawContent componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    
    NSError* error;
    
    NSRegularExpression* structureRegExp = [NSRegularExpression regularExpressionWithPattern: @"^char \\bid=(\\d*)\\b\\s*\\bx=(\\d*)\\b\\s*\\by=(\\d*)\\b\\s*\\bwidth=(\\d*)\\b\\s*\\bheight=(\\d*)\\b\\s*\\bxoffset=(.*)\\b\\s*\\byoffset=(.*)\\b" options:NSRegularExpressionCaseInsensitive error:&error];
    
    for (NSString* line in lines) {
        
        NSArray* ids = [structureRegExp matchesInString:line options:0 range:NSMakeRange(0, [line length])];
        
        if ([ids count] > 0) {
            NSTextCheckingResult* result = [ids objectAtIndex:0];
            int id = [[line substringWithRange:[result rangeAtIndex:1]] intValue];
            int x = [[line substringWithRange:[result rangeAtIndex:2]] intValue];
            int y = [[line substringWithRange:[result rangeAtIndex:3]] intValue];
            int width = [[line substringWithRange:[result rangeAtIndex:4]] intValue];
            int height = [[line substringWithRange:[result rangeAtIndex:5]] intValue];
            float xOffset = [[line substringWithRange:[result rangeAtIndex:6]] floatValue];
            float yOffset = [[line substringWithRange:[result rangeAtIndex:7]] floatValue];
            
            if (id == 'S' || id == 'p')
                [YALog debug:TAG message:[NSString stringWithFormat:@"id: %d x: %d y: %d width: %d height: %d xoffset: %f yoffset: %f", id, x, y, width, height, xOffset, yOffset]];
            
            
            NSPoint uvCoords = [self calcUVCoords:x :y];
            NSPoint uvDimensions = [self calcUVCoords:width :height];
            // works only because of the 0 to 1 vcoord scale
            NSPoint verticeOffset = [self calcUVCoords:xOffset :yOffset];
            
            if (maxWidth < uvDimensions.x)
                maxWidth = uvDimensions.x;
            
            if (maxHeight < uvDimensions.y)
                maxHeight = uvDimensions.y;

            NSDictionary* elem = [[NSDictionary alloc] initWithObjectsAndKeys: 
                                  [NSNumber numberWithFloat:uvCoords.x], (NSString*)ELEM_X_POS, 
                                  [NSNumber numberWithFloat:uvCoords.y], (NSString*)ELEM_Y_POS, 
                                  [NSNumber numberWithFloat:uvDimensions.x], (NSString*)ELEM_WIDTH,
                                  [NSNumber numberWithFloat:uvDimensions.y], (NSString*)ELEM_HEIGHT, 
                                  [NSNumber numberWithFloat:verticeOffset.x], (NSString*)ELEM_X_OFFSET, 
                                  [NSNumber numberWithFloat:verticeOffset.y], (NSString*)ELEM_Y_OFFSET, 
                                  nil ]; 
            
            [characterMap setObject:elem forKey:[NSNumber numberWithInt:id]];
//            [YALog debug:TAG message:[NSString stringWithFormat:@"Elem id: %d is %@", id, elem]];
        }
    } 
}


- (NSPoint) calcUVCoords: (int) x : (int) y 
{
    NSPoint result;
    result.x = (float) x / (float)[_texture pixelWidth];
    result.y = (float) y / (float)[_texture pixelHeight];
    return result;
}

@end
