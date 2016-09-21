//
//  YAMatrix3f.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 10.11.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import "YAVector3f.h"
#import "YAMatrix4f.h"
#import "YAMatrix3f.h"

@implementation YAMatrix3f

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)extractNormalMatrix: (YAMatrix4f*) modelViewMatrix
{
    
    YAMatrix4f* t = modelViewMatrix;
    m[0][0] = t->m[0][0]; m[0][1] = t->m[0][1]; m[0][2] = t->m[0][2];
    m[1][0] = t->m[1][0]; m[1][1] = t->m[1][1]; m[1][2] = t->m[1][2];
    m[2][0] = t->m[2][0]; m[2][1] = t->m[2][1]; m[2][2] = t->m[2][2];
}

- (void)extractRotationMatrix: (YAMatrix4f*) fourDimMatrix
{
    YAMatrix4f* t = [fourDimMatrix createTranspose];
    
    
    m[0][0] = t->m[0][0]; m[0][1] = t->m[0][1]; m[0][2] = t->m[0][2];
    m[1][0] = t->m[1][0]; m[1][1] = t->m[1][1]; m[1][2] = t->m[1][2];
    m[2][0] = t->m[2][0]; m[2][1] = t->m[2][1]; m[2][2] = t->m[2][2];

}

- (void) normalize
{
    YAVector3f* cX = [[YAVector3f alloc] initVals: m[0][0] :m[0][1] :m[0][2]];
    YAVector3f* cY = [[YAVector3f alloc] initVals: m[1][0] :m[1][1] :m[1][2]];
    YAVector3f* cZ = [[YAVector3f alloc] initVals: m[2][0] :m[2][1] :m[2][2]];
    
    [cX normalize];
    [cY normalize];
    [cZ normalize];

    m[0][0] = [cX x]; m[0][1] = [cX y]; m[0][2] = [cX z];
    m[1][0] = [cY z]; m[1][1] = [cY z]; m[1][2] = [cY z];
    m[2][0] = [cZ z]; m[2][1] = [cZ z]; m[2][2] = [cZ z];
    
}

- (YAVector3f*) mulVector3f: (const YAVector3f*) vector
{
    YAVector3f* result = [[YAVector3f alloc] init];
    result.x = m[0][0]* vector.x + m[0][1]* vector.y + m[0][2]* vector.z;
    result.y = m[1][0]* vector.x + m[1][1]* vector.y + m[1][2]* vector.z;
    result.z = m[2][0]* vector.x + m[2][1]* vector.y + m[2][2]* vector.z;
    return result;
}

@end
