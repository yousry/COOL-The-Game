//
//  YAColonyMap.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 03.05.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YARenderLoop, YATerrain, YAImpersonator, YASceneUtils, YAGameContext, YAVector2i, YAImpGroup, YAVector3f, YABlockAnimator;

typedef enum {
    HOUSE_NONE = -1,
    HOUSE_ENERGY = 0,
    HOUSE_SMITHORE = 1,
    HOUSE_FARM = 2,
    HOUSE_CRYSTALYTE = 3,
    HOUSE_STORE = 4
} house_type;

typedef enum {
    PLAYER_VACANT = -1,
    PLAYER_1 = 0,
    PLAYER_2 = 1,
    PLAYER_3 = 2,
    PLAYER_4 = 3,
    PLAYER_STORE = 4
} plot_owner;

@interface YAColonyMap : NSObject {
@private
    NSMutableArray* colMap;
    NSArray* houseIngredients;
    
    int freePlots;
}

@property (strong, readonly) __block YAImpGroup* shopGroup;

@property (weak, readwrite) YARenderLoop* world;
@property (weak, readwrite) YATerrain* terrain;
@property (weak, readwrite) YAImpersonator* terrainImp;
@property (weak, readwrite) YASceneUtils* sceneUtils;
@property (weak, readwrite) YAGameContext* gameContext;


- (id) init;

- (void) createMountainX: (int) x Z: (int) z;

- (void) setClaim: (plot_owner) owner  X: (int) x Z: (int) z At: (float) myTime;
- (void) buidlHouse: (house_type) house forPlayer: (plot_owner) owner  X: (int) x Z: (int) z At: (float) myTime;

// This is a replacement for buildHouse.
//The socket was already created and the time delay is replaced by the event chain
- (void) buildFab: (house_type) house X: (int) x Z: (int) z Pod: (YAImpersonator*) podImp;
- (void) setFab: (house_type) house X: (int) x Z: (int) z At: (float) delay;
- (void) resetFabs;

- (float) heightX: (int) x Z: (int) z;
- (float) worldHeightX: (int) x Z: (int) z;

- (plot_owner) plotOwnerAtX: (int) x Z: (int) z;
- (house_type) plotHouseAtX: (int) x Z: (int) z;
- (float) plotCrystaliteX: (int) x Z: (int) z;
- (bool) plotSamplesX: (int) x Z: (int) z;

- (void) changePlotOwnerAtX: (int) x Z: (int) z Owner: (plot_owner) owner;
- (void) destroyPlotAtX: (int) x Z: (int) z;


- (YAVector2i*) getClaimIdAt: (YAVector3f*) position;

- (NSArray*) getEmptyPlots: (plot_owner) owner;
- (NSArray*) getAllPlots: (plot_owner) owner;

- (int) sameNeighbour: (YAVector2i*) plot;
- (NSArray*) getAllPlots: (plot_owner) owner OfType: (house_type) house;


- (YAImpersonator*) getSocketImpAtX: (int) xPos Z: (int) yPos;
- (YAImpGroup*) getHouseGroupAtX: (int) xPos Z: (int) yPos;
- (YAImpersonator*) getHouseAtX: (int) xPos Z: (int) zPos;

- (int) vacantPlots;

- (YAVector2i*) randomVacantPlot;

- (void) hideImps: (float) myTime;
- (void) showImps: (float) myTime;

- (YAVector3f*) calcWorldPosX: (int) x Z: (int) z;

- (YABlockAnimator*) blinkPlots: (int) plotOwner;

- (void) enableLaserPointer: (bool) enabled;
- (void) laserPointerAtPlot: (float) x : (float) y;

- (NSArray*) getAllProduction;
- (void) clearProductivity;
- (void) setProductivityProbability: (YAVector2i*) plotPos Probability: (float) probability;
- (float) productivityProbability: (YAVector2i*) plotPos;

- (void) changeProduction: (YAVector2i*) plotPos  Amount: (int) amount;
- (void) addProduction: (YAVector2i*) plotPos  Amount: (int) amount;
- (int) plotProduction: (YAVector2i*) plotPos;

- (int) foundCrystalHerds;
- (void) highCrystitePlotAtX: (int) x Z: (int) z;

@end
