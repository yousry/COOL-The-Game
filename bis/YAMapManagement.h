//
//  YAMapManagement.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 05.09.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YASceneUtils, YARenderLoop, YAImpersonator, YAColonyMap, YAVector2i, YAGameContext, YASoundCollector, YATerrain, YAVector2i;

@interface YAMapManagement : NSObject {
@private
    __block YAVector2i* observedBlockPosition;
    __block NSMutableArray* landGranted;
    
    __block int visitedPlots;
    
}

@property (weak, readwrite) YAGameContext* gameContext;
@property (weak, readwrite) YAColonyMap* colonyMap;
@property (weak, readwrite) YASceneUtils* sceneUtils;
@property (weak, readwrite) YARenderLoop* world;
@property (weak, readwrite) YAImpersonator* cursorInnerImp;
@property (weak, readwrite) YAImpersonator* cursorOuterImp;
@property (weak, readwrite) YASoundCollector* soundCollector;

// -- optional
@property (weak, readwrite) YAImpersonator* terrainImp;
@property (weak, readwrite) YATerrain* terrain;

- (float) selectPlots: (float) myTime;
- (float)moveCursor:(float)myTime Position: (YAVector2i*) position withCamera: (bool) cameraMovement Distance: (float) distance;



@end
