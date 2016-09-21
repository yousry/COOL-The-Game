//
//  YAImprovedNoise.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 20.05.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

// based on ImpovedNoise by Ken Perlin

#import <Foundation/Foundation.h>
@class YAVector2f;

@interface YAImprovedNoise : NSObject

+ (float) noiseAtX: (float) x Y: (float) y  Z: (float) z;

@end
