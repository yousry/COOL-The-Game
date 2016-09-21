//
//  YAQuaternion.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 18.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YAVector3f;

@interface YAQuaternion : NSObject {
@private    
    float x;
    float y;
    float z;
    float w;
}

@property(readwrite,assign)float x;
@property(readwrite,assign)float y;
@property(readwrite,assign)float z;
@property(readwrite,assign)float w;

- (id) initVals: (float)xVal : (float)yVal : (float)zVal : (float)wVal; 
- (id) initCopy: (YAQuaternion*) orig;
- (id) initEuler: (float) head pitch: (float) pitch roll: (float) roll;
- (id) initEulerDeg: (float) head pitch: (float) pitch roll: (float) roll;

- (YAQuaternion*) normalize;
- (YAQuaternion*) conjugate;

- (YAQuaternion*) mulQuaternion: (YAQuaternion*) other;
- (YAQuaternion*) addQuaternion: (YAQuaternion*) other;

- (YAQuaternion*) mulVector3f: (YAVector3f*) other;
- (void) setQuat: (YAQuaternion*) other;
- (void) setValues: (float)xVal : (float)yVal : (float)zVal : (float)wVal;

- (YAVector3f*) rotate: (YAVector3f*) vector; 

-(YAVector3f*) euler;

@end
