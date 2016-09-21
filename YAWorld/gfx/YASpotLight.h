//
//  YASpotLight.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 11.11.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#define GLFW_INCLUDE_NONE
#import <GL/glcorearb.h>
#import <GLFW/glfw3.h>

#import "Positionable.h"
#import "WithRadiation.h"

#import "YALight.h"

@interface YASpotLight : YALight <Positionable, WithRadiation>{
@protected
    YAVector3f* position;
    YAVector3f* intensity;

    float exponent;
    float cutoff;

    GLuint positionID, intensityID, directionID, exponentID, cutoffID;
}

@property (assign, readwrite) float cutoff;
@property (assign, readwrite) float exponent;

// utillity functions
- (void) spotAt: (YAVector3f*) target;

@end
