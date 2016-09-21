//
//  YALight.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 23.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

// #import <Foundation/Foundation.h>

@class YAVector3f, YAVector4f, YAShader, YATransformator;

@interface YALight : NSObject {
@protected  
    
    // for frag ads
    YAVector3f* ambientColor;
    float ambientIntensity;
    
    YAVector3f* direction;
    float diffuseIntensity;
    
}

@property (readonly) YAVector3f* ambientColor;
@property (readwrite, assign) float ambientIntensity;

@property (readonly) YAVector3f* direction;
@property (readwrite, assign) float diffuseIntensity;

- (const NSString*) name;
- (void) shine: (YAShader*) shader transformator: (YATransformator*) transformator;

@end
