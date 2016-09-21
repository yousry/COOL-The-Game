//
//  YAImpersonator.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 26.10.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YAVector3f, YAMaterial, YAShapeshifter, YAQuaternion, YAMatrix4f;

@interface YAImpersonator : NSObject {
@private
    int identifier;
    YAVector3f* translation;
    YAVector3f* rotation;
    YAVector3f* size;
    bool visible;
    bool shadowCaster;
    NSString* ingredientName;
    YAMaterial* material;
    YAShapeshifter* _shapeshifter;
    
    YAQuaternion* _rotationQuaternion;
    YAMatrix4f* _quatMatrix;
}

- (id)initWithIngredient: (NSString*) name;

@property (strong,readonly) NSMutableDictionary* joints;
@property (readonly) NSString* ingredientName;
@property (assign, readwrite) int identifier;
@property (readonly) YAVector3f* translation;
@property (readonly) YAVector3f* rotation;
@property (readonly) YAVector3f* size;
@property (readonly) YAMaterial* material;

@property (assign, readwrite) bool shadowCaster;
@property (assign, readwrite) bool visible;
@property (assign, readwrite) bool clickable;
@property (assign, readwrite) bool backfaceCulling;
@property (assign, readwrite) float normalMapFactor; // also for heightmap


- (void) addShapeshifter: (YAShapeshifter*) shapeshifter;
- (YAShapeshifter*) shapeshifter; 

- (void) updateShapeshifter;
- (void) resize: (float) size;


// Addendum use quaternions for rotation
@property (assign,readwrite) bool useQuaternionRotation;
@property (strong, readwrite) YAQuaternion* rotationQuaternion;
-(YAMatrix4f*) quatMatrix;

// Only used for relative positions in groups
@property (readonly) YAVector3f* originTranslation;
@property (readonly) YAVector3f* originRotation;
@property (readonly) YAVector3f* originSize;
@property (readonly) YAQuaternion* originRotationQuaternion;

@end
