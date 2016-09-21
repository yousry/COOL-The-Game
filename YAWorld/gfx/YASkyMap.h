//
//  YASkyMap.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 23.11.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YAShader;


@interface YASkyMap : NSObject {
@private
    GLuint texId[3]; // 0 = bg, 1 = diffuse, 2 = spec
    
    NSArray* orientations;
    NSString* name;
    
    GLuint vaoId;
    GLuint vboId;
    
    YAShader* _shader;
}

- (id) initResource: (NSString*) skyMapName shader: (YAShader*) shader;


- (bool)load;
- (bool) setupBuffer;
- (void) bind: (YAShader*) shader;
- (void) draw;
- (void) destroy;


@end
