//
//  YAVertex.h
//  YAWorld
//
//  Created by Yousry Abdallah on 11.02.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YAVector3f;

@interface YAVertex : NSObject
@property (strong, readwrite) YAVector3f* coordinate;
@property (strong, readwrite) YAVector3f* normal;

-(void) copyVertex: (YAVertex*) other;
-(void) copyVertexRefNormal: (YAVertex*) other;



@end
