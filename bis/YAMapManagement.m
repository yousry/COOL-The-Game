//
//  YAMapManagement.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 05.09.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YALog.h"
#import "YAProbability.h"
#import "YATerrain.h"
#import "YASoundCollector.h"
#import "YASpotLight.h"
#import "YAColonyMap.h"
#import "YASceneUtils.h"
#import "YAImpersonator.h"
#import "YAVector3f.h"
#import "YAVector2i.h"
#import "YAVector2f.h"
#import "YAMaterial.h"
#import "YABlockAnimator.h"
#import "YARenderLoop.h"
#import "YAAvatar.h"
#import "YAGameContext.h"

#import "YAMapManagement.h"

#define CURSOR_HEIGHT_SELECT_PLOTS 2.3f

@implementation YAMapManagement
@synthesize sceneUtils, world, cursorInnerImp, cursorOuterImp, colonyMap, gameContext;


-(void) botLogic: (float)  myTime
{
    assert(gameContext != nil);
    
    YAVector2i* center = [[YAVector2i alloc] initVals:3 :3];
    
    YABlockAnimator* botAct = [world createBlockAnimator];
    [botAct setDelay:myTime + 0.1];
    [botAct setOneExecution:true];
    [botAct addListener:^(float sp, NSNumber *event, int message) {
        
        for(int bot = gameContext.playerNumber; bot < 4; bot++) {
            if([[landGranted objectAtIndex:bot] boolValue] == false) {
                const int freePlots = colonyMap.vacantPlots;
                const double dist = [observedBlockPosition distanceTo:center];
                
                // urgency to find a free plot
                double probA = (double) visitedPlots / (double) freePlots;
                
                // urgency to minimize shop distance
                double probB = 1 / dist;
                
                double finalProb = fmax(probA, probB);
                double rndOutcome = [YAProbability random];
                
                if(rndOutcome < finalProb &&
                   finalProb > 0.49 &&
                   ([colonyMap plotOwnerAtX:observedBlockPosition.x Z:observedBlockPosition.y] == PLAYER_VACANT))
                {
                    [colonyMap setClaim:bot X:observedBlockPosition.x Z:observedBlockPosition.y At:0];
                    [landGranted replaceObjectAtIndex:bot withObject:[NSNumber numberWithBool:true]];
                    [_soundCollector playForImp:cursorInnerImp Sound:[_soundCollector getSoundId:@"LaserC"]];
                    return;
                }
            }
        }
        
    }];
}

- (YABlockAnimator*) buttenPressedLogic: (float) myTime
{
    assert(gameContext != nil);
    assert(colonyMap != nil);

    YABlockAnimator* userAct = [world createBlockAnimator];
    [userAct setDelay:myTime];
    [userAct addListener:^(float sp, NSNumber *event, int message) {
        
        if(observedBlockPosition.x < 0 || observedBlockPosition.x > 6 ||
           observedBlockPosition.y < 0 || observedBlockPosition.y > 6)
            return;
        
        if([colonyMap plotOwnerAtX:observedBlockPosition.x Z:observedBlockPosition.y] != PLAYER_VACANT)
            return;
        
        int deviceId = -1;
        int playerId = -1;
        
        switch (event.intValue) {
            case MOUSE_DOWN:
                deviceId = 1000;
                playerId =[gameContext playerForDevice: deviceId];
                break;
            case GAMEPAD_BUTTON_OK:
                deviceId = message >> 16;
                playerId =[gameContext playerForDevice: deviceId];
                break;
            default:
                return;
                break;
        }
        
        if([[landGranted objectAtIndex:playerId] boolValue] == false) {
            [colonyMap setClaim:playerId X:observedBlockPosition.x Z:observedBlockPosition.y At:0];
            [landGranted replaceObjectAtIndex:playerId withObject:[NSNumber numberWithBool:true]];
            [_soundCollector playForImp:cursorInnerImp Sound:[_soundCollector getSoundId:@"LaserC"]];
        }
    }];
    
    return userAct;
}


// helper function to calculate the terrain height
- (float) minCursorHeightX: (float) x Z: (float) z
{
    const int terrainGrid = _terrain.terrainDimension;
    const float terrainSize = _terrainImp.size.x;
    const float worldOffset = terrainSize;
    
    const int xI = (x + worldOffset) / (terrainSize * 2) * terrainGrid;
    const int zI = (z + worldOffset) / (terrainSize * 2) * terrainGrid;

    
    const int cursorSizeInGrids = 2;
    float height = -1;

    for(int csX = -cursorSizeInGrids; csX <= cursorSizeInGrids; csX++) {
        for(int csZ = -cursorSizeInGrids; csZ <= cursorSizeInGrids; csZ++) {
            int xx = xI + csX;
            int zz = zI + csZ;
            
            float h = -1.0f;
            if(xx >= 0 && xx <= _terrain.terrainDimension && zz >= 0 && zz <= _terrain.terrainDimension)
                h = [_terrain heightAt:xx :zz];
            
            if (h > height)
                height = h;
        }
    }

    height = (height / 255) * _terrainImp.normalMapFactor * _terrainImp.size.y + 0.025;
    return height;
}

- (float)moveCursor:(float)myTime Position: (YAVector2i*) position withCamera: (bool) cameraMovement Distance: (float) distance
{
    
    const float duration = distance == 0 ? 0.25f : 0.25f * distance;

    __block YAVector2f* curPos = nil;
    __block YAVector2f* avaPos = nil;
    __block YAVector3f* colonyTargetPos = [colonyMap calcWorldPosX:position.x Z:position.y];

    
    YABlockAnimator *moveToPos = [world createBlockAnimator];
    __weak YABlockAnimator* wToPos = moveToPos;
    
    [moveToPos setDelay:myTime];
    [moveToPos setInterval:duration];
    [moveToPos setProgress:PROGRESS_SLOW_ACCELERATE_DECELERATE];
    [moveToPos setOnce:true];
    [moveToPos setOnceReset:false];
    [moveToPos addListener:^(float sp, NSNumber *event, int message) {
        
        float progress =  sp;
        
        if(curPos == nil)
            curPos = [[YAVector2f alloc] initVals:cursorInnerImp.translation.x :cursorInnerImp.translation.z];
        
        if(avaPos == nil)
            avaPos = [[YAVector2f alloc] initVals:sceneUtils.avatar.position.x :sceneUtils.avatar.position.z];
        
        
        YAVector2f* mDestPos = [[YAVector2f alloc] initVals:colonyTargetPos.x :-colonyTargetPos.z ];
        YAVector2f* aDestPos = [[YAVector2f alloc] initVals:colonyTargetPos.x * 0.8 :-colonyTargetPos.z * 0.8];
        
        YAVector2f* posNow = [[YAVector2f alloc] initVals
                              :curPos.x + ((mDestPos.x - curPos.x) * progress)
                              :curPos.y + ((mDestPos.y - curPos.y) * progress)];
        
        YAVector2f* aPosNow = [[YAVector2f alloc] initVals
                               :avaPos.x + ((aDestPos.x - avaPos.x) * progress)
                               :avaPos.y + ((aDestPos.y - avaPos.y) * progress)];

        [[cursorInnerImp translation] setX:posNow.x];
        [[cursorInnerImp translation] setZ:posNow.y];
        [[cursorOuterImp translation] setX:posNow.x];
        [[cursorOuterImp translation] setZ:posNow.y];
        
        if(posNow.x <= mDestPos.x)
            [[cursorOuterImp rotation] setY: -sp * 90];
        else {
            if(!cameraMovement)
                [[cursorOuterImp rotation] setY: +sp * 90];
            else
                [[cursorOuterImp rotation] setY: +sp * 180];
        }
        
        YAVector3f* movehigherDim = [[YAVector3f alloc] initVals:aPosNow.x :sceneUtils.avatar.position.y :aPosNow.y ];
        
        if(cameraMovement) {
            [[sceneUtils avatar] setPosition:movehigherDim];
            [sceneUtils.spotLight spotAt:[[YAVector3f alloc] initVals:posNow.x :cursorInnerImp.translation.y :posNow.y]];
            [sceneUtils updateSpotLightFrustum];
        } else {
            const float cursorHeightLast = cursorInnerImp.translation.y;
            const float cursorHeight = [self minCursorHeightX:cursorInnerImp.translation.x Z:cursorInnerImp.translation.z];
            const float cursorHightDest = [self minCursorHeightX:mDestPos.x Z:mDestPos.y];
            
            const float cursorAverage = (cursorHeight  + cursorHeightLast  + cursorHightDest * 2) / 4.0f;
            
            cursorInnerImp.translation.y = fmax(cursorHeight,cursorAverage);
            cursorOuterImp.translation.y = fmax(cursorHeight,cursorAverage);
        }
        
        if(wToPos.deleteme) {
                [_soundCollector playForImp:cursorInnerImp Sound:[_soundCollector getSoundId:@"Pickup"]];
        }
    }];
    
    
    moveToPos = [world createBlockAnimator];
    [moveToPos setDelay:myTime + duration];
    [moveToPos setOneExecution:true];
    [moveToPos addListener:^(float sp, NSNumber *event, int message) {
        observedBlockPosition = [[YAVector2i alloc] initVals:position.x : 6 - position.y ];
        // used for Bot calculations
        visitedPlots++;
    }];
    
    
    return myTime + duration;
}

- (float) selectPlots: (float) mtm
{
    assert(sceneUtils != nil);
    assert(world != nil);
    assert(cursorInnerImp != nil);
    assert(cursorOuterImp != nil);
    assert(colonyMap != nil);
    
    cursorInnerImp.translation.y = CURSOR_HEIGHT_SELECT_PLOTS;
    cursorOuterImp.translation.y = CURSOR_HEIGHT_SELECT_PLOTS;
    
    const float lastCutoff = sceneUtils.spotLight.cutoff;
    const float lastExponnent = sceneUtils.spotLight.exponent;
    
    sceneUtils.spotLight.cutoff = 5.0;
    sceneUtils.spotLight.exponent = 800.0;
    
    [sceneUtils.spotLight spotAt:[[YAVector3f alloc] initVals:cursorInnerImp.translation.x :cursorInnerImp.translation.y :cursorInnerImp.translation.z]];
    [sceneUtils updateSpotLightFrustum];

    
    // initialise selections
    landGranted = [[NSMutableArray alloc] initWithObjects:
                   [NSNumber numberWithBool:false],
                   [NSNumber numberWithBool:false],
                   [NSNumber numberWithBool:false],
                   [NSNumber numberWithBool:false],
                   nil ];
    
    // disable selection
    observedBlockPosition = [[YAVector2i alloc] initVals:-1 :-1];

    __block float myTime = mtm;
    
    [sceneUtils updateFrustumTo:AVATAR_TOP_FRONT At:myTime];
    myTime = [sceneUtils moveAvatarPositionTo:AVATAR_TOP_FRONT At:myTime];
    

    YABlockAnimator* pressAnim = [self buttenPressedLogic:myTime];
    
    __block  YAImpersonator* textLandGrand = [sceneUtils genTextBlocked:[YALog decode:@"landGrant"]];
    [textLandGrand resize:0.15];
    [[[textLandGrand material] phongAmbientReflectivity] setVector:sceneUtils.color_yellow];
    textLandGrand.material.eta = 0.2;
    textLandGrand.visible = false;
    
    __block  YAImpersonator* textPressButton = [sceneUtils genTextBlocked:[YALog decode:@"selectPlot"]];
    [textPressButton setVisible:false];
    [textPressButton resize:0.15];
    [[[textPressButton material] phongAmbientReflectivity] setVector:sceneUtils.color_yellow];
    textPressButton.material.eta = 0.2;
    textPressButton.visible = false;
    
    [sceneUtils showImp:textLandGrand atTime:myTime + 0.1];
    [sceneUtils showImp:textPressButton atTime:myTime + 0.1];
    
    const float storeTime = myTime;
    visitedPlots = 0;
    
    for(int zPos = 0; zPos < 7; zPos++) {
        for(int xPos = 0; xPos < 7; xPos++) {
            if([colonyMap plotOwnerAtX:xPos Z: 6 - zPos] !=  PLAYER_VACANT)
                continue;
            
            myTime = [self moveCursor:myTime Position:[[YAVector2i alloc] initVals:xPos :zPos] withCamera:YES Distance:0];
            [self botLogic:myTime];
            
            myTime += 0.2f;
        }
    }
    
    // must run after cursor movement
    __block YABlockAnimator* anim = [world createBlockAnimator];
    [anim setDelay:storeTime];
    [anim setProgress:harmonic];
    [anim setInterval:1.5];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        [[textLandGrand translation] setVector:[[YAVector3f alloc] initVals:-0.5 :0.95 :5]];
        [sceneUtils alignToCam:textLandGrand];
        [[textPressButton translation] setVector:[[YAVector3f alloc] initVals:-0.7 :-0.8 :5]];
        [sceneUtils alignToCam:textPressButton];
        [[[textPressButton material] phongAmbientReflectivity] setValues:sp + 0.5 :0 :0.0];
    }];

    // cleanup
    YABlockAnimator *cleanUp = [world createBlockAnimator];
    [cleanUp setDelay:myTime];
    [cleanUp setOneExecution:true];
    [cleanUp addListener:^(float sp, NSNumber *event, int message) {
        
        sceneUtils.spotLight.cutoff = lastCutoff;
        sceneUtils.spotLight.exponent = lastExponnent;
        [sceneUtils.spotLight spotAt:[[YAVector3f alloc] initVals:0 :0 :0]];
        
        [anim setDeleteme:true];
        [pressAnim setDeleteme:true];
        [sceneUtils removeImp:textLandGrand atTime:0];
        [sceneUtils removeImp:textPressButton atTime:0];
    }];
    
    return myTime;
}


@end
