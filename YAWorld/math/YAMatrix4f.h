//
//  YAMatrix4f.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 18.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YAVector3f, YAVector4f, YAPerspectiveProjectionInfo, YAQuaternion;

@interface YAMatrix4f : NSObject {
@public
    float m[4][4];
}

- (id) initIdentity;
- (id)initScaleTransform: (float)scaleX : (float)scaleY : (float)scaleZ;
- (id)initRotateTransform: (float)rotateX : (float)rotateY : (float)rotateZ;
- (id)initRotateQuatTransform: (YAQuaternion*) quatRotation;
- (id)initTranslationTransform: (float)transX : (float)transY : (float)transZ;

- (id)initCameraTransform: (const YAVector3f*)target up: (const YAVector3f*)up;
- (id)initPerspectiveProjectionTransform: (const YAPerspectiveProjectionInfo*) ppInfo;


- (id)initShadowBiasTransform;


- (YAMatrix4f*) mulMatrix4f: (const YAMatrix4f*) other;
- (YAMatrix4f*) mulMatrix4f: (const YAMatrix4f*) other into: (YAMatrix4f*) result; // faster because no initialization needed



- (YAVector4f*) mulVector4f: (const YAVector4f*) vector;

- (YAVector4f*) mulVector3f: (const YAVector3f*) vector;

- (YAMatrix4f*) createTranspose;

- (void) setMatrix: (const YAMatrix4f*) other;

@end
