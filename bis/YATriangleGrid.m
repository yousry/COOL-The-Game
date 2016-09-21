//
//  YATriangleGrid.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 14.05.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <math.h>
#import "YALog.h"
#import "YAVector3f.h"
#import "YATriangleGrid.h"
#import "YATerrain.h"

@implementation YATriangleGrid

static const NSString *TAG = @"YATriangleGrid";

// problem with texture mapping from 0 to 1 because 1 == 0
static const float gridSize = 1.95f;

- (id) initWithDim: (int) dimension
{
    self = [super init];
    if (self) {
        gridDimension = dimension;   
        gridTileSize = gridSize / (float)gridDimension;
    }
    
    return self;  
}



/* grid layout
 C-----D
 |     |
 |     |
 A-----B
 
 uvs
 u = floor
 v = fract
 
*/

// create grid triangles in x/z plane -gridsize/2 .. gridSize/2
- (NSMutableData*) triangles: (YATerrain*) terrain;
{
    [YALog debug:TAG message:@"triangles" ];
    
    
    NSMutableData* triangles = [[NSMutableData alloc] init]; 
    
    // iterate over grids
    for(int x = 0; x < gridDimension; x++)
        for(int z = 0; z < gridDimension; z++) {

            float heightA = [terrain heightAt:x     :z];
            float heightB = [terrain heightAt:x + 1 :z];
            float heightC = [terrain heightAt:x     :z + 1];
            float heightD = [terrain heightAt:x + 1 :z + 1];
            
            float abHdiff = heightA > heightB ? heightA - heightB : heightB - heightA;
            float acHdiff = heightA > heightC ? heightA - heightC : heightC - heightA;

            float dcHdiff = heightD > heightC ? heightD - heightC : heightC - heightD;
            float dbHdiff = heightD > heightB ? heightD - heightB : heightB - heightD;

            double pyDiff = 15;
            
            abHdiff = round( abHdiff / pyDiff);
            acHdiff = round( acHdiff / pyDiff);

            dcHdiff = round( dcHdiff / pyDiff);
            dbHdiff = round( dbHdiff / pyDiff);
            
            abHdiff = abHdiff < 1 ? 1 : abHdiff;
            acHdiff = acHdiff < 1 ? 1 : acHdiff;

            abHdiff = abHdiff > 9 ? 9 : abHdiff;
            acHdiff = acHdiff > 9 ? 9 : acHdiff;

            
            dcHdiff = dcHdiff < 1 ? 1 : dcHdiff;
            dbHdiff = dbHdiff < 1 ? 1 : dbHdiff;
            
            dcHdiff = dcHdiff > 9 ? 9 : dcHdiff;
            dbHdiff = dbHdiff > 9 ? 9 : dbHdiff;
            
            YAVector3f* gridPointA = [[YAVector3f alloc] initVals: x * gridTileSize :0 :z * gridTileSize];
            
            // recenter
            [gridPointA setX:[gridPointA x] - gridSize/2];
            [gridPointA setZ:[gridPointA z] - gridSize/2];

            const float uOff = 1000;
            const float vOff =    1;
            
            // adding uv
            float pA[3] = {gridPointA.x, gridPointA.z, x * uOff + z * vOff};
            
            YAVector3f* gridPointB = [[YAVector3f alloc] initCopy:gridPointA];
            [gridPointB setX:[gridPointA x] + gridTileSize];
            float pB[3] = {gridPointB.x, gridPointB.z, (x + abHdiff) * uOff + z * vOff };

            YAVector3f* gridPointC = [[YAVector3f alloc] initCopy:gridPointA];
            [gridPointC setZ:[gridPointA z] + gridTileSize];
            float pC[3] = {gridPointC.x, gridPointC.z, x * uOff + (z + acHdiff) * vOff};

            YAVector3f* gridPointD = [[YAVector3f alloc] initCopy:gridPointC];
            [gridPointD setX:[gridPointA x] + gridTileSize];
            float pD[3] = {gridPointD.x, gridPointD.z,  (x + dcHdiff) * uOff + (z + dbHdiff) * vOff};
            
            // triangle A (ABC)
            [triangles appendBytes:pA length: 3 * sizeof(float)];
            [triangles appendBytes:pC length: 3 * sizeof(float)];
            [triangles appendBytes:pB length: 3 * sizeof(float)];

            // triangle B (BDC)
            [triangles appendBytes:pB length: 3 * sizeof(float)];
            [triangles appendBytes:pC length: 3 * sizeof(float)];
            [triangles appendBytes:pD length: 3 * sizeof(float)];
        }
    
    return triangles;
}


@end
