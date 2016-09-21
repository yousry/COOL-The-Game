//
//  YAGridModel.h
//  YAWorld
//
//  Created by Yousry Abdallah on 14.05.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YAModel.h"
@class YAShader, YATexture, YATextureArray;

@interface YAGridModel : YAModel {
    YATextureArray* _textureArray;
}

- (id) initTriangles: (NSData*) vertexBuffer  shader: (YAShader*) shader textures: (YATextureArray*) textureArray normal: (YATexture*) normal;

@end
