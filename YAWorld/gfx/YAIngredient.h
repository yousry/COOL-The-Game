//
//  YAIngredient.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 24.10.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>


@class NSString, YARenderLoop;

enum flavourType
{
    Model3D = 0,
    Model2D = 1,
    Text = 2,
    Hud = 3,
    PointLight = 4,
    SpotLight = 5,
    SkyMap = 6,
    Terrain = 7
};


@interface YAIngredient : NSObject {
    
@private    
    NSString* _name;
    YARenderLoop* _world;
    enum flavourType flavour;
    
    NSString* _model;
    NSString* texture;
    
}

@property(assign, readwrite) bool autoMipMap;
@property(readwrite) enum flavourType flavour;
@property(strong, readwrite) NSString* texture;
@property(copy, readwrite) NSString* text;

- (id)initWithName: (NSString*) name world:(YARenderLoop*) world;

- (NSString*) model;
- (void) setModel: (NSString*) modelName;

- (void)setModelWithShader: (NSString*) modelName shader: (NSString*) shaderId;

- (void)createModelfromGrid: (NSData*) triangleData;
- (void)createModelfromTriangles: (NSData*) triangleData;
- (void)updateTriangles: (NSData*) triangleData;
@end
