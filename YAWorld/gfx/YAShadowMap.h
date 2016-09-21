//
//  YAShadowMap.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 28.11.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YAShader;

@interface YAShadowMap : NSObject {
@private    
    GLuint shadowTextureId;
    GLuint fbo;
    
    int width;
    int height;
}

- (id) initResolution: (int) pixel;

@property (readonly) int width;
@property (readonly) int height;

- (bool) setupWrite;
- (bool) bind: (YAShader*) shader;

@end
