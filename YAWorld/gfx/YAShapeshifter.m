//
//  YAShapeshifter.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 15.12.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES
#define GLCOREARB_PROTOTYPES
#import <GL/glcorearb.h>

#import <Foundation/NSJSONSerialization.h>
#import <Foundation/NSDictionary.h>

#import "YAPreferences.h"

#import "YALog.h"
#import "YAVector3f.h"
#import "YAQuaternion.h"
#import "YAMatrix4f.h"
#import "YAShapeshifter.h"


@interface YAShapeshifter()
- (void)setupTBO: (NSDictionary*) influences;
@end

@implementation YAShapeshifter

@synthesize inherentModel, shapers;

static const NSString* TAG = @"YAShapeshifter";
static const NSString* OF_TYPE = @"YSR";
static const NSString* MODEL_DIRECTORY_NAME = @"model";


- (id)initFromJson: (NSString*) filename
{
    self = [super init];
    if (self) {
        [YALog debug:TAG message:@"initFromJson"];

        YAPreferences* prefs = [[YAPreferences alloc] init];
        NSString* path = [NSString stringWithFormat:@"%@/%@/%@.%@", prefs.resourceDir , MODEL_DIRECTORY_NAME, filename, OF_TYPE];
        [YALog debug:TAG message:[NSString stringWithFormat:@"Try loading: %@", path]];

        // NSInputStream* iStream = [[NSInputStream alloc] initWithFileAtPath:path];
        // [iStream open];

        NSData* iData = [NSData dataWithContentsOfFile:path];
        [YALog debug:TAG message:[NSString stringWithFormat:@"Length: %ld", iData.length]];

        NSError *error = nil;

        // NSDictionary* shapeShifterJson = [NSJSONSerialization JSONObjectWithStream:iStream options:NSJSONReadingMutableLeaves error:&error];
        NSDictionary* shapeShifterJson = [NSJSONSerialization JSONObjectWithData:iData options:NSJSONReadingMutableLeaves error:&error];
        
        if(error != nil) {
            [YALog debug:TAG message:[NSString stringWithFormat:@"Error in YSR File: %@", error]];
            return nil;
        }
        
        // [iStream close];

        inherentModel = [shapeShifterJson objectForKey:@"Y3D"];
        
        NSArray* shapersJson = [shapeShifterJson objectForKey:@"Shapers"];
        [YALog debug:TAG message:[NSString stringWithFormat:@"Number of shapers: %ld", [shapersJson count]]];
        
        shapers = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        for (NSDictionary* shaperJson in shapersJson) {
            NSString *name = [shaperJson objectForKey:@"Name"];
            NSNumber *myId = [shaperJson objectForKey:@"Id"]; 
            NSNumber *parentId = [shaperJson objectForKey:@"Parent"];

            NSArray *jointCoords = [shaperJson objectForKey:@"Joint"];
            YAVector3f* joint = [[YAVector3f alloc] initVals:[[jointCoords objectAtIndex:0] floatValue] 
                                                            :[[jointCoords objectAtIndex:1] floatValue] 
                                                            :[[jointCoords objectAtIndex:2] floatValue]];
            
            NSArray* quatCoords = [shaperJson objectForKey:@"Quaternion"];
            YAQuaternion* quat = [[YAQuaternion alloc] initVals:[[quatCoords objectAtIndex:0] floatValue] 
                                                             :[[quatCoords objectAtIndex:1] floatValue] 
                                                             :[[quatCoords objectAtIndex:2] floatValue]
                                                             :[[quatCoords objectAtIndex:3] floatValue]];
            
            NSArray* boneMat = [shaperJson objectForKey:@"Bone"];
            YAMatrix4f* bone = [[YAMatrix4f alloc] init ];
            for (int i = 0; i < [boneMat count]; i++) 
                bone->m[i % 4][i / 4] = [[boneMat objectAtIndex:i] floatValue];

            NSMutableDictionary* shaper = [[NSMutableDictionary alloc] init];

            // Be aware of the attributes
            [shaper setObject:name forKey:@"NAME"];
            [shaper setObject:myId forKey:@"MYID"];
            [shaper setObject:parentId forKey:@"PARENT"];
            [shaper setObject:joint forKey:@"JOINT"];
            [shaper setObject:quat forKey:@"QUATERNION"];
            [shaper setObject:bone forKey:@"BONE"];
            
            // Shapers are indexed by their name.
            [shapers setObject:shaper forKey:name];
        }
        
        
        shapeData = [NSMutableData dataWithLength:sizeof(float) * 7];
        [self setupTBO:[shapeShifterJson objectForKey:@"Influences"]];
        
    }
    
    return self;
}


- (void)setupTBO: (NSArray*) influences
{
    const int descriptionLength = 3 + 4 + 3; // location + quat + target
    
    
    int blendOffset = (int)[influences count] * 2;  // 2 values (index and length) 
    [YALog debug:TAG message:[NSString stringWithFormat: @"Blend offset. %d", blendOffset]];
    
    int matrixOffset = blendOffset;
    for (NSDictionary* influence in influences) {
        NSArray *boneReferences = [influence objectForKey:@"Bones"]; 
        matrixOffset += [boneReferences count] * 2; // ( index, weight ) 
    }
    [YALog debug:TAG message:[NSString stringWithFormat: @"Bones offset. %d", matrixOffset]];
    
    
    tboData = [NSMutableData dataWithLength:sizeof(float)  * (blendOffset + matrixOffset + ( [shapers count] * (descriptionLength)))]; // I don't want to copy the Matrix to the tpo
    
    [YALog debug:TAG message:[NSString stringWithFormat:@"Array of size '%ld' created.", [tboData length] ]];
    
    float* tboArray = [tboData mutableBytes];     

    // and again
    int offset = blendOffset;
    for (NSDictionary* influence in influences) {

        NSArray *boneReferences = [influence objectForKey:@"Bones"];
        
        int verticeIndex = [[influence objectForKey:@"Vertice"] intValue];
        
        // calculate the bone Index
        tboArray[verticeIndex * 2] = (float)offset;
        tboArray[verticeIndex * 2 + 1] = (float)[boneReferences count]; //  boneIndex, length
        
        for(NSDictionary* boneRef in boneReferences) {
            tboArray[offset++] =  (float) matrixOffset +  [[boneRef objectForKey:@"Bone"] intValue] * (descriptionLength);
            tboArray[offset++] = [[boneRef objectForKey:@"Blend"] floatValue];
        }
    }

    // offset shoud now be at shaper position
    for (NSString* shaperName in shapers) {
  
        NSMutableDictionary* shaper = [shapers objectForKey:shaperName];     
        int myId = [[shaper objectForKey:@"MYID"] intValue];

        [shaper setValue:[NSNumber numberWithInt:offset + (myId * descriptionLength)] forKey:@"TBOPOSITION"];
        

        YAVector3f* joint = [shaper objectForKey:@"JOINT"];
        YAQuaternion* quaternion = [shaper objectForKey:@"QUATERNION"];  
        
        tboArray[offset + (myId * descriptionLength) + 0] = joint.x;
        tboArray[offset + (myId * descriptionLength) + 1] = joint.y;
        tboArray[offset + (myId * descriptionLength) + 2] = joint.z;

        tboArray[offset + (myId * descriptionLength) + 3] = quaternion.x;
        tboArray[offset + (myId * descriptionLength) + 4] = quaternion.y;
        tboArray[offset + (myId * descriptionLength) + 5] = quaternion.z;
        tboArray[offset + (myId * descriptionLength) + 6] = quaternion.w;
        
        // new position after joint rotation
        tboArray[offset + (myId * descriptionLength) + 7] = joint.x;
        tboArray[offset + (myId * descriptionLength) + 8] = joint.y;
        tboArray[offset + (myId * descriptionLength) + 9] = joint.z;
    }
}


- (bool) createTBO
{
    [YALog debug:TAG message:@"createTPO"];
    
    if (tboData == nil) {
        [YALog debug:TAG message:@"Bonedata not available!"];
        return false;
    }
    
    float* tboArray = [tboData mutableBytes];  

    glGenBuffers(1, &tboId);
    glBindBuffer(GL_TEXTURE_BUFFER, tboId); 
    glBufferData(GL_TEXTURE_BUFFER, [tboData length], tboArray, GL_DYNAMIC_DRAW);

    tboData = nil;
    
    return [YALog isGLStateOk:TAG message:@"createTBO"];
}

- (void) dealloc
{
    [self destroyTBO];
}

- (bool) destroyTBO
{
    [YALog isGLStateOk:TAG message:@"destroyTBO / Entry"];
    glBindBuffer(GL_TEXTURE_BUFFER, tboId);
    glDeleteBuffers(1, &tboId);
    return [YALog isGLStateOk:TAG message:@"destroyTBO"];
}

- (void) bind: (GLenum) position
{
    [YALog isGLStateOk:TAG message:@"bind / init FAILED"];
    glActiveTexture(position);
    glBindBuffer(GL_TEXTURE_BUFFER, tboId); 
    glTexBuffer(GL_TEXTURE_BUFFER, GL_R32F, tboId);
    [YALog isGLStateOk:TAG message:@"Could not bind tbo."];
}


- (void) updateShaper: (NSDictionary*) shaper
{
    NSMutableDictionary* _shaper = [shapers objectForKey:[shaper objectForKey:@"NAME"]];
    if(_shaper != nil) {
        float* tboArray = [shapeData mutableBytes];  
        GLintptr offset = [[_shaper objectForKey:@"TBOPOSITION"] intValue];
        YAVector3f* joint = [shaper objectForKey:@"JOINT"];
        YAQuaternion* quaternion = [shaper objectForKey:@"QUATERNION"];  
        
        tboArray[0] = quaternion.x;
        tboArray[1] = quaternion.y;
        tboArray[2] = quaternion.z;
        tboArray[3] = quaternion.w;
        
        tboArray[4] = joint.x;
        tboArray[5] = joint.y;
        tboArray[6] = joint.z;
        
        glBufferSubData(GL_TEXTURE_BUFFER, (offset + 3) * 4, sizeof(float) * 7, tboArray);
    }
}

@end
