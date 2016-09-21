//
//  YAText2D.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 03.12.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YAShader, YATexture;

@interface YAText2D : NSObject {
@private
    NSMutableData* vbos;
}

@property (strong, readwrite) NSMutableData* vbos;


/**
 * Initialize the text2s setting once. It is possible to share vbo and vbs
 **/
+ (void) setupText: (YATexture*) texture;
- (id) initText: (NSString*) text;
- (void) setText: (NSString*) text;

@end
