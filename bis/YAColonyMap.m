//
//  YAColonyMap.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 03.05.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YAProbability.h"
#import "YAAvatar.h"
#import "YADromedarMover.h"
#import "YAShopAssembler.h"
#import "YAImpGroup.h"
#import "YARenderLoop.h"
#import "YABlockAnimator.h"
#import "YATerrain.h"
#import "YAImpersonator.h"
#import "YAVector3f.h"
#import "YAVector2i.h"
#import "YAMaterial.h"
#import "YASceneUtils.h"
#import "YAGameContext.h"

#import "YAColonyMap.h"

#define MAP_WIDTH 7
#define MAP_HEIGHT 7
#define cCoords(x, z) (x + MAP_WIDTH * z)


@implementation YAColonyMap
@synthesize world, terrain, terrainImp, sceneUtils, gameContext, shopGroup;

- (id) init
{
    self = super.init;
    
    if(self) {
        
        freePlots = MAP_WIDTH * MAP_HEIGHT;
        
        colMap = [[NSMutableArray alloc] init];
        
        
        // create crystalite herds (classical)
        NSArray* crystalideHerds = [NSArray arrayWithObjects:
                                    [[YAVector2i alloc] initVals:roundf([YAProbability random] * 6.0f) :roundf([YAProbability random] * 6.0f)] ,
                                    [[YAVector2i alloc] initVals:roundf([YAProbability random] * 6.0f) :roundf([YAProbability random] * 6.0f)] ,
                                    [[YAVector2i alloc] initVals:roundf([YAProbability random] * 6.0f) :roundf([YAProbability random] * 6.0f)] ,
                                    [[YAVector2i alloc] initVals:roundf([YAProbability random] * 6.0f) :roundf([YAProbability random] * 6.0f)] ,
                                    nil];

        
        
        for(int plot = 0; plot < MAP_WIDTH * MAP_HEIGHT; plot++) {
            
            // calculate Vorkommen
            const int z = plot / MAP_WIDTH;
            const int x = plot - z * MAP_WIDTH;
            
            float minDist = 100;
            for(YAVector2i* herd in crystalideHerds) {
                float dist = [herd distanceTo:[[YAVector2i alloc] initVals:z :x]];
                if(dist < minDist)
                    minDist = dist;
            }
            
            float sample = (3 - minDist) / 3;
            if(sample < 0)
                sample = 0;

            
            NSMutableDictionary* plotData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                             [NSNumber numberWithInt:PLAYER_VACANT], @"OWNER",
                                             [NSNumber numberWithInt:HOUSE_NONE], @"HOUSE",
                                             [NSNumber numberWithFloat:sample], @"CRYSTALITE",
//                                             [NSNumber numberWithFloat:[YAProbability sinPowProb:[YAProbability random]]], @"CRYSTALITE",
                                             @NO, @"SAMPLESAVALABLE",
                                             nil];
            [colMap addObject:plotData];
        }
        

        

        
        
        
        houseIngredients = [[NSArray alloc] initWithObjects: @"SolarplantTile", @"SmithoreTile", @"FarmhouseTile", @"CrystaliteTile", @"Store", nil ];
    }
    
    return self;
}



// only x and z are used
- (YAVector3f*) calcWorldPosX: (int) x Z: (int) z
{
    YAVector3f* result = [[YAVector3f alloc] init];
    
    // calculate the position
    double totalGrids = terrain.terrainDimension;
    
    double multiplier = 0;
    if(totalGrids == 33.0)
        multiplier = 2.012;
    else if(totalGrids == 65)
        multiplier = 1.9840;
    else if(totalGrids == 129)
        multiplier = 1.97;
    else if(totalGrids == 257)
        multiplier = 1.97;
    else 
        multiplier = 1.972;

    double gridLength = (terrainImp.size.z * multiplier) / totalGrids;
    
    double borderGrids = terrain.brdSize;
    
    double boardOffst = -terrainImp.size.z;
    double offsetCorrection = 0.142;


    result.x = (boardOffst + offsetCorrection) + gridLength * borderGrids;
    result.z = (boardOffst + offsetCorrection) + gridLength * borderGrids;
    
    result.x += (terrain.fieldWidth * gridLength * x);
    result.z += (terrain.fieldHeight * gridLength * z);
    
    if(totalGrids >= 129) {
        
        double fufuMagic = totalGrids / 129.0f;
        
        if(x <= 1)
            result.x -= gridLength * fufuMagic;
        if(z <= 1)
            result.z -= gridLength * fufuMagic;
        if(x == 6)
            result.x += gridLength * fufuMagic;
        if(z == 6)
            result.z += gridLength * fufuMagic;

    }

    result.x += ((terrain.fieldWidth  * gridLength)/ 2.0f);
    result.z += ((terrain.fieldHeight * gridLength)/ 2.0f);

    return result;
}

- (void) createMountainX: (int) x Z: (int) z
{
    [terrain createMountain:x :z];
    [world createHeightmapTexture:terrain withName:@"terrainHeightMap"];
}



- (void) setClaim: (plot_owner) owner  X: (int) x Z: (int) z At: (float) myTime
{
    assert(x >= 0 && x <= 6);
    assert(z >= 0 && z <= 6);
    
    __block NSMutableDictionary* plotData = [colMap objectAtIndex:cCoords(x, z)];
    [plotData setObject:[NSNumber numberWithInt:owner] forKey:@"OWNER"];
    
    YABlockAnimator* anim = [world createBlockAnimator];
    [anim setDelay:myTime];
    [anim setOneExecution:true];
    
    [anim addListener:^(float sp, NSNumber *event, int message) {
        
        const float tileSize = 0.08f;
        const float fallDist = 2.3f;
        const float fallTime = 0.1f;

        float height = [terrain flattenField:x :z];
        [world createHeightmapTexture:terrain withName:@"terrainHeightMap"];
        
        // i limit the depth to -1 in the shader
        if(height < -1.0)
            height = -1.0;
        
        [plotData setObject:[NSNumber numberWithFloat:height ] forKey:@"HEIGHT"];
        
        height = (height / 255) * terrainImp.normalMapFactor * terrainImp.size.y + 0.01 + fallDist;
        
        int impId = [world createImpersonator:@"tileSocket"];
        YAImpersonator* imp = [world getImpersonator:impId];
        [[imp translation] setY:height];
        
        [plotData setObject:imp forKey:@"SOCKET_IMP"];
        
        if(owner == PLAYER_STORE)
            [[[imp material] phongAmbientReflectivity] setVector: sceneUtils.color_grey_white];
        else
            [[[imp material] phongAmbientReflectivity] setVector: [[gameContext colorVectors] objectAtIndex:[gameContext getColorForPlayer:owner]]];

        [[[imp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
        [[[imp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
        imp.material.eta = 0.75;
        [[imp material] setPhongShininess: 50.0f];

        [[imp translation] setVector:[self calcWorldPosX:x Z:z]];
        [[imp translation] setY:height];
        
        [[imp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
        [imp resize:tileSize];
        
        YABasicAnimator* fallDown;
        fallDown = [world createBasicAnimator];
        [fallDown setOnce:true];
        [fallDown setOnceReset:false];
        [fallDown setProgress:damp];
        [fallDown setInterval:fallTime];
        [fallDown setInfluence:Y_AXE];
        [fallDown addListener:[imp translation] factor:-fallDist];
    }];
    
    --freePlots;

}


- (void) resetFabs
{
    for(int x = 0; x <= 6; x++) {
        for(int z = 0; z <= 6; z++ ) {
            YAImpersonator* houseImp = [self getHouseAtX:x Z:z];
            house_type house = [self plotHouseAtX:x Z:z];
            
            if(house == HOUSE_CRYSTALYTE) {
                [[houseImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
                [houseImp resize:0.35];
            } else if( house == HOUSE_ENERGY) {
                [[houseImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
                [houseImp resize:0.08];
            } else if( house == HOUSE_FARM) {
                [[houseImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
                [houseImp resize:0.08];
            } else if( house == HOUSE_SMITHORE) {
                [[houseImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
                [houseImp resize:0.2];
            }
        }
    }
}


// simplified building generation event for bots
- (void) setFab: (house_type) house X: (int) x Z: (int) z At: (float) delay;
{
    // NSLog(@"Set Fab");
    assert(x >= 0 && x <= 6);
    assert(z >= 0 && z <= 6);
    
    YABlockAnimator* anim = [world createBlockAnimator];
    anim.oneExecution = YES;
    anim.delay = delay;
    [anim addListener:^(float sp, NSNumber *event, int message) {
        NSMutableDictionary* plotData = [colMap objectAtIndex:cCoords(x, z)];
        [plotData setObject:[NSNumber numberWithInt:house] forKey:@"HOUSE"];
        
        YAVector3f* position = [self getSocketImpAtX:x Z:z].translation;
        float heightMultiplier = [self getSocketImpAtX:x Z:z].size.x;
        float height = [self worldHeightX:x Z:z];
        
        int houseImpId = [world createImpersonator:[houseIngredients objectAtIndex:house]];
        YAImpersonator* houseImp = [world getImpersonator:houseImpId];
        houseImp.visible = NO;
        
        float houseSize = 0.08;
        if(house == HOUSE_SMITHORE)
            houseSize = 0.2;
        else if (house == HOUSE_CRYSTALYTE)
            houseSize = 0.35;
        
        [[houseImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
        [houseImp resize:houseSize];
        [[[houseImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4 : 0.5 : 0.5 ]];
        [[[houseImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
        [[[houseImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.1f : 0.1f : 0.1f ]];
        [[houseImp material] setPhongShininess: 200];
        
        if(house == HOUSE_CRYSTALYTE) {
            [houseImp setBackfaceCulling:false];
            [[[houseImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 1.0f : 1.0f : 1.0f ]];
            [[houseImp material] setPhongShininess: 10];
        }
        
        [[houseImp translation] setY:height + (heightMultiplier * 0.5)];
        [[houseImp translation] setX:position.x];
        [[houseImp translation] setZ:position.z];
        [plotData setObject:houseImp forKey:@"HOUSE_IMP"];
        
        [sceneUtils showImp:houseImp atTime:0];
        
    }];
}

// build house replacement
- (void) buildFab: (house_type) house X: (int) x Z: (int) z Pod: (YAImpersonator*) podImp
{
    // NSLog(@"Build Fab");
    assert(x >= 0 && x <= 6);
    assert(z >= 0 && z <= 6);
    
    __block NSMutableDictionary* plotData = [colMap objectAtIndex:cCoords(x, z)];
    [plotData setObject:[NSNumber numberWithInt:house] forKey:@"HOUSE"];
    
    YAVector3f* position = [self getSocketImpAtX:x Z:z].translation;
    float heightMultiplier = [self getSocketImpAtX:x Z:z].size.x;
    
    float height = [self worldHeightX:x Z:z];
    
    int houseImpId = [world createImpersonator:[houseIngredients objectAtIndex:house]];
    __block YAImpersonator* houseImp = [world getImpersonator:houseImpId];
    
    float houseSize = 0.08;
    if(house == HOUSE_SMITHORE)
        houseSize = 0.2;
    else if (house == HOUSE_CRYSTALYTE)
        houseSize = 0.35;

    const float dromedarSize = 0.04;
    
    [[houseImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
    [houseImp resize:houseSize];
    [[[houseImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4 : 0.5 : 0.5 ]];
    [[[houseImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[houseImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.1f : 0.1f : 0.1f ]];
    [[houseImp material] setPhongShininess: 200];
    [[houseImp translation] setY:height + (heightMultiplier * 0.5)];
    [[houseImp translation] setX:position.x];
    [[houseImp translation] setZ:position.z];
    houseImp.visible = NO;
    
    YAImpersonator* oldHouse = [plotData objectForKey:@"HOUSE_IMP"];
    if(oldHouse != nil)
        [sceneUtils removeImp:oldHouse atTime:0];
    
    [plotData setObject:houseImp forKey:@"HOUSE_IMP"];
    
    int dromedarId = [world createImpersonatorWithShapeShifter: @"Dromedar"];

    YAImpersonator* dromedarImp = [world getImpersonator:dromedarId];
    [dromedarImp resize:dromedarSize];
    [[[dromedarImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[dromedarImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[dromedarImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[dromedarImp material] setPhongShininess: 20];
    [[dromedarImp translation] setVector:position];
    dromedarImp.translation.y += (heightMultiplier * 0.6);
    dromedarImp.translation.x -= (heightMultiplier * 4);
    [[dromedarImp rotation] setValues:-90 :0 :0];
    __block YADromedarMover* dm = [[YADromedarMover alloc] initWithImp:dromedarImp inWorld:world];
    
    [dm setActive:walk];

    const float animTime = 5.0f;
    
    __block float podHeight = podImp.translation.y;
    YABlockAnimator* anim = [world createBlockAnimator];
    __weak YABlockAnimator* _anim = anim;
    
    [anim setOnce:YES];
    [anim setInterval:animTime];
    [anim setProgress:damp];
    [anim setAsyncProcessing:NO];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        houseImp.visible = YES;
        const float cycles = 15;
        houseImp.rotation.y = 360 * cycles * (1 - sp);
        podImp.rotation.y = 360 * 5 * (1 - sp);
        podImp.translation.y = podHeight - 0.32 * sp;
        if(_anim.deleteme) {
            [dm setActive:parade];
        }
    }];
    
    anim = [world createBlockAnimator];
    [anim setOnce:YES];
    [anim setProgress:accelerate];
    [anim setInterval:animTime];
    [anim setAsyncProcessing:NO];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        const float cycles = 15;
        YAVector3f* dromedarPos = [[YAVector3f alloc] initVals:-(heightMultiplier*4) - sp / 2 :(heightMultiplier * 0.3) + sp / 2 :0];
        [dromedarPos rotate:cycles * 360 * (1  - sp) axis:[[YAVector3f alloc] initYAxe]];
        [dromedarPos addVector:position];
        
        dromedarImp.rotation.x = -90;
        dromedarImp.rotation.y = cycles * 360 * sp;
        dromedarImp.rotation.z = 0;
        [[dromedarImp translation] setVector:dromedarPos];

        [[[dromedarImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 + sp : 0.7 - sp : 0.7 - sp ]];
        [[[dromedarImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f + sp : 0.4f - sp : 0.4f - sp ]];
        [[[dromedarImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f + sp : 0.4f - sp : 0.4f - sp ]];
        dromedarImp.material.specIntensity = sp;
        dromedarImp.material.specPower = sp;
        
        
        [dromedarImp resize:dromedarSize * (1-sp / 2)];
        [houseImp resize:houseSize * sp];

        if(_anim.deleteme) {
            [dm setActive:none];
            [dm reset];
            [dm cleanup];
            dm = nil;
            [world removeImpersonator:dromedarId];
            [podImp setVisible:NO];
            houseImp.rotation.y = 0;
            [houseImp resize:houseSize];
        }
        
        
    }];
}


- (void) buidlHouse: (house_type) house forPlayer: (plot_owner) owner  X: (int) x Z: (int) z At: (float) myTime
{
    
    assert(x >= 0 && x <= 6);
    assert(z >= 0 && z <= 6);
    
    __block NSMutableDictionary* plotData = [colMap objectAtIndex:cCoords(x, z)];
    [plotData setObject:[NSNumber numberWithInt:owner] forKey:@"OWNER"];
    [plotData setObject:[NSNumber numberWithInt:house] forKey:@"HOUSE"];

    YABlockAnimator* anim = [world createBlockAnimator];
    [anim setDelay:myTime];
    [anim setOneExecution:true];
    
    [anim addListener:^(float sp, NSNumber *event, int message) {
        
        const float tileSize = 0.08f;

        const float fallDist = 10.0f;
        
        const float fallTime = 0.1f;
        
        const float fallTimeHouse = 0.2f;
        
        const float houseDelay = 0.1f;
       
        
        float houseSize = 0.3;
        if(house == 0)
            houseSize = 0.09;
        else if (house == 1)
            houseSize = 0.2;
        else if (house == 2)
            houseSize = 0.08;
        
        float height = [terrain flattenField:x :z];
        [world createHeightmapTexture:terrain withName:@"terrainHeightMap"];
        
        // i limit the depth to -1 in the shader
        if(height < -1.0)
            height = -1.0;

        [plotData setObject:[NSNumber numberWithFloat:height ] forKey:@"HEIGHT"];
        
        
        height = (height / 255) * terrainImp.normalMapFactor * terrainImp.size.y + 0.001 + fallDist;
        
        int impId;
        YAImpersonator* imp;
        YABasicAnimator* fallDown;
        
        if(house != HOUSE_STORE) {
            impId = [world createImpersonator:@"tileSocket"];
            imp = [world getImpersonator:impId];
            
            [plotData setObject:imp forKey:@"SOCKET_IMP"];
            
            
            [[imp translation] setY:height];
            
            if(owner == PLAYER_STORE)
                [[[imp material] phongAmbientReflectivity] setVector: sceneUtils.color_grey_white];
            else
                [[[imp material] phongAmbientReflectivity] setVector: [[gameContext colorVectors] objectAtIndex:[gameContext getColorForPlayer:owner]]];
            
            [[[imp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
            [[[imp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
            [[imp material] setPhongShininess: 10.0f];
            
            [[imp translation] setVector:[self calcWorldPosX:x Z:z]];
            [[imp translation] setY:height];
            
            [[imp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
            [imp resize:tileSize];
            
            fallDown = [world createBasicAnimator];
            [fallDown setOnce:true];
            [fallDown setOnceReset:false];
            [fallDown setProgress:damp];
            [fallDown setInterval:fallTime];
            [fallDown setInfluence:Y_AXE];
            [fallDown setAsyncProcessing:NO];
            [fallDown addListener:[imp translation] factor:-fallDist];
        }
            
        
        if(house == HOUSE_NONE)
            return; // to avoid nesting
        
        if(house != HOUSE_STORE)
        {
           int impId = [world createImpersonator:[houseIngredients objectAtIndex:house]];
           imp = [world getImpersonator:impId];
           imp.visible = NO;

            [plotData setObject:imp forKey:@"HOUSE_IMP"];
 
            
            [[imp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
            
            [imp resize:houseSize];

            [[[imp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4 : 0.5 : 0.5 ]];
            [[[imp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
            [[[imp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.1f : 0.1f : 0.1f ]];
            [[imp material] setPhongShininess: 200];
            
            [[imp translation] setVector:[self calcWorldPosX:x Z:z]];
            [[imp translation] setY:height];

            [sceneUtils showImp:imp atTime:houseDelay];
            fallDown = [world createBasicAnimator];
            [fallDown setOnce:true];
            [fallDown setOnceReset:false];
            [fallDown setProgress:damp];
            [fallDown setInterval:fallTimeHouse];
            [fallDown setDelay:houseDelay];
            [fallDown setInfluence:Y_AXE];
            [fallDown setAsyncProcessing:NO];
            [fallDown addListener:[imp translation] factor:-fallDist];
        } else { // store (shop group)
         
            shopGroup = [[YAImpGroup alloc] init];
            [YAShopAssembler buildShop:world SceneUtils:sceneUtils Group:shopGroup];
            
            [shopGroup setVisible:false];
            [shopGroup setState:@"withoutPod"];
            
            YAVector3f* shopPosition = [self calcWorldPosX:x Z:z];
            
            [plotData setObject:shopGroup forKey:@"HOUSE_GROUP"];

            [sceneUtils showImp:(YAImpersonator*)shopGroup atTime:houseDelay];
            YABlockAnimator* fallDownShop = [world createBlockAnimator];
            [fallDownShop setOnce:true];
            [fallDownShop setOnceReset:false];
            [fallDownShop setProgress:damp];
            [fallDownShop setInterval:fallTimeHouse];
            [fallDownShop setDelay:houseDelay];
            [fallDownShop setAsyncProcessing:NO];
            [fallDownShop addListener:^(float sp, NSNumber *event, int message) {

                // [[shopGroup translation] setVector: [[YAVector3f alloc] initVals:shopPosition.x
                //                                                       :height - fallDist * sp
                //                                                       :shopPosition.z]];
                
                [shopGroup setTranslation:[[YAVector3f alloc] initVals:shopPosition.x
                                                                      :height - fallDist * sp
                                                                      :shopPosition.z]];
            }];
        }
    }];

    --freePlots;
}

- (float) heightX: (int) x Z: (int) z
{
    assert(x >= 0 && x <= 6);
    assert(z >= 0 && z <= 6);

    NSMutableDictionary* plotData = [colMap objectAtIndex:cCoords(x, z)];
    
    const float height = [[plotData objectForKey:@"HEIGHT"] intValue];
    
    return height;
}

- (float) worldHeightX: (int) x Z: (int) z
{
    float height = [self heightX:x Z:z];
    height = (height / 255) * terrainImp.normalMapFactor * terrainImp.size.y + 0.001;

    return height;
}


- (bool) plotSamplesX: (int) x Z: (int) z
{
    assert(x >= 0 && x <= 6);
    assert(z >= 0 && z <= 6);
    NSMutableDictionary* plotData = [colMap objectAtIndex:cCoords(x, z)];
    return [[plotData objectForKey:@"SAMPLESAVALABLE"] boolValue];
}


- (float) plotCrystaliteX: (int) x Z: (int) z
{
    assert(x >= 0 && x <= 6);
    assert(z >= 0 && z <= 6);
    NSMutableDictionary* plotData = [colMap objectAtIndex:cCoords(x, z)];
    [plotData setObject:@YES forKey:@"SAMPLESAVALABLE"]; // samples available can be used by bot in plot grants
    return [[plotData objectForKey:@"CRYSTALITE"] floatValue];
}


- (house_type) plotHouseAtX: (int) x Z: (int) z
{
    assert(x >= 0 && x <= 6);
    assert(z >= 0 && z <= 6);
    NSMutableDictionary* plotData = [colMap objectAtIndex:cCoords(x, z)];
    
    NSNumber* houseNumber = [plotData objectForKey:@"HOUSE"];
                            
    if(houseNumber == nil)
        return HOUSE_NONE;
    else
        return [houseNumber intValue];
}


- (plot_owner) plotOwnerAtX: (int) x Z: (int) z
{
    assert(x >= 0 && x <= 6);
    assert(z >= 0 && z <= 6);
    NSMutableDictionary* plotData = [colMap objectAtIndex:cCoords(x, z)];
    return [[plotData objectForKey:@"OWNER"] intValue];
}

- (void) highCrystitePlotAtX: (int) x Z: (int) z
{
    assert(x >= 0 && x <= 6);
    assert(z >= 0 && z <= 6);

    NSMutableDictionary* plotData = [colMap objectAtIndex:cCoords(x, z)];
    [plotData  setObject:[NSNumber numberWithFloat:1] forKey:@"CRYSTALITE"];
}


- (void) destroyPlotAtX: (int) x Z: (int) z
{
    assert(x >= 0 && x <= 6);
    assert(z >= 0 && z <= 6);
    
    // change owner to none
    NSMutableDictionary* plotData = [colMap objectAtIndex:cCoords(x, z)];
    [plotData  setObject:[NSNumber numberWithInt:PLAYER_VACANT] forKey:@"OWNER"];
    YAImpersonator* socketImp = [plotData objectForKey:@"SOCKET_IMP"];
    
    // remove socket
    [sceneUtils removeImp:socketImp atTime:0];
    [plotData removeObjectForKey:@"SOCKET_IMP"];

    
    // remove house logical
    [plotData  setObject:[NSNumber numberWithInt:HOUSE_NONE] forKey:@"HOUSE"];

    // remove house Imp
    YAImpersonator* destructHouse = [plotData objectForKey:@"HOUSE_IMP"];
    [sceneUtils removeImp:destructHouse atTime:0];
    [plotData removeObjectForKey:@"HOUSE_IMP"];
}


- (void) changePlotOwnerAtX: (int) x Z: (int) z Owner: (plot_owner) owner
{
    assert(x >= 0 && x <= 6);
    assert(z >= 0 && z <= 6);
    NSMutableDictionary* plotData = [colMap objectAtIndex:cCoords(x, z)];
    [plotData  setObject:[NSNumber numberWithInt:owner] forKey:@"OWNER"];
    YAImpersonator* socketImp = [plotData objectForKey:@"SOCKET_IMP"];
    YAVector3f* color = [gameContext.colorVectors objectAtIndex: [gameContext getColorForPlayer:owner]];
    [[[socketImp material] phongAmbientReflectivity] setVector:color];
}



- (int) vacantPlots
{
//    int result = 0;
//    for(NSDictionary* plot in colMap) {
//      if([[plot objectForKey:@"OWNER"] intValue] == PLAYER_VACANT)
//          result++;
//    }
    
    return freePlots;
}

- (YAVector2i*) randomVacantPlot
{
    
    NSMutableArray* plotsForAuction  = [[NSMutableArray alloc] init];

    
    for(int x = 0; x <= 6; x++)
        for(int z = 0; z <= 6; z++)
            if([self plotOwnerAtX:x Z:z] == PLAYER_VACANT)
                [plotsForAuction addObject:[[YAVector2i alloc] initVals:x :z]];
        


    return [YAProbability randomSelectArray:plotsForAuction];
}


- (YAImpersonator*) getSocketImpAtX: (int) xPos Z: (int) zPos
{
    assert(xPos >= 0 && xPos <= 6);
    assert(zPos >= 0 && zPos <= 6);
    NSMutableDictionary* plotData = [colMap objectAtIndex:cCoords(xPos, zPos)];
    return [plotData objectForKey:@"SOCKET_IMP"];
}

- (YAImpersonator*) getHouseAtX: (int) xPos Z: (int) zPos
{
    assert(xPos >= 0 && xPos <= 6);
    assert(zPos >= 0 && zPos <= 6);
    NSMutableDictionary* plotData = [colMap objectAtIndex:cCoords(xPos, zPos)];
    return [plotData objectForKey:@"HOUSE_IMP"];
    
}

- (YAImpGroup*) getHouseGroupAtX: (int) xPos Z: (int) zPos
{
    assert(xPos >= 0 && xPos <= 6);
    assert(zPos >= 0 && zPos <= 6);
    NSMutableDictionary* plotData = [colMap objectAtIndex:cCoords(xPos, zPos)];
    return [plotData objectForKey:@"HOUSE_GROUP"];
}


- (void) hideImps: (float) myTime
{
    YABlockAnimator* anim = [world createBlockAnimator];
    [anim setOneExecution:true];
    [anim setDelay:myTime];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        for(NSDictionary* plot in colMap) {
            YAImpersonator* imp = [plot objectForKey:@"SOCKET_IMP"];
            [sceneUtils hideImp:imp atTime:0];
            imp = [plot objectForKey:@"HOUSE_IMP"];
            [sceneUtils hideImp:imp atTime:0];

            YAImpGroup* group = [plot objectForKey:@"HOUSE_GROUP"];
            if(group != nil) {
                __block NSString* wp = @"withPod";
                [group setState:wp];
                [group setVisible:false];
                for(YAImpersonator* imp in group.allImps) 
                   imp.visible = false;     
            }

        }
    }];
}

- (void) showImps: (float) myTime
{
    YABlockAnimator* anim = [world createBlockAnimator];
    [anim setOneExecution:true];
    [anim setDelay:myTime];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        for(NSDictionary* plot in colMap) {
            YAImpersonator* imp = [plot objectForKey:@"SOCKET_IMP"];
            [sceneUtils showImp:imp atTime:0];
            imp = [plot objectForKey:@"HOUSE_IMP"];
            [sceneUtils showImp:imp atTime:0];
            __weak YAImpGroup* group = [plot objectForKey:@"HOUSE_GROUP"];
            [group setVisible:true];
            [group setState:group.state];
        }
    }];

}

- (YAVector2i*) getClaimIdAt: (YAVector3f*) position
{
    
    const int terrainField = 32;
    const float oneGrid = (terrainImp.size.x * 2) / (float) terrainField;

    float gridX = (position.x + terrainImp.size.x) / oneGrid;
    float gridZ = (position.z + terrainImp.size.y) / oneGrid;

    float borderSize = 2;
    float fieldSize = 4;
  
    gridX = gridX - borderSize;
    gridZ = gridZ - borderSize;
    
    gridX = gridX / fieldSize;
    gridZ = gridZ / fieldSize;
    
    int posX = gridX;
    int posZ = gridZ;
    
    if(gridX < 0 || gridX > 7)
        return nil;
    
    if(gridZ < 0 || gridZ > 7)
        return nil;
    
    return [[YAVector2i alloc] initVals:posX  :posZ];
}

- (YABlockAnimator*) blinkPlots: (int) plotOwner
{
 
    NSMutableArray* sockets = [[NSMutableArray alloc] init];
    
    for(int x = 0 ; x <= 6; x++)
        for(int z = 0; z <= 6; z++) {
            if ([self plotOwnerAtX:x Z:z] == plotOwner) {
                [sockets addObject:[self getSocketImpAtX:x Z:z]];
            }
        }

    if(sockets.count == 0)
        return nil;
    
    __block YAVector3f *restoreColor = [[YAVector3f alloc] initCopy:[[[sockets objectAtIndex:0] material] phongAmbientReflectivity]];

    YABlockAnimator* anim = [world createBlockAnimator];
    __weak YABlockAnimator* animW = anim;
    
    anim.asyncProcessing = NO;
    anim.progress = harmonic;
    anim.interval = 0.5f;
    
    [anim addListener:^(float sp, NSNumber *event, int message) {
        for(YAImpersonator* imp in sockets)
            [[[imp material] phongAmbientReflectivity] setValues:sp + 0.5 :sp + 0.5 :sp + 0.5];
        if (animW.deleteme) {
            for(YAImpersonator* imp in sockets)
                [[[imp material] phongAmbientReflectivity] setVector:restoreColor];
        }
    }];
    
    return anim;
}

- (int) sameNeighbour: (YAVector2i*) plot
{
    
    bool (^validPlot)(int, int) = ^(int x, int y) {
        bool result = true;
        
        if(x < 0 || x > 6)
            result = false;
        
        if(y < 0 || y > 6)
            result = false;

        return result;
    };

    int result = 0;

    const int xPos = plot.x;
    const int zPos = plot.y;
    
    house_type house = [self plotHouseAtX: xPos Z: zPos];

    int nxPos, nzPos;
    
    nxPos = xPos - 1; nzPos = zPos + 1;
    if(validPlot(nxPos, nzPos)   && [self plotHouseAtX: nxPos Z: nzPos] == house)
        result += 1;
    nxPos = xPos ; nzPos = zPos + 1;
    if(validPlot(nxPos, nzPos)   && [self plotHouseAtX: nxPos Z: nzPos] == house)
        result += 1;
    nxPos = xPos + 1; nzPos = zPos + 1;
    if(validPlot(nxPos, nzPos)   && [self plotHouseAtX: nxPos Z: nzPos] == house)
        result += 1;

    nxPos = xPos - 1; nzPos = zPos;
    if(validPlot(nxPos, nzPos)   && [self plotHouseAtX: nxPos Z: nzPos] == house)
        result += 1;
    nxPos = xPos + 1; nzPos = zPos;
    if(validPlot(nxPos, nzPos)   && [self plotHouseAtX: nxPos Z: nzPos] == house)
        result += 1;

    nxPos = xPos - 1; nzPos = zPos - 1;
    if(validPlot(nxPos, nzPos)   && [self plotHouseAtX: nxPos Z: nzPos] == house)
        result += 1;
    nxPos = xPos ; nzPos = zPos - 1;
    if(validPlot(nxPos, nzPos)   && [self plotHouseAtX: nxPos Z: nzPos] == house)
        result += 1;
    nxPos = xPos + 1; nzPos = zPos - 1;
    if(validPlot(nxPos, nzPos)   && [self plotHouseAtX: nxPos Z: nzPos] == house)
        result += 1;

    return result;
}

- (NSArray*) getAllPlots: (plot_owner) owner OfType: (house_type) house
{
    NSMutableArray* plots = [[NSMutableArray alloc] init];
    
    for(int x = 0 ; x <= 6; x++)
        for(int z = 0; z <= 6; z++) {
            if ([self plotOwnerAtX:x Z:z] == owner && [self plotHouseAtX:x Z:z] == house) {
                [plots addObject:[[YAVector2i alloc] initVals:x :z]];
            }
        }
    return [NSArray arrayWithArray:plots];
}

- (NSArray*) getAllPlots: (plot_owner) owner
{
    NSMutableArray* plots = [[NSMutableArray alloc] init];
    
    for(int x = 0 ; x <= 6; x++)
        for(int z = 0; z <= 6; z++) {
            if ([self plotOwnerAtX:x Z:z] == owner ) {
                [plots addObject:[[YAVector2i alloc] initVals:x :z]];
            }
        }
    return [NSArray arrayWithArray:plots];
}

- (NSArray*) getAllProduction
{
    NSMutableArray* plots = [[NSMutableArray alloc] init];
    
    for(int x = 0 ; x <= 6; x++) {
        for(int z = 0; z <= 6; z++) {
            house_type house = [self plotHouseAtX:x Z:z];
            if (house != HOUSE_NONE && house != HOUSE_STORE) {
                [plots addObject:[[YAVector2i alloc] initVals:x :z]];
            }
        }
    }
    
    return [NSArray arrayWithArray:plots];
}


- (NSArray*) getEmptyPlots: (plot_owner) owner
{
    NSMutableArray* plots = [[NSMutableArray alloc] init];
    
    for(int x = 0 ; x <= 6; x++)
        for(int z = 0; z <= 6; z++) {
            if ([self plotOwnerAtX:x Z:z] == owner && [self plotHouseAtX:x Z:z] == HOUSE_NONE) {
                [plots addObject:[[YAVector2i alloc] initVals:x :z]];
            }
        }

    return [NSArray arrayWithArray:plots];
}

- (void) enableLaserPointer: (bool) enabled
{
    if(enabled)
        terrainImp.material.specPower = 0.0f;
    else
        terrainImp.material.specPower = 1.0f;
}

- (void) laserPointerAtPlot: (float) x : (float) y
{
    float xPos = [YAProbability mapToProbRange:x  From:0 To:6];
    float yPos = [YAProbability mapToProbRange:y  From:0 To:6];
    
    const float range = 1.45;
    xPos *= range; xPos -= range * .5;
    yPos *= range; yPos -= range * .5;
    
    
    terrainImp.material.reflection = xPos;
    terrainImp.material.refraction = yPos;
}

- (void) clearProductivity
{
    for(int x = 0; x <= 6; x++) {
        for(int z = 0; z <= 6; z++) {
            NSMutableDictionary* plotData = [colMap objectAtIndex:cCoords(x, z)];
            [plotData removeObjectForKey:@"PRODUCTIVITY_PROBABILITY"];
            [plotData removeObjectForKey:@"PRODUCTION"];
        }
    }
}


- (void) setProductivityProbability: (YAVector2i*) plotPos Probability: (float) probability;
{
    NSMutableDictionary* plotData = [colMap objectAtIndex:cCoords(plotPos.x, plotPos.y)];
    [plotData setObject:[NSNumber numberWithFloat:probability] forKey:@"PRODUCTIVITY_PROBABILITY"];
}

- (float) productivityProbability: (YAVector2i*) plotPos
{
    NSMutableDictionary* plotData = [colMap objectAtIndex:cCoords(plotPos.x, plotPos.y)];
    return [[plotData objectForKey:@"PRODUCTIVITY_PROBABILITY"] floatValue];
}

- (void) changeProduction: (YAVector2i*) plotPos  Amount: (int) amount
{
    NSMutableDictionary* plotData = [colMap objectAtIndex:cCoords(plotPos.x, plotPos.y)];
    [plotData setObject:[NSNumber numberWithInt:amount] forKey:@"PRODUCTION"];
}

- (void) addProduction: (YAVector2i*) plotPos  Amount: (int) amount
{
    NSMutableDictionary* plotData = [colMap objectAtIndex:cCoords(plotPos.x, plotPos.y)];
    int actualProduction = [[plotData objectForKey:@"PRODUCTION"] intValue];
    
    [plotData setObject:[NSNumber numberWithInt:actualProduction + amount] forKey:@"PRODUCTION"];
}

- (int) plotProduction: (YAVector2i*) plotPos
{
    NSMutableDictionary* plotData = [colMap objectAtIndex:cCoords(plotPos.x, plotPos.y)];
    return [[plotData objectForKey:@"PRODUCTION"] intValue];
}

- (int) foundCrystalHerds
{
    int result = 0;
    
    for(int x = 0 ; x <= 6; x++)
        for(int z = 0; z <= 6; z++) {
            if ([self plotSamplesX:x Z:z] == YES  && [self plotCrystaliteX:x Z:z] == 1) {
                result++;
            }
        }
    
    return result;
}


@end

