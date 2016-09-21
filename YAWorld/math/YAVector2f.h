//
//  YAVector2f.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 18.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YAVector2f : NSObject {
@private
    float x;
    float y;
}

- (id) initVals: (float)xVal : (float)yVal;   
- (id) initCopy: (YAVector2f*) orig;

@property(assign)float x;
@property(assign)float y;

- (YAVector2f*) normalize;

- (YAVector2f*) addVector: (const YAVector2f*) other;
- (YAVector2f*) subVector: (const YAVector2f*) other;


- (YAVector2f*) mulScalar: (const float) scalar;
- (double) length;
- (double) distanceTo: (YAVector2f*) other;



@end
