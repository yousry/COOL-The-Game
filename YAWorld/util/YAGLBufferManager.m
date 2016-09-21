//
//  YAGLBufferManager.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 26.10.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import "YAGLBufferManager.h"

@implementation YAGLBufferManager


- (id)init
{
    self = [super init];
    if (self) {
        models = nil;
        vbos = nil;
        ibos = nil;
    }
    
    return self;
}

@end
