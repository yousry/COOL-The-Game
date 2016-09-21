//
//  YAImpersonator.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 26.10.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES
#define GLCOREARB_PROTOTYPES
#import <GL/glcorearb.h>

#import "YAQuaternion.h"
#import "YAMatrix4f.h"
#import "YAVector3f.h"
#import "YAQuaternion.h"
#import "YAShapeshifter.h"
#import "YALog.h"
#import "YAMaterial.h"
#import "YAGroupListener.h"
#import "YAImpersonator.h"

#define ToRadian(x) ((x) * M_PI / 180.0f)
#define ToDegree(x) ((x) * 180.0f / M_PI)
#define ToGrad(x) ((x) * M_PI / 360.0f)

@implementation YAImpersonator

static int nextId = 100;

@synthesize translation, material, joints, backfaceCulling;
@synthesize rotation, size, visible,clickable ,identifier, ingredientName;
@synthesize normalMapFactor, shadowCaster;
@synthesize originRotation, originTranslation, originSize, originRotationQuaternion;
@synthesize useQuaternionRotation;

- (id)initWithIngredient: (NSString*) name
{
    self = [super init];
    if (self) {
        ingredientName = name;
        identifier = nextId++;
        translation = [[YAVector3f alloc] init];
        rotation  = [[YAVector3f alloc] init];;
        size = [[YAVector3f alloc] initVals:1.0f :1.0f :1.0f];
        material = [[YAMaterial alloc] init];
        joints = [[NSMutableDictionary alloc] initWithCapacity:10];
        backfaceCulling = true;
        normalMapFactor = 1.0;
        visible = true;
        clickable = false;
        shadowCaster = true;
        useQuaternionRotation = false;
        _rotationQuaternion =[[YAQuaternion alloc] init];
        _quatMatrix = nil;
    }

    return self;
}

- (void) resize: (float) newSize
{
    size = [[YAVector3f alloc] initVals:newSize :newSize :newSize];
}


- (void) addShapeshifter: (YAShapeshifter*) shapeshifter;
{
    _shapeshifter = shapeshifter;
    for (id shaperId in [shapeshifter shapers]) {
        NSMutableDictionary* shaper = [[shapeshifter shapers] objectForKey:shaperId];
        NSMutableDictionary* shapeCopy = [[NSMutableDictionary alloc] init];

        [shapeCopy setObject:[shaper objectForKey:@"NAME"] forKey:@"NAME"];
        [shapeCopy setObject:[shaper objectForKey:@"MYID"] forKey:@"MYID"];
        [shapeCopy setObject:[shaper objectForKey:@"PARENT"] forKey:@"PARENT"];
        [shapeCopy setObject:[shaper objectForKey:@"JOINT"] forKey:@"JOINT"];
        [shapeCopy setObject:[shaper objectForKey:@"QUATERNION"] forKey:@"QUATERNION"];
        [shapeCopy setObject:[shaper objectForKey:@"BONE"] forKey:@"BONE"];
        [joints setObject:shapeCopy forKey:[shaper objectForKey:@"NAME"]];
    }
}

- (YAShapeshifter*) shapeshifter
{
    return _shapeshifter;
}


- (void) updateShapeshifter
{
    for (id jointId in joints)
        [_shapeshifter updateShaper:[joints objectForKey:jointId]];
}

// TODO: Move to extension.
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    if(originTranslation == nil)
        originTranslation = [[YAVector3f alloc] initCopy:translation];

    if(originRotation == nil)
        originRotation = [[YAVector3f alloc] initCopy:rotation];

    if(originRotationQuaternion == nil)
        originRotationQuaternion = [[YAQuaternion alloc] initCopy:_rotationQuaternion];

    if(originSize == nil)
        originSize = [[YAVector3f alloc] initCopy:size];


    [size setValues:originSize.x :originSize.y :originSize.z];
    [translation setValues:originTranslation.x :originTranslation.y :originTranslation.z];
    [rotation setValues:originRotation.x :originRotation.y :originRotation.z];


    // TODO: handle the different states for the group. Only works for simple structures.
    id <YAGroupListener> group = object;


    if(group.visible == false) {
        visible = false;
        [YALog debug:@"YAImpersonator" message:@"observeValueForKeyPath EXIT A"];
        return;
    }


    visible = true;

    __block NSString* state = group.state.copy;

    NSEnumerator* e = [group.states objectEnumerator];
    NSArray* stateEntry;


    while (stateEntry = [e nextObject]) {
        NSString* eState = [stateEntry objectAtIndex:0];
        int eId = [[stateEntry objectAtIndex:1] intValue];
        NSString* eModifier = [stateEntry objectAtIndex:2];
        id value = [stateEntry objectAtIndex:3];


        if([state isEqualToString: eState] && eId == identifier) {
            id fValue = nil;
            if([value isKindOfClass:[YAVector3f class]])
                fValue = [[YAVector3f alloc] initCopy:(YAVector3f*)value]; // create a copy regarding references
            else
                fValue = value;

           if([eModifier isEqualToString: @"visible"])
                self.visible = ((NSNumber*) fValue).boolValue;
           else if([eModifier isEqualToString: @"useQuaternionRotation"])
                self.useQuaternionRotation = ((NSNumber*) fValue).boolValue;
           else
               [self setValue:fValue forKey:eModifier];
        }
    }


    YAVector3f *rot = nil;
    YAVector3f *rotB = nil;

    if(!group.useQuaternionRotation) {
        [rotation addVector:[group rotation]];
    } else {
        [group.rotationQuaternion normalize];
        rot = group.rotationQuaternion.euler;
        rotB = [[YAVector3f alloc] initVals:ToDegree(rot.z) :-ToDegree(rot.x) :ToDegree(rot.y) ];
        [rotation addVector:rotB];
    }

    // rotate around origin
    // WARNING: Gimbal Lock
    // NOTEWORTHY: internally quaternions are used for the vecctor rotation.

    if(!group.useQuaternionRotation) {
        [translation rotate:group.rotation.x axis:[[YAVector3f alloc] initXAxe]];
        [translation rotate:-group.rotation.y axis:[[YAVector3f alloc] initYAxe]];
        [translation rotate:group.rotation.z axis:[[YAVector3f alloc] initZAxe]];
    } else {
        // TODO:  use quat rotation instead
        [translation rotate:rotB.x axis:[[YAVector3f alloc] initXAxe]];
        [translation rotate:-rotB.y axis:[[YAVector3f alloc] initYAxe]];
        [translation rotate:rotB.z axis:[[YAVector3f alloc] initZAxe]];
    }


    [translation addVector:[group translation]];
    [size setVector:[group size]];


}


- (void) setRotationQuaternion: (YAQuaternion*) rotationQuaternion
{
    [_rotationQuaternion setQuat:rotationQuaternion];
    _quatMatrix = nil;
}


- (YAQuaternion*) rotationQuaternion
{
    _quatMatrix = nil;
    return _rotationQuaternion;
}

-(YAMatrix4f*) quatMatrix
{
    if (_quatMatrix == nil) {
        [_rotationQuaternion normalize];
        _quatMatrix = [[YAMatrix4f alloc] initRotateQuatTransform:_rotationQuaternion];
    }

    return _quatMatrix;
}

@end
