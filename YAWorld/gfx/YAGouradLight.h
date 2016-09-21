//
//  YAGouradLight.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 11.11.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import "Positionable.h"
#import "WithRadiation.h"

#import "YALight.h"

@interface YAGouradLight : YALight <Positionable, WithRadiation> 

@property (assign, readwrite) bool directional;
// @property (strong, readonly) YAVector3f* position;
// @property (strong, readonly) YAVector3f* intensity;

@end
