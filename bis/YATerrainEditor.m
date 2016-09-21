//
//  YATerrainEditor.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 03.09.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YABlockAnimator.h"
#import "YATerrain.h"
#import "YARenderLoop.h"

#import "YATerrainEditor.h"

@implementation YATerrainEditor

+ (void) setupTerrainEditor: (YARenderLoop*) world Terrain: (YATerrain*) terrain Seed: (float) sd
{
    
    __block float seed = sd;
    YABlockAnimator* terrainEditor = [world createBlockAnimator];
    [terrainEditor addListener:^(float sp, NSNumber *event, int message) {
        
        bool pDisp = false;
        
        switch (event.intValue) {
            case KEY_Q:
                pDisp = true;
                seed += 0.01;
                [terrain generate:seed];
                [world createHeightmapTexture:terrain withName:@"terrainHeightMap"];
                break;
            case KEY_W:
                pDisp = true;
                [terrain setTDisplacement:terrain.tDisplacement + 1];
                [terrain generate:seed];
                [world createHeightmapTexture:terrain withName:@"terrainHeightMap"];
                break;
            case KEY_E:
                pDisp = true;
                [terrain setTAmplitude:terrain.tAmplitude + 1.5f];
                [terrain generate:seed];
                [world createHeightmapTexture:terrain withName:@"terrainHeightMap"];
                break;
            case KEY_R:
                pDisp = true;
                [terrain setTFrequency: terrain.tFrequency + 0.0001f];
                [terrain generate:seed];
                [world createHeightmapTexture:terrain withName:@"terrainHeightMap"];
                break;
            case KEY_T:
                pDisp = true;
                [terrain setTGain: terrain.tGain + 0.01f];
                [terrain generate:seed];
                [world createHeightmapTexture:terrain withName:@"terrainHeightMap"];
                break;
            case KEY_Z:
                pDisp = true;
                [terrain setTLacunarity: terrain.tLacunarity + 0.005f];
                [terrain generate:seed];
                [world createHeightmapTexture:terrain withName:@"terrainHeightMap"];
                break;
            case KEY_U:
                pDisp = true;
                [terrain setTOctaves: terrain.tOctaves + 1];
                [terrain generate:seed];
                [world createHeightmapTexture:terrain withName:@"terrainHeightMap"];
                break;
            case KEY_I:
                pDisp = true;
                [terrain setTTileBorder: terrain.tTileBorder + 1];
                [terrain generate:seed];
                [world createHeightmapTexture:terrain withName:@"terrainHeightMap"];
                break;
            case KEY_A:
                pDisp = true;
                seed -= 0.01;
                [terrain generate:seed];
                [world createHeightmapTexture:terrain withName:@"terrainHeightMap"];
                break;
            case KEY_S:
                pDisp = true;
                [terrain setTDisplacement:terrain.tDisplacement - 0.1f];
                [terrain generate:seed];
                [world createHeightmapTexture:terrain withName:@"terrainHeightMap"];
                break;
            case KEY_D:
                pDisp = true;
                [terrain setTAmplitude:terrain.tAmplitude - 1.5f];
                [terrain generate:seed];
                [world createHeightmapTexture:terrain withName:@"terrainHeightMap"];
                break;
            case KEY_F:
                pDisp = true;
                [terrain setTFrequency: terrain.tFrequency - 0.0001f];
                [terrain generate:seed];
                [world createHeightmapTexture:terrain withName:@"terrainHeightMap"];
                break;
            case KEY_G:
                pDisp = true;
                [terrain setTGain: terrain.tGain - 0.01f];
                [terrain generate:seed];
                [world createHeightmapTexture:terrain withName:@"terrainHeightMap"];
                break;
            case KEY_H:
                pDisp = true;
                [terrain setTLacunarity: terrain.tLacunarity - 0.005f];
                [terrain generate:seed];
                [world createHeightmapTexture:terrain withName:@"terrainHeightMap"];
                break;
            case KEY_J:
                pDisp = true;
                [terrain setTOctaves: terrain.tOctaves - 1];
                [terrain generate:seed];
                [world createHeightmapTexture:terrain withName:@"terrainHeightMap"];
                break;
            case KEY_K:
                pDisp = true;
                [terrain setTTileBorder: terrain.tTileBorder - 1];
                [terrain generate:seed];
                [world createHeightmapTexture:terrain withName:@"terrainHeightMap"];
                break;
            default:
                break;
        }
        
        
        if(pDisp) {
            // NSLog(@"(q)seed: %f", seed);
            // NSLog(@"(w)displacement: %d", terrain.tDisplacement );
            // NSLog(@"(e)amplitude: %f", terrain.tAmplitude);
            // NSLog(@"(r)frequency: %f", terrain.tFrequency);
            // NSLog(@"(t)gain: %f", terrain.tGain );
            // NSLog(@"(z)lactunarity: %f", terrain.tLacunarity);
            // NSLog(@"(u)octaves: %d", terrain.tOctaves);
            // NSLog(@"(i)tileborder: %d", terrain.tTileBorder);
        }
        
    }];
    

}


@end
