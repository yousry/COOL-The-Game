//
//  YASceneUtils.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 28.08.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Positionable.h"
#import "WithRadiation.h"

@class YAGameContext, YAAvatar, YARenderLoop, YAGouradLight, YASpotLight,
    YALight, YAAvatar, YAImpersonator, YARenderLoop, YATerrain,
    YAImpersonator, YAColonyMap, YAGameStateMachine;

typedef enum {
    AVATAR_FRONT_GAMEBOARD,
    AVATAR_TOP_FRONT,
    AVATAR_PLANET,
    AVATAR_SCORE,
    AVATAR_AUCTION,
    AVATAR_EAGLE,
    AVATAR_RELATIV_POI,
    AVATAR_SHOP_DEBUG,
    AVATAR_BOARD_OVERVIEW,
    AVATAR_BOOKSHELF_DEBUG,
    AVATAR_LEFTWALL_DEBUG,
    AVATAR_TABLE_DEBUG,
    AVATAR_DEVELOPMENT,
} avatar_position;

typedef enum {
    LIGHT_STUDIO_SE,
    LIGHT_STUDIO_RIGHT,
    LIGHT_NOON_HIGH,
    LIGHT_STUDIO_FILLSHADOWS,
    LIGHT_NOON_RELAXED,
    LIGHT_ROOM_SPOT,
    LIGHT_RELATIVE_POI,
    LIGHT_ZENITH,
} light_position;


typedef enum {
    EMISSION_WHITE_FULL,
    EMISSION_ARTIFICIAL_FULL
} light_emission;

@interface YASceneUtils : NSObject {
@private
    YARenderLoop* _world;
    YAImpersonator* debugLampImp;
    
    NSMutableArray* impRemovePuffer;
    
}

@property (weak, readonly) YAAvatar* avatar;
@property (weak, readonly) YAGouradLight* light;
@property (weak, readonly) YASpotLight* spotLight;
@property (weak, readwrite) YAVector3f* poi;

- (id) initInWorld: (YARenderLoop*) world;

- (YAGameContext*) createMockupGameContext;

- (void) setAvatarPositionTo: (avatar_position) position;
- (void) setLightPosition: (id<Positionable>) light to: (light_position) position;
- (void) setRadiation: (id<WithRadiation>) light to: (light_emission) emission;

- (void) alignToCam: (YAImpersonator*) imp;
- (void) alignToCam: (YAImpersonator*) imp AtTime: (float) delay;

- (float) scrollText: (YAImpersonator*) imp atTime: (float) delay;
- (float) tickerText: (YAImpersonator*) imp atTime: (float) delay withLength: (int) characters;

- (void) removeImp: (YAImpersonator*) imp atTime: (float) delay;

- (void) showImp: (YAImpersonator*) imp atTime: (float) delay;
- (void) hideImp: (YAImpersonator*) imp atTime: (float) delay;

- (float) moveAvatarPositionTo: (avatar_position) position At: (float) time;

- (void) cameraDebug;
- (void) cameraDebugRelativeTo: (YAVector3f*) position;

- (void) frustumDebug;
- (void) updateFrustumTo: (avatar_position) position;
- (void) updateFrustumTo: (avatar_position) position At: (float) time;



- (void) lightDebug: (bool) isSpotLight;
- (void) impDebug: (YAImpersonator*) imp;
- (void) impDebug: (YAImpersonator*) imp relativeTo: (YAVector3f*) origin;


- (void) materialDebug: (YAImpersonator*) imp;


- (void) showScoreBoard: (YAGameContext*) gameContext;
- (void) hideScoreBoard: (YAGameContext*) gameContext;

- (void) showScoreBoard: (YAGameContext*) gameContext At: (float) time;
- (void) hideScoreBoard: (YAGameContext*) gameContext At: (float) time;

- (YAImpersonator*) genTextBlocked: (NSString*) text;
- (YAImpersonator*) genText: (NSString*) text;


- (NSArray*) createPlayerColorRings: (YAGameContext*) gameContext;
- (NSArray*) createPlayerColorBalls: (YAGameContext*) gameContext;
- (NSArray*) createPlayerColorChart: (YAGameContext*) gameContext;


- (float) rotatateAvatar: (float) myTime;

- (void) updateSpotLightFrustum;
- (void) updateSpotLightFrustumAt: (float) myTime;
- (void) updateSpotLightFrustumUnblocked;



// colors
@property (readonly) YAVector3f* color_yellow;
@property (readonly) YAVector3f* color_grey_white;
@property (readonly) YAVector3f* color_red;
@property (readonly) YAVector3f* color_black;
@property (readonly) YAVector3f* color_dark_blue;
@property (readonly) YAVector3f* color_green;
@property (readonly) YAVector3f* color_white;


// Global State Machine
@property (weak, readwrite) YAGameStateMachine* gameState;

@end
