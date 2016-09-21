//
//  YAHeightMap.h
//  YAWorld
//
//  Created by Yousry Abdallah on 14.05.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YAHeightMap <NSObject>

@property (readonly) int terrainDimension;
- (float) heightAt :(int) x :(int) y; 

@end
