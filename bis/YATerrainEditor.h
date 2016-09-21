//
//  YATerrainEditor.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 03.09.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YARenderLoop, YATerrain;

@interface YATerrainEditor : NSObject

+ (void) setupTerrainEditor: (YARenderLoop*) world Terrain: (YATerrain*) terrain Seed: (float) sd;

@end
