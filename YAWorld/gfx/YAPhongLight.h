//
//  YAPhongLight.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 09.11.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import "YALight.h"


@interface YAPhongLight : YALight {
@private
    YAVector4f* position;
    YAVector3f* ambientLightIntensity;
    YAVector3f* diffuseLightIntensity;
    YAVector3f* specularLightIntensity;
}

@property (strong, readonly) YAVector4f* position;
@property (strong, readonly) YAVector3f* ambientLightIntensity;
@property (strong, readonly) YAVector3f* diffuseLightIntensity;
@property (strong, readonly) YAVector3f* specularLightIntensity;

@end
