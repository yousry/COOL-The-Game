//
//  YATransformator.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 19.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YAVector3f, YAVector4f, YAMatrix4f, YAPerspectiveProjectionInfo;

@interface YATransformator : NSObject {
@private
    
    YAPerspectiveProjectionInfo* projectionInfo;
    
    // Object Specific
    YAVector3f* scale;
    YAVector3f* rotate;
    YAVector3f* translate;
    
    // Scene Specific
    YAVector3f* eyePos;
    YAVector3f* eyeFocus;
    YAVector3f* eyeUp;
    
    YAMatrix4f* modelM;
    YAMatrix4f* modelViewM;
    YAMatrix4f* projectionM;
    
    YAMatrix4f* cameraTM;
    YAMatrix4f* cameraM;
    
    YAMatrix4f* viewM;
    
    YAMatrix4f* rotateM;
    YAMatrix4f* rx;
    YAMatrix4f* ry;
    YAMatrix4f* rz;
    
    // speed
    YAMatrix4f* tempM;
    
    int renderWidth, renderHeight;
}

@property (strong, readonly) YAPerspectiveProjectionInfo*  projectionInfo;
@property (readonly) int renderWidth;
@property (readonly) int renderHeight;


@property(strong, readonly) YAMatrix4f* viewMatrix; 
@property(strong, readonly) YAMatrix4f* modelMatrix; 
@property(strong, readonly) YAMatrix4f* modelviewMatrix; 
@property(strong, readonly) YAMatrix4f* projectionMatrix; 

// object space
@property(strong, readonly) YAVector3f* scale;
@property(strong, readonly) YAVector3f* rotate;

@property(weak, readwrite) YAMatrix4f* rotateQuatMatrix;

@property(strong, readonly) YAVector3f* translate;
- (const YAMatrix4f*) transform;

// global
@property(strong, readonly) YAVector3f* eyePos;
@property(strong, readonly) YAVector3f* eyeFocus;
@property(strong, readonly) YAVector3f* eyeUp;

- (void)recalcCam;

- (void)setDisplaySize: (int)width height:(int)height;
- (NSArray*) trapezoid;

@end
