//
//  YAImpCollector.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 29.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YAImpersonator, YAImpGroup;

// Just consists of a colletion of imps(references for transfer to Events

@interface YAImpCollector : NSObject

@property (weak, readwrite) YAImpersonator* terrainImp;
@property (weak, readwrite) YAImpersonator* cursorInnerImp;
@property (weak, readwrite) YAImpersonator* cursorOuterImp;
@property (weak, readwrite) YAImpersonator* moonImp;
@property (weak, readwrite) YAImpersonator* sunImp;
@property (weak, readwrite) YAImpersonator* sunCoverImp;
@property (weak, readwrite) YAImpersonator* deskImp;
@property (weak, readwrite) YAImpersonator* boardImp;
@property (weak, readwrite) YAImpersonator* boardTitleImp;
@property (weak, readwrite) YAImpersonator* spaceShipImp;
@property (weak, readwrite) YAImpersonator* barrackImp;
@property (weak, readwrite) YAImpersonator* planeImp;
@property (weak, readwrite) NSMutableArray* starImps;
@property (weak, readwrite) YAImpGroup* eagleGroup;
@property (weak, readwrite) YAImpersonator* podImp;
@property (weak, readwrite) YAImpersonator* parachuteImp;
@property (weak, readwrite) YAImpersonator* stickSunImp;
@property (weak, readwrite) YAImpersonator* stickMoonImp;
@property (weak, readwrite) YAImpersonator* tableImp;
@property (weak, readwrite) YAImpersonator* cloudNormalImp;
@property (weak, readwrite) YAImpersonator* cloudLightningImp;
@property (weak, readwrite) YAImpersonator* meteoriteImp;
@property (weak, readwrite) YAImpersonator* fireImp;
@property (weak, readwrite) NSArray* ropeSegments;
@end

