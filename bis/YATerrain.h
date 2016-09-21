//
//  YATerrain.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 11.05.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YAHeightMap.h"
#import <Foundation/Foundation.h>

@interface YATerrain : NSObject <YAHeightMap> {
@private
    float _seed;
}


@property (assign, readwrite) int tDisplacement;
@property (assign, readwrite) float tAmplitude;
@property (assign, readwrite) int tTileBorder;
@property (assign, readwrite) float tFrequency;
@property (assign, readwrite) float tGain;
@property (assign, readwrite) float tLacunarity;
@property (assign, readwrite) int tOctaves;

@property (assign, readwrite) int fieldWidth;
@property (assign, readwrite) int fieldHeight;
@property (assign, readwrite) int brdSize;


- (id) init;
- (id) initSize: (int) size;
- (void) generate: (float) seed;
- (float) heightAt :(int) x :(int) y; 
- (float) flattenField :(int) x :(int) y; // returns the avarage height

- (void) createMountain: (int) x : (int) y;

@end
