//
//  YATriangleModel.h
//  YAWorld
//
//  Created by Yousry Abdallah on 04.02.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YAModel.h"
@class YAShader, YATexture;

@interface YATriangleModel : YAModel

- (id) initTriangles: (NSData*) vertexBuffer  shader: (YAShader*) shader texture: (YATexture*) texture; 

-(bool) updateVBO: (NSData*) vertexBuffer;



@end
