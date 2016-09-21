//
//  YAFogLight.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 11.11.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import "YAGouradLight.h"

@interface YAFogLight : YAGouradLight {
@protected
    YAVector3f* color;
    float maxDistance;
    float minDistance;
}

@end
