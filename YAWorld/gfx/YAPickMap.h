//
//  YAPickMap.h
//  YAWorld
//
//  Created by Yousry Abdallah on 18.06.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YAShader;

@interface YAPickMap : NSObject {
@private    
    GLuint colorTextureId;
    GLuint shadowTextureId;
    GLuint fbo;
    
    int width;
    int height;
}

@property (readonly) int width;
@property (readonly) int height;

- (bool) setupWrite;
- (bool) bind: (YAShader*) shader; // unused. I only use...

- (int) getImpAtX: (int) x Y: (int) Y; 

@end
