//
//  YASimplexNoise.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 02.08.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

/*
 Original: http://webstaff.itn.liu.se/~stegu/simplexnoise/SimplexNoise.java
 
 This code was placed in the public domain by its original author,
 Stefan Gustavson. You may use it as you see fit, but
 attribution is appreciated.
 */


#import <Foundation/Foundation.h>

@interface YASimplexNoise : NSObject

+ (double) noise: (double) xin :(double) yin;
+ (double) noise: (double) xin :(double) yin :(double) zin;
+ (double) noise: (double) x :(double) y :(double) z :(double) w;

@end
