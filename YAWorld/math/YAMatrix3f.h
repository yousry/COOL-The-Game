//
//  YAMatrix3f.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 10.11.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YAMatrix4f, YAVector3f;

@interface YAMatrix3f : NSObject {
@public
    float m[3][3];
}


- (void)extractNormalMatrix: (YAMatrix4f*) modelViewMatrix;
- (void)extractRotationMatrix: (YAMatrix4f*) fourDimMatrix;
- (void)normalize;

- (YAVector3f*) mulVector3f: (const YAVector3f*) vector;

@end
