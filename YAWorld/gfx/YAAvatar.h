//
//  YAAvatar.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 20.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YATransformator, YAVector3f;

@interface YAAvatar : NSObject {
    YATransformator* _transformator;
    
    bool moveForward;
    bool moveBackwardeward;
    bool moveLeft;
    bool moveRight;
    
}

@property(readwrite,assign) YAVector3f* position;

@property(readwrite,assign) float stepSize;
@property(readwrite,assign) bool moveForward;
@property(readwrite,assign) bool moveBackward;
@property(readwrite,assign) bool moveLeft;
@property(readwrite,assign) bool moveRight;

@property(readwrite,assign) float headAtlas;
@property(readwrite,assign) float headAxis;

- (void) moveHead: (float)speedX : (float)speedY;
- (void) setAtlas: (float)atlas axis: (float)axis;

- (id) initWithTransformator: (YATransformator*) transformator;

- (void) setFocus: (YAVector3f*) direction;

- (void) nextStep; 

- (void) lookAt: (YAVector3f*) target;
- (void) recenter: (YAVector3f*) target MarginAtlas: (float) marginAtlas MarginAxis: (float) marginAxis;

@end
