//
//  YAVector3f.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 18.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YAVector3f : NSObject {
@private
    float x;
    float y;
    float z;
}

- (id)initVals: (float)xVal : (float)yVal : (float)zVal; 
- (id)initCopy: (const YAVector3f*) orig;

- (id) initXAxe;
- (id) initYAxe;
- (id) initZAxe;

@property(assign)float x;
@property(assign)float y;
@property(assign)float z;


- (void) setVector: (const YAVector3f*) other;
- (void) setValues: (float)xVal : (float)yVal : (float)zVal; 

- (YAVector3f*) addVector: (const YAVector3f*) other;
- (YAVector3f*) subVector: (const YAVector3f*) other;
- (YAVector3f*) mulScalar: (const float) scalar;
- (YAVector3f*) crossVector: (const YAVector3f*) other;
- (float) dotVector: (const YAVector3f*) other;

- (YAVector3f*) normalize;
- (YAVector3f*) rotate:(float)angle axis:(const YAVector3f*) axis;


- (double) distanceTo: (YAVector3f*) other;


@end
