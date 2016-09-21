//
//  YAIngredient.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 24.10.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#define GLFW_INCLUDE_NONE
#import <GL/glcorearb.h>
#import <GLFW/glfw3.h>

#import "YAIngredient.h"
#import "YAModel.h"
#import "YARenderLoop.h"
#import "YALog.h"

@implementation YAIngredient

static const NSString* TAG = @"YAIngredient";

@synthesize flavour, texture, text;
@synthesize autoMipMap;

- (id)initWithName:(NSString *)name  world:(YARenderLoop*) world
{
    self = [super init];
    if (self) {
        _world = world;
        _name = name;
        texture = nil;
        text = @"";
        autoMipMap = false;
    }

    return self;
}


- (NSString*) model {
    return _model;
}


// grid without normals and uv
- (void)createModelfromGrid: (NSData*) triangleData
{
    _model = _name;
    [_world createModelFromGrid: triangleData name:_name ingredient:self];
}


/* add triangles with vertex normals
*/
- (void)createModelfromTriangles: (NSData*) triangleData
{
    _model = _name;
    [_world createModelFromTriangles: triangleData name:_name ingredient:self];
}


- (void)updateTriangles: (NSData*) triangleData
{
    [_world updateModel:_name withTriangles:triangleData];
}

/*
 Set model file for Ingredient. Use the default shader for rendering.
 */
- (void) setModel: (NSString*) modelName
{
    _model = modelName;
    [_world addModel:modelName ingredient:self];
}


- (void)setModelWithShader: (NSString*) modelName shader: (NSString*) shaderId;
{
    _model = modelName;
    [_world addModelWithShader: modelName shader: shaderId ingredient:self];
}


- (NSString *)description {

    return [NSString stringWithFormat:@"Object: %@ Name: %@", TAG, _name];
}

@end
