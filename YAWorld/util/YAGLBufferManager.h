//
//  YAGLBufferManager.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 26.10.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NSMutableData, NSArray;


/*
 * each BufferManager is responsible for exact one VBO an doptional IBO
 * indexing and streaming takes place in thos class
 * it is thereby cascaded by th YAModel class.
*/ 
@interface YAGLBufferManager : NSObject {
    NSArray* models;
    NSMutableData *vbos, *ibos;
}

@end
