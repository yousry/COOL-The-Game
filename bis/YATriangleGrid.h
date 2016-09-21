//
//  YATriangleGrid.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 14.05.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YATerrain;

@interface YATriangleGrid : NSObject {
@private
    int gridDimension;
    float gridTileSize;
}

- (id) initWithDim: (int) dimension;

- (NSMutableData*) triangles: (YATerrain*) terrain;

@end
