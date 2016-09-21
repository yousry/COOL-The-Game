//
//  YATextureArray.h
//  YAWorld
//
//  Created by Yousry Abdallah on 31.07.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YATexture.h"

@interface YATextureArray : YATexture {
@protected
    NSMutableArray* _imageNames;
}

- (id) initWithFilenames: (NSArray*) fileNames;

@end
