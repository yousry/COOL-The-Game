//
//  YATextModel.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 06.12.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import "YAModel.h"

@interface YATextModel : YAModel {
    
}

- (id)initTrianglesWithShader: (YATexture*) texture vertexBuffer:(NSData*) vertexBuffer shader: (YAShader*) shader;

@end
