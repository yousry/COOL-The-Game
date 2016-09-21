//
//  YASceneUtils.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 28.08.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//


#import "YAChronograph.h"

#import "YALog.h"
#import "YAAlienRace.h"

#import "YATransformator.h"
#import "YAPerspectiveProjectionInfo.h"

#import "YAGameContext.h"

#import "YAKinematic.h"
#import "YAQuaternion.h"
#import "YABonzoidMover.h"
#import "YAFlapperMover.h"
#import "YAGollumerMover.h"
#import "YAHumanoidMover.h"
#import "YALeggitMover.h"
#import "YAMechatronMover.h"
#import "YAPackerMover.h"
#import "YASpheroidMover.h"
#import "YADromedarMover.h"

#import "YATexture.h"
#import "YAAvatar.h"
#import "YAIngredient.h"
#import "YAImpersonator.h"
#import "YAVector4f.h"
#import "YAVector3f.h"
#import "YABasicAnimator.h"
#import "YABlockAnimator.h"
#import "YASpotLight.h"
#import "YALight.h"
#import "YAGouradLight.h"
#import "YAMaterial.h"

#import "YATriangleGrid.h"
#import "YATerrain.h"

#import "YARenderLoop.h"

#import "YAImpGroup.h"

#import "YAGameContext.h"

#import "YASceneUtils.h"

@implementation YASceneUtils
@synthesize light = _light, spotLight = _spotLight, avatar = _avatar;
@synthesize poi;
@synthesize color_yellow, color_grey_white, color_red, color_black, color_dark_blue, color_green, color_white;

- (id) initInWorld: (YARenderLoop*) world
{
    self = [super init];
    
    if(self) {
        _world = world;
        _avatar = [world avatar];
        NSArray* lights = [world lights];
        
        for (YALight* lit in lights) {
            if([[lit name] isEqualToString:@"YAGouradLight"])
                _light = (YAGouradLight*)lit;
            else if([[lit name] isEqualToString:@"YASpotLight"]) {
                _spotLight = (YASpotLight*)lit;
            }
        }
        
        int debugLampImpId = [world createImpersonator:@"DebugLamp"];
        debugLampImp = [world getImpersonator:debugLampImpId];
        [[debugLampImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
        [debugLampImp resize:0.5];
        [[[debugLampImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
        [[[debugLampImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
        [[[debugLampImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
        [[debugLampImp material] setPhongShininess: 10.0f];
        [[debugLampImp translation] setX:_spotLight.position.x];
        [[debugLampImp translation] setY:_spotLight.position.y];
        [[debugLampImp translation] setZ:_spotLight.position.z];
        [debugLampImp setShadowCaster:false];
        [debugLampImp setVisible:false];
        
        color_yellow = [[YAVector3f alloc] initVals:1.0 :0.9 :0.1];
        color_red = [[YAVector3f alloc] initVals:1.0 :0.0 :0.0];
        color_grey_white = [[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ];
        color_black = [[YAVector3f alloc] initVals: 0 : 0 : 0 ];
        color_green = [[YAVector3f alloc] initVals: 0 : 1 : 0 ];
        color_dark_blue = [[YAVector3f alloc] initVals: 0.02279 : 0.02201 : 0.303 ];
        color_white = [[YAVector3f alloc] initVals: 1 : 1 : 1 ];
    }
    
    return self;
}

- (YAGameContext*) createMockupGameContext
{
    YAGameContext* gameContext = [[YAGameContext alloc] init];
    
    gameContext.gameDifficulty = 0;
    [gameContext setPlayerNumber:0];
    
    [gameContext setColor:0 forPlayer:0];
    [gameContext setColor:1 forPlayer:1];
    [gameContext setColor:2 forPlayer:2]; // Bot
    [gameContext setColor:3 forPlayer:3]; // Bot
    
    [gameContext setPlayerNumber:1];
    [gameContext setDeviceId:100 forPlayer:0]; // player 0 plays pad
//    [gameContext setDeviceId:1000 forPlayer:1]; // player 1 plays mouse
    [gameContext setSpecies:@"Flapper" forPlayer:0];
//    [gameContext setSpecies:@"Paker" forPlayer:1];

    return gameContext;
}


- (void) updateFrustumTo: (avatar_position) position
{
    YABlockAnimator* anim = [_world createBlockAnimator];
    anim.oneExecution = YES;
    anim.delay = 0;
    [anim addListener:^(float sp, NSNumber *event, int message) {

        switch (position) {
            case AVATAR_RELATIV_POI:
                _world.transformer.projectionInfo.zNear = 15.0f;
                _world.transformer.projectionInfo.zFar = 500.0f;
                break;
            case AVATAR_EAGLE:
                _world.transformer.projectionInfo.zNear = 1.0f;
                _world.transformer.projectionInfo.zFar = 50.0f;
                break;
            case AVATAR_FRONT_GAMEBOARD:
                _world.transformer.projectionInfo.zNear = 5.0f;
                _world.transformer.projectionInfo.zFar = 50.0f;
                break;
            case AVATAR_SCORE:
                _world.transformer.projectionInfo.zNear = 5.0f;
                _world.transformer.projectionInfo.zFar = 60.0f;
                break;
            case AVATAR_TOP_FRONT:
                _world.transformer.projectionInfo.zNear = 0.5f;
                _world.transformer.projectionInfo.zFar = 50.0f;
                break;
            default:
                [[[_world transformer] projectionInfo] setZFar:1000.0f];
                [[[_world transformer] projectionInfo] setZNear:0.1f];
                [[_world transformer] recalcCam];
                break;
        }
        
        [[_world transformer] recalcCam];

     }];
}


- (void) updateFrustumTo: (avatar_position) position At: (float) time
{
    YABlockAnimator* anim = [_world createBlockAnimator];
    anim.oneExecution = YES;
    anim.delay = time;
    [anim addListener:^(float sp, NSNumber *event, int message) {
        [self updateFrustumTo:position];
    }];
}


- (void) setAvatarPositionTo: (avatar_position) position
{
    YAVector3f* relPos = [[YAVector3f alloc] initCopy: poi];
    [relPos addVector:[[YAVector3f alloc] initVals: 0 : 0.560716 :  -0.915288]];
    
    switch (position) {
        case AVATAR_FRONT_GAMEBOARD:
            [_avatar setPosition: [[YAVector3f alloc] initVals:-0.143689 :8.219234 :-16.438982 ]];
            [_avatar setAtlas:25.654783 axis:-0.176539];
            break;
        case AVATAR_TOP_FRONT:
            [_avatar setPosition: [[YAVector3f alloc] initVals:0 :12 :-1.5 ]];
            [_avatar setAtlas:90 axis:0];
            break;
        case AVATAR_PLANET:
            [_avatar setPosition: [[YAVector3f alloc] initVals:-0.536970  :3.616479  :-10.767632 ]];
            [_avatar setAtlas:7.362630 axis:2.013659];
            break;
        case AVATAR_SCORE:
            [_avatar setPosition: [[YAVector3f alloc] initVals:-19.927803  :1.738040  :0.483234 ]];
            [_avatar setAtlas:-6.188380 axis:91.372581];
            break;
        case AVATAR_AUCTION:
            [_avatar setPosition: [[YAVector3f alloc] initVals:16.210600  :8.509934  :0 ]];
            [_avatar setAtlas:27.635183 axis:-89.845169];
            break;
        case AVATAR_EAGLE:
            [_avatar setPosition: [[YAVector3f alloc] initVals:-0.093462  :5.886656  :-6.5 ]];
            [_avatar setAtlas:36.784195 axis:0.272482];
            break;
        case AVATAR_SHOP_DEBUG:
            [_avatar setPosition: [[YAVector3f alloc] initVals:-0.105912  :1.337131  :-0.981697 ]];
            [_avatar setAtlas:48.231243 axis:1.397972];
            break;
        case AVATAR_BOARD_OVERVIEW:
            [_avatar setPosition: [[YAVector3f alloc] initVals:-5.661594   :11.575125  :-21.753525 ]];
            [_avatar setAtlas:26.248892 axis:14.664639];
            break;
        case AVATAR_BOOKSHELF_DEBUG:
            [_avatar setPosition: [[YAVector3f alloc] initVals:8.364646   :13.929794 :-12.634048]];
            [_avatar setAtlas:10.182232 axis:1.776412];
            break;
        case AVATAR_LEFTWALL_DEBUG:
            [_avatar setPosition: [[YAVector3f alloc] initVals:41.122208   :24.946142  :-2.998234 ]];
            [_avatar setAtlas:9.846991 axis:-84.033409];
            break;
        case AVATAR_RELATIV_POI:
            [_avatar setPosition: relPos];
            [_avatar setAtlas:30.5 axis:0];
            break;
        case AVATAR_TABLE_DEBUG:
            [_avatar setPosition: [[YAVector3f alloc] initVals:-13.921159   :32.760807  :-75.942535 ]];
            [_avatar setAtlas:22.646933 axis:9.197976];
            break;
        case AVATAR_DEVELOPMENT:
            [_avatar setPosition: [[YAVector3f alloc] initVals:-0.090892   :13.901341  :-18.569448 ]];
            [_avatar setAtlas:37.399887 axis:-0.735361];
            break;
        default:
            break;
    }
}


//Position: YAVector3f [-0.215876, 14.664547, -17.691357]
//Atlas: 41.060669, Axis: 0.088169


- (float) moveAvatarPositionTo: (avatar_position) position At: (float) time
{
    
    __block YAVector3f* posA = [[YAVector3f alloc] initCopy:[_avatar position]];
    __block float atlasA = [_avatar headAtlas];
    __block float axisA = [_avatar headAxis];
    
    [self setAvatarPositionTo:position];
    
    __block YAVector3f* posB = [[YAVector3f alloc] initCopy:[_avatar position]];
    __block float atlasB = [_avatar headAtlas];
    __block float axisB = [_avatar headAxis];
    
    // Now is the future this is the time at the initialization!
    [_avatar setPosition:posA];
    [_avatar setAtlas:atlasA axis:axisA];
    
    // in order execution used to calcualate the actual state
    YABlockAnimator* anim = [_world createBlockAnimator];
    [anim setOneExecution:true];
    [anim setDelay:time];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        [[_world transformer] recalcCam];
        posA = [[YAVector3f alloc] initCopy:[_avatar position]];
        atlasA = [_avatar headAtlas];
        axisA = [_avatar headAxis];
    }];
    
    // here starts the calcualtion between the "future" now and then
    anim = [_world createBlockAnimator];
    
    [anim setProgress:damp];
    [anim setOnce:true];
    [anim setOnceReset:false];
    [anim setDelay:time];
    [anim setAsyncProcessing: NO];
    [anim setInterval:1.0];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        float progress =  sp;
        
        YAVector3f* posNow = [[YAVector3f alloc] initVals
                              :posA.x + ((posB.x - posA.x) * progress)
                              :posA.y + ((posB.y - posA.y) * progress)
                              :posA.z + ((posB.z - posA.z) * progress)];
        
        float atlasNow = atlasA + ((atlasB - atlasA) * progress);
        float axisNow = axisA + ((axisB - axisA) * progress);
        
        [_avatar setPosition:posNow];
        [_avatar setAtlas:atlasNow axis:axisNow];
    }];
    
    return time + 1.0f;
}


- (void) setLightPosition: (id<Positionable>) light to: (light_position) position;
{
    
    YAVector3f* relPos = [[YAVector3f alloc] initCopy: poi];
    [relPos addVector:[[YAVector3f alloc] initVals: 0.5 : 1 :  0]];


    
    switch (position) {
        case LIGHT_STUDIO_SE:
            [[light position] setVector:[[YAVector3f alloc] initVals: 1.659804 : 5.900003 : -1.111771]];
            break;
        case LIGHT_NOON_HIGH:
            [[light position] setVector:[[YAVector3f alloc] initVals:0 :5 :0]];
            break;
        case LIGHT_STUDIO_RIGHT:
            [[light position] setVector:[[YAVector3f alloc] initVals:7.052431 :3.749997 :-0.030781]];
            break;
        case LIGHT_STUDIO_FILLSHADOWS:
            [[light position] setVector:[[YAVector3f alloc] initVals:-3.740680 :25.299898 :9.733787]];
            break;
        case LIGHT_NOON_RELAXED:
            [[light position] setVector:[[YAVector3f alloc] initVals:1.655883 :5.900003 :1.393621]];
            break;
        case LIGHT_ROOM_SPOT:
            [[light position] setVector:[[YAVector3f alloc] initVals:12.427451 :16.550034 :0.501561]];
            break;
        case LIGHT_RELATIVE_POI:
            [[light position] setVector:relPos];
            break;
        case LIGHT_ZENITH:
            [[light position] setVector:[[YAVector3f alloc] initVals:0 :15 :0]];
            break;
        default:
            break;
    }
}

- (void) setRadiation: (id<WithRadiation>) light to: (light_emission) emission
{
    switch (emission) {
        case EMISSION_WHITE_FULL:
            [[light intensity] setVector:[[YAVector3f alloc] initVals: 1 : 1 : 1 ]];
            break;
        case EMISSION_ARTIFICIAL_FULL:
            [[light intensity] setVector:[[YAVector3f alloc] initVals: 0.97f : 0.97f : 1.0f ]];
            break;
        default:
            break;
    }
}

- (void) hideScoreBoard: (YAGameContext*) gameContext At: (float) time
{
    YABlockAnimator* anim = [_world createBlockAnimator];
    [anim setOneExecution:true];
    [anim setDelay:time];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        [self hideScoreBoard:gameContext];
    }];
}


- (void) hideScoreBoard: (YAGameContext*) gameContext
{
    for(YAAlienRace* al in gameContext.playerGameData) {
        [[al impersonator] setVisible:false];
    }
        
    for(NSNumber* i in impRemovePuffer) {
        [_world removeImpersonator:i.intValue];
    }
        
    
}

- (void) showScoreBoard: (YAGameContext*) gameContext At: (float) time
{
    YABlockAnimator* anim = [_world createBlockAnimator];
    [anim setOneExecution:true];
    [anim setDelay:time];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        
        YAVector3f* actAvatarPos = [[YAVector3f alloc] initCopy:_avatar.position];
        float axis = _avatar.headAxis;
        float atlas = _avatar.headAtlas;
        [self setAvatarPositionTo:AVATAR_SCORE];
        [self showScoreBoard:gameContext];
        [[_avatar position] setVector:actAvatarPos];
        [_avatar setAtlas:atlas axis:axis];
    }];
}

- (void) showScoreBoard: (YAGameContext*) gameContext
{
    
    impRemovePuffer = [[NSMutableArray alloc] init];
    
    NSString* scoreboardTitleText = [NSString stringWithFormat:@"%@ %d", [YALog decode:@"scoreboardTitle"], gameContext.round ] ;
    YAImpersonator* textImp = [self genText:scoreboardTitleText];
    [[[textImp material] phongAmbientReflectivity] setValues:0.9 :0.1 :0.2];
    
    [impRemovePuffer addObject:[NSNumber numberWithInt:[textImp identifier]]];
    
    [textImp resize:0.3];
    [[textImp translation] setVector:[[YAVector3f alloc] initVals: -1.5 :1.7 :9]];
    [self alignToCam:textImp];
    
    NSArray* sortedByMoney = [[gameContext playerGameData] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int v1 = [(YAAlienRace*)obj1 totalValue];
        int v2 = [(YAAlienRace*)obj2 totalValue];
        if (v1 > v2)
            return NSOrderedAscending;
        else if (v1 < v2)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
     }];
    
    const float defaultTextSize = 0.15f;
    const float defaultEta = 0.3f;
    
    float yOrigin = 0.75;
    float yOriginText = yOrigin + 0.4;

    float xOriginText = -1.75;
    float xOriginTextValue = 1.75;

    float yOffset = 0.66f;
    float yOffsetText = 0.66f;
    float ySubOffsetText = -0.14f;

    float spaceLength = 0.1f;

    int enumerator = 0;
    
    int colonyTotal = 0;
    
    for(YAAlienRace* al in sortedByMoney) {
        
        YAVector3f* playerColor = [[gameContext colorVectors] objectAtIndex:[gameContext getColorForPlayer:al.playerId]];
        
        [al sizeScoreboard];
        YAImpersonator* imp = al.impersonator;
        [imp setVisible:true];
        [[imp translation] setY:yOrigin - (yOffset * enumerator)];
        [[imp translation] setX:-2];
        [[imp translation] setZ:7];
        
        YAVector3f* position = imp.translation;
        position = [position rotate:[_avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
        position = [position rotate:[_avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
        [position addVector:[_avatar position]];
        
        [[imp translation] setVector: position];
        [[imp rotation] setX: [_avatar headAtlas] -90];
        [[imp rotation] setY: -[_avatar headAxis]];
        
        textImp = [self genText:[YALog decode:@"money"]];
        [[[textImp material] phongAmbientReflectivity] setVector:playerColor];
        textImp.material.eta = defaultEta;
        [impRemovePuffer addObject:[NSNumber numberWithInt:[textImp identifier]]];
        [textImp resize:defaultTextSize];
        [[textImp translation] setVector:[[YAVector3f alloc] initVals:xOriginText :yOriginText - (yOffsetText * enumerator) :7]];
        [self alignToCam:textImp];
        
        NSString* value = [NSString stringWithFormat:@"%d", al.money];
        textImp = [self genText:value];
        [[[textImp material] phongAmbientReflectivity] setVector:playerColor];
        textImp.material.eta = defaultEta;
        [impRemovePuffer addObject:[NSNumber numberWithInt:[textImp identifier]]];
        [textImp resize:defaultTextSize];
        [[textImp translation] setVector:[[YAVector3f alloc] initVals:xOriginTextValue + (5 - value.length) * spaceLength :yOriginText - (yOffsetText * enumerator) :7]];
        [self alignToCam:textImp];


        textImp = [self genText:[YALog decode:@"land"]];
        [[[textImp material] phongAmbientReflectivity] setVector:playerColor];
        textImp.material.eta = defaultEta;
        [impRemovePuffer addObject:[NSNumber numberWithInt:[textImp identifier]]];
        [textImp resize:defaultTextSize];
        [[textImp translation] setVector:[[YAVector3f alloc] initVals:xOriginText  :yOriginText - (yOffsetText * enumerator) + ySubOffsetText:7]];
        [self alignToCam:textImp];
        
        value = [NSString stringWithFormat:@"%d", [al getLand]];
        textImp = [self genText:value];
        [[[textImp material] phongAmbientReflectivity] setVector:playerColor];
        textImp.material.eta = defaultEta;
        [impRemovePuffer addObject:[NSNumber numberWithInt:[textImp identifier]]];
        [textImp resize:defaultTextSize];
        [[textImp translation] setVector:[[YAVector3f alloc] initVals:xOriginTextValue + (5 - value.length) * spaceLength :yOriginText - (yOffsetText * enumerator) + ySubOffsetText :7]];
        [self alignToCam:textImp];
        

        textImp = [self genText:[YALog decode:@"goods"]];
        [[[textImp material] phongAmbientReflectivity] setVector:playerColor];
        textImp.material.eta = defaultEta;
        [impRemovePuffer addObject:[NSNumber numberWithInt:[textImp identifier]]];
        [textImp resize:defaultTextSize];
        [[textImp translation] setVector:[[YAVector3f alloc] initVals:xOriginText :yOriginText - (yOffsetText * enumerator) + (ySubOffsetText * 2):7]];
        [self alignToCam:textImp];
        
        value = [NSString stringWithFormat:@"%d", [al getGoods]];
        textImp = [self genText:value];
        [[[textImp material] phongAmbientReflectivity] setVector:playerColor];
        textImp.material.eta = defaultEta;
        [impRemovePuffer addObject:[NSNumber numberWithInt:[textImp identifier]]];
        [textImp resize:defaultTextSize];
        [[textImp translation] setVector:[[YAVector3f alloc] initVals:xOriginTextValue + (5 - value.length) * spaceLength :yOriginText - (yOffsetText * enumerator) + (ySubOffsetText * 2) :7]];
        [self alignToCam:textImp];


        textImp = [self genText:[YALog decode:@"total"]];
        [[[textImp material] phongAmbientReflectivity] setVector:playerColor];
        textImp.material.eta = defaultEta;
        [impRemovePuffer addObject:[NSNumber numberWithInt:[textImp identifier]]];
        [textImp resize:defaultTextSize];
        [[textImp translation] setVector:[[YAVector3f alloc] initVals:xOriginText :yOriginText - (yOffsetText * enumerator) + (ySubOffsetText * 3):7]];
        [self alignToCam:textImp];

        int playerTotal = al.totalValue;
        colonyTotal += playerTotal;
        value = [NSString stringWithFormat:@"%d", playerTotal];
        textImp = [self genText:value];
        [[[textImp material] phongAmbientReflectivity] setVector:playerColor];
        textImp.material.eta = defaultEta;
        [impRemovePuffer addObject:[NSNumber numberWithInt:[textImp identifier]]];
        [textImp resize:defaultTextSize];
        [[textImp translation] setVector:[[YAVector3f alloc] initVals:xOriginTextValue + (5 - value.length) * spaceLength :yOriginText - (yOffsetText * enumerator) + (ySubOffsetText * 3) :7]];
        [self alignToCam:textImp];
        
        enumerator++;
    }
    

    // show colony total
    textImp = [self genText:[YALog decode:@"colony"]];
    textImp.material.eta = defaultEta;
    [impRemovePuffer addObject:[NSNumber numberWithInt:[textImp identifier]]];
    [textImp resize:defaultTextSize];
    [[textImp translation] setVector:[[YAVector3f alloc] initVals: xOriginText :yOriginText - (yOffsetText * enumerator) :7]];
    [self alignToCam:textImp];
    
    NSString* value = [NSString stringWithFormat:@"%d", colonyTotal];
    textImp = [self genText:value];
    textImp.material.eta = defaultEta;
    [impRemovePuffer addObject:[NSNumber numberWithInt:[textImp identifier]]];
    [textImp resize:defaultTextSize];
    [[textImp translation] setVector:[[YAVector3f alloc] initVals: xOriginTextValue + (5 - value.length) * spaceLength :yOriginText - (yOffsetText * enumerator) :7]];
    [self alignToCam:textImp];
}

- (void) alignToCam: (YAImpersonator*) imp AtTime: (float) delay
{
    YABlockAnimator* anim = [_world createBlockAnimator];
    [anim setOneExecution:true];
    [anim setDelay:delay];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        [self alignToCam:imp];
    }];
}


- (void) alignToCam: (YAImpersonator*) imp
{
    YAVector3f* position = imp.translation;
    position = [position rotate:[_avatar headAtlas] axis:[[YAVector3f alloc] initXAxe]];
    position = [position rotate:[_avatar headAxis] axis:[[YAVector3f alloc] initYAxe]];
    [position addVector:[_avatar position]];
    
    [[imp translation] setVector: position];
    [[imp rotation] setX: [_avatar headAtlas]];
    [[imp rotation] setY: -[_avatar headAxis]];
}

- (float) tickerText: (YAImpersonator*) imp atTime: (float) delay withLength: (int) characters
{
    float duration = 0.105 * characters;
    
    YAVector3f* originCenter = [[YAVector3f alloc] initCopy:imp.translation];

    YABlockAnimator* anim = [_world createBlockAnimator];
    [anim setAsyncProcessing:NO];
    [anim setOnce:YES];
    [anim setOnceReset:false];
    [anim setInterval:duration];
    [anim setProgress:cyclic];
    [anim setDelay:delay];
    
    __block int averager = 0;
    __block float average = 0;
    __block float spAveraged = 0;
    __block float lastSP = 0;
    
    [anim addListener:^(float sp, NSNumber *event, int message) {
        
        if(average == 0) average = sp;
        
        else if(averager++ <= 60) {
            average = average       * ((float)averager / (float)(averager + 1)) +
                      (sp - lastSP) * 1.0f / (float)(averager + 1);
        }
        
        lastSP = sp;
        spAveraged += average;
        
        [[imp translation] setVector:originCenter];
        imp.translation.x -= (spAveraged * characters * 0.13);
        [self alignToCam:imp];
    }];
    
    return duration + delay;
}


- (float) scrollText: (YAImpersonator*) imp atTime: (float) delay;
{
    float duration = 0.8;
    
    YABasicAnimator* scrollAnim = [_world createBasicAnimator];
    [scrollAnim setInfluence:Y_AXE];
    [scrollAnim setAsyncProcessing:false];
    [scrollAnim setOnce:YES];
    [scrollAnim setOnceReset:false];
    [scrollAnim setInterval:duration];
    [scrollAnim setProgress:damp];
    [scrollAnim setDelay:delay];
    [imp.translation setY: imp.translation.y + 1.5];
    [scrollAnim addListener:[imp translation] factor:-1.5];
    
    return duration + delay;
}

- (void) removeImp: (YAImpersonator*) imp atTime: (float) delay
{
    YABlockAnimator* remover = [_world createBlockAnimator];
    [remover setOneExecution:true];
    [remover setDelay:delay];
    [remover addListener:^(float sp, NSNumber *event, int message) {
        [_world removeImpersonator:[imp identifier]];
    }];
}


- (void) showImp: (YAImpersonator*) imp atTime: (float) delay
{
    YABlockAnimator* anim = [_world createBlockAnimator];
    [anim setOnce:YES];
    [anim setInterval:0.1];
    [anim setDelay:delay];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        [imp setVisible:true];
    }];
}

- (void) hideImp: (YAImpersonator*) imp atTime: (float) delay
{
    YABlockAnimator* anim = [_world createBlockAnimator];
    [anim setOnce:YES];
    [anim setInterval:0.1];
    [anim setDelay:delay];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        [imp setVisible:false];
    }];
}


- (void) impDebug: (YAImpersonator*) imp
{
    
    __block bool sizeInc = false;
    __block bool sizeDec = false;

    __block float xSpeed = 0;
    __block float ySpeed = 0;
    __block float zSpeed = 0;
    __block float rSpeed = 0;


    __block float lastSP = 0;
    
    YABlockAnimator* anim = [_world createBlockAnimator];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        
        int evBin = message & 255;
        float evVal = (float)(message & 255) / 255.0f - 0.5f;
 
        switch (event.intValue) {
            case GAMEPAD_LEFT_Y:
                ySpeed = evVal / 2;
                break;
            case GAMEPAD_LEFT_X:
                xSpeed = evVal / 2;
                break;
            case GAMEPAD_RIGHT_Y:
                zSpeed = evVal / 2;
                break;
            case GAMEPAD_RIGHT_X:
                rSpeed = evVal;
                break;
            case GAMEPAD_BUTTON_A:
                if(evBin == 1)
                    sizeInc = true;
                else
                    sizeInc = false;
                break;
            case GAMEPAD_BUTTON_B:
                if(evBin == 1)
                    sizeDec = true;
                else
                    sizeDec = false;
                break;
            case GAMEPAD_BUTTON_OK:
                break;
            case GAMEPAD_BUTTON_CANCEL:
                if(evBin == 1) {
                    // NSLog(@"translation:\n %@", imp.translation);
                    // NSLog(@"rotation:\n %@", imp.rotation);
                    // NSLog(@"size:\n %@", imp.size);
                }
                break;
            default:
                break;
        }
        
        const float moveFactor = 0.1;
        const float resizeFactor = 0.001;
        if(sizeInc)
            [[imp size] setValues:imp.size.x + resizeFactor :imp.size.y + resizeFactor :imp.size.z  + resizeFactor];
        
        if(sizeDec)
            [[imp size] setValues:imp.size.x - resizeFactor :imp.size.y - resizeFactor :imp.size.z  - resizeFactor];
        
        if(lastSP != sp){
            if(fabs(xSpeed) > 0.02)
                [imp.translation setX: imp.translation.x + xSpeed * moveFactor];
            
            if(fabs(ySpeed) > 0.02)
                [imp.translation setZ: imp.translation.z - ySpeed * moveFactor];
            
            if(fabs(zSpeed) > 0.02)
                [imp.translation setY: imp.translation.y - zSpeed * moveFactor];


            if(fabs(rSpeed) > 0.02)
                [imp.rotation setY: imp.rotation.y - rSpeed];

            lastSP = sp;
        }
    }];
}

- (void) impDebug: (YAImpersonator*) imp relativeTo: (YAVector3f*) origin
{
    
    __block bool sizeInc = false;
    __block bool sizeDec = false;
    
    __block float xSpeed = 0;
    __block float ySpeed = 0;
    __block float zSpeed = 0;
    __block float rSpeed = 0;
    
    
    __block float lastSP = 0;
    
    YABlockAnimator* anim = [_world createBlockAnimator];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        
        int evBin = message & 255;
        float evVal = (float)(message & 255) / 255.0f - 0.5f;
        
        switch (event.intValue) {
            case GAMEPAD_LEFT_Y:
                ySpeed = evVal;
                break;
            case GAMEPAD_LEFT_X:
                xSpeed = evVal;
                break;
            case GAMEPAD_RIGHT_Y:
                zSpeed = evVal;
                break;
            case GAMEPAD_RIGHT_X:
                rSpeed = evVal;
                break;
            case GAMEPAD_BUTTON_A:
                if(evBin == 1)
                    sizeInc = true;
                else
                    sizeInc = false;
                break;
            case GAMEPAD_BUTTON_B:
                if(evBin == 1)
                    sizeDec = true;
                else
                    sizeDec = false;
                break;
            case GAMEPAD_BUTTON_OK:
                break;
            case GAMEPAD_BUTTON_CANCEL:
                if(evBin == 1) {
                    
                    YAVector3f* offset = [[YAVector3f alloc] initCopy:origin];
                    [offset subVector:imp.translation];
                    
                    // NSLog(@"translation:\n %@", offset);
                    // NSLog(@"rotation:\n %@", imp.rotation);
                    // NSLog(@"size:\n %@", imp.size);
                }
                break;
            default:
                break;
        }
        
        
        const float resizeFactor = 0.02;
        if(sizeInc)
            [[imp size] setValues:imp.size.x + resizeFactor :imp.size.y + resizeFactor :imp.size.z  + resizeFactor];
        
        if(sizeDec)
            [[imp size] setValues:imp.size.x - resizeFactor :imp.size.y - resizeFactor :imp.size.z  - resizeFactor];
        
        if(lastSP != sp){
            if(fabs(xSpeed) > 0.02)
                [imp.translation setX: imp.translation.x + xSpeed * 0.2];
            
            if(fabs(ySpeed) > 0.02)
                [imp.translation setZ: imp.translation.z - ySpeed  * 0.2];
            
            if(fabs(zSpeed) > 0.02)
                [imp.translation setY: imp.translation.y - zSpeed  * 0.2];
            
            
            if(fabs(rSpeed) > 0.02)
                [imp.rotation setY: imp.rotation.y - rSpeed];
            
            lastSP = sp;
        }
    }];
}

- (void) cameraDebugRelativeTo: (YAVector3f*) position
{
    __block float zSpeed = 0;
    __block float xSpeed = 0;
    __block float atlasSpeed = 0;
    __block float axisSpeed = 0;
    __block float upSpeed = 0;
    __block float lastSP = 0;
    
    YABlockAnimator* moverCam = [_world createBlockAnimator];
    [moverCam addListener:^(float sp, NSNumber *event, int message) {
        
        
        const float axaTOf = 1.0;
        const float mvOf = 0.15;
        const float elvSp = 0.025f;
        
        int evBin = message & 255;
        float evVal = (float)(message & 255) / 255.0f - 0.5f;
        
        switch (event.intValue) {
            case GAMEPAD_LEFT_Y:
                zSpeed = -(evVal * mvOf);
                break;
            case GAMEPAD_LEFT_X:
                xSpeed = (evVal* mvOf);
                break;
            case GAMEPAD_RIGHT_Y:
                atlasSpeed = -(evVal * axaTOf);
                break;
            case GAMEPAD_RIGHT_X:
                axisSpeed = (evVal * axaTOf);
                break;
            case GAMEPAD_BUTTON_A:
                if(evBin == 1)
                    upSpeed = -elvSp;
                else
                    upSpeed = 0;
                break;
            case GAMEPAD_BUTTON_B:
                if(evBin == 1)
                    upSpeed = elvSp;
                else
                    upSpeed = 0;
                break;
            case GAMEPAD_BUTTON_OK:
                break;
            case GAMEPAD_BUTTON_CANCEL:
                if(evBin == 1) {

                    YAVector3f* pos = [[YAVector3f alloc] initCopy:_avatar.position];
                    [pos subVector:position];
                    // NSLog(@"relativeOffset: %@", pos);
                    // NSLog(@"\nAvatar:\n %@", _avatar);
                    // NSLog(@"\nSpotlight:\n %@", _spotLight);
                    // NSLog(@"\nLight:\n %@", _light);
                    
                }
            default:
                break;
        }
        
        
        [_avatar.position setY:_avatar.position.y + upSpeed];
        [_avatar setStepSize:fmaxf(fabsf(xSpeed), fabsf(zSpeed))];
        [_avatar setMoveForward:false];
        [_avatar setMoveBackward: false];
        [_avatar setMoveLeft:false];
        [_avatar setMoveRight: false];
        
        
        if(lastSP != sp) {
            if(fabsf(zSpeed) > fabsf(xSpeed)) {
                if(zSpeed > 0.01)
                    [_avatar setMoveForward:true];
                else if(zSpeed < -0.01)
                    [_avatar setMoveBackward: true];
            } else {
                if(xSpeed > 0.01)
                    [_avatar setMoveRight:true];
                else if(xSpeed < -0.01)
                    [_avatar setMoveLeft:true];
            }
            
            if(fabsf(atlasSpeed) > 0.1 || fabsf(axisSpeed) > 0.1)
                [_avatar setAtlas:_avatar.headAtlas - atlasSpeed axis:_avatar.headAxis + axisSpeed];
            else
                [_avatar setAtlas:_avatar.headAtlas axis:_avatar.headAxis ];
            
            lastSP = sp;
        }
        
    }];
}


- (void) cameraDebug
{
    __block float zSpeed = 0;
    __block float xSpeed = 0;
    __block float atlasSpeed = 0;
    __block float axisSpeed = 0;
    __block float upSpeed = 0;
    __block float lastSP = 0;
    
    YABlockAnimator* moverCam = [_world createBlockAnimator];
    [moverCam addListener:^(float sp, NSNumber *event, int message) {
        
        
        const float axaTOf = 1.0;
        const float mvOf = 0.15;
        const float elvSp = 0.025f;
        
        int evBin = message & 255;
        float evVal = (float)(message & 255) / 255.0f - 0.5f;
        
        switch (event.intValue) {
            case GAMEPAD_LEFT_Y:
                zSpeed = -(evVal * mvOf);
                break;
            case GAMEPAD_LEFT_X:
                xSpeed = (evVal* mvOf);
                break;
            case GAMEPAD_RIGHT_Y:
                atlasSpeed = -(evVal * axaTOf);
                break;
            case GAMEPAD_RIGHT_X:
                axisSpeed = (evVal * axaTOf);
                break;
            case GAMEPAD_BUTTON_A:
                if(evBin == 1)
                    upSpeed = -elvSp;
                else
                    upSpeed = 0;
                break;
            case GAMEPAD_BUTTON_B:
                if(evBin == 1)
                    upSpeed = elvSp;
                else
                    upSpeed = 0;
                break;
            case GAMEPAD_BUTTON_OK:
                break;
            case GAMEPAD_BUTTON_CANCEL:
                if(evBin == 1) {
                    // NSLog(@"\nAvatar:\n %@", _avatar);
                    // NSLog(@"\nSpotlight:\n %@", _spotLight);
                    // NSLog(@"\nLight:\n %@", _light);
                    
                }
            default:
                break;
        }
        
        
        [_avatar.position setY:_avatar.position.y + upSpeed];
        [_avatar setStepSize:fmaxf(fabsf(xSpeed), fabsf(zSpeed))];
        [_avatar setMoveForward:false];
        [_avatar setMoveBackward: false];
        [_avatar setMoveLeft:false];
        [_avatar setMoveRight: false];
        
        
        if(lastSP != sp) {
            if(fabsf(zSpeed) > fabsf(xSpeed)) {
                if(zSpeed > 0.01)
                    [_avatar setMoveForward:true];
                else if(zSpeed < -0.01)
                    [_avatar setMoveBackward: true];
            } else {
                if(xSpeed > 0.01)
                    [_avatar setMoveRight:true];
                else if(xSpeed < -0.01)
                    [_avatar setMoveLeft:true];
            }
            
            if(fabsf(atlasSpeed) > 0.1 || fabsf(axisSpeed) > 0.1)
                [_avatar setAtlas:_avatar.headAtlas - atlasSpeed axis:_avatar.headAxis + axisSpeed];
            else
                [_avatar setAtlas:_avatar.headAtlas axis:_avatar.headAxis ];
            
            lastSP = sp;
        }
        
    }];
}

- (void) lightDebug: (bool) isSpotLight
{
    __block float zSpeed = 0;
    __block float xSpeed = 0;
    __block float lastSP = 0;
    __block float ySpeed = 0;
    __block float zSpeedB = 0;
    __block float xSpeedB = 0;
    __block float ySpeedB = 0;
    
    __block YAVector3f* newDirection = [[YAVector3f alloc] initVals:0 :-1 :0];
    
    if(isSpotLight)
        [[_spotLight direction] setVector:newDirection];
    
    [debugLampImp setVisible:true];
    
    
    YABlockAnimator* moverLight = [_world createBlockAnimator];
    [moverLight addListener:^(float sp, NSNumber *event, int message) {
        
        const float evSp = 0.2;
        const float mp = 0.25;
        
        int evBin = message & 255;
        float evVal = (float)(message & 255) / 255.0f - 0.5f;
        
        switch (event.intValue) {
            case SPACE:
                // NSLog(@"\nAvatar:\n %@", _avatar);
                // NSLog(@"\nSpotlight:\n %@", _spotLight);
                // NSLog(@"\nLight:\n %@", _light);
                break;
            case GAMEPAD_LEFT_Y:
                zSpeed =  evVal;
                break;
            case GAMEPAD_LEFT_X:
                xSpeed = evVal;
                break;
            case GAMEPAD_RIGHT_Y:
                zSpeedB = evVal;
                break;
            case GAMEPAD_RIGHT_X:
                xSpeedB = evVal;
                break;
            case GAMEPAD_BUTTON_A:
                if(evBin == 1)
                    ySpeed = -evSp;
                else
                    ySpeed = 0;
                break;
            case GAMEPAD_BUTTON_B:
                if(evBin == 1)
                    ySpeed = evSp;
                else
                    ySpeed = 0;
                break;
            case GAMEPAD_BUTTON_OK:
                if(evBin == 1) {
                    if(isSpotLight)
                        ySpeedB = -evSp;
                    else
                        [_light setDirectional:!_light.directional];
                } else
                    ySpeedB = 0;
                break;
            case GAMEPAD_BUTTON_CANCEL:
                if(evBin == 1)
                    ySpeedB = evSp;
                else
                    ySpeedB = 0;
                break;
            default:
                break;
        }
        
        
        if((fabs(xSpeed) > 0.01f || fabs(zSpeed) > 0.01f || fabs(ySpeed) > 0.01f) && lastSP != sp) {
            
            if(isSpotLight) {
                [_spotLight.position setX: _spotLight.position.x + xSpeed * mp];
                [_spotLight.position setY: _spotLight.position.y + ySpeed * mp];
                [_spotLight.position setZ: _spotLight.position.z - zSpeed * mp];
                [[debugLampImp translation] setValues:_spotLight.position.x :_spotLight.position.y :_spotLight.position.z ];
                [self updateSpotLightFrustum];
                
            } else {
                [[_light position] setX: _light.position.x + xSpeed * mp];
                [[_light position] setY: _light.position.y + ySpeed * mp];
                [[_light position] setZ: _light.position.z - zSpeed * mp];
                [[debugLampImp translation] setValues:_light.position.x :_light.position.y :_light.position.z ];
                
                
            }
            
            
        }
        
        if((fabs(xSpeedB) > 0.01f || fabs(zSpeedB) > 0.01f || fabs(ySpeedB) > 0.01f) && lastSP != sp && isSpotLight) {
            [newDirection rotate:xSpeedB * 1.2 axis:[[YAVector3f alloc] initZAxe]];
            [newDirection rotate:zSpeedB * 1.2 axis:[[YAVector3f alloc] initXAxe]];
            [_spotLight.direction setVector:newDirection];
            
            [_spotLight setCutoff: _spotLight.cutoff + ySpeedB];
            
            [[debugLampImp rotation] setZ: debugLampImp.rotation.z + xSpeedB * 1.2];
            [[debugLampImp rotation] setX: debugLampImp.rotation.x + zSpeedB * 1.2];
        }
        
        lastSP = sp;
    }];
    
}

- (YAImpersonator*) genTextBlocked: (NSString*) text
{
    __block int textImpersonatorId = -1; 
    
    YABlockAnimator* anim = [_world createBlockAnimator];
    anim.oneExecution = YES;
    [anim addListener:^(float sp, NSNumber *event, int message) {
            textImpersonatorId = [_world createImpersonatorFromText: text];
    }];

    YAChronograph* chronograph = [[YAChronograph alloc] init];
    for(int i = 0; i < 5; i++) {
        if(textImpersonatorId != -1)
            break;    
        [chronograph wait:1.0f/60.0f];
    }

    YAImpersonator* textImp = [_world getImpersonator:textImpersonatorId];

    if(!textImp)
        return nil;
    
    [textImp setShadowCaster:NO];
    [textImp setClickable:NO];
    
    [[textImp translation] setVector: [[YAVector3f alloc] initVals: 0 : 0 : 0]];
    [textImp resize:0.3];
    [[textImp rotation] setVector: [[YAVector3f alloc] initVals:90: 0 : 0]];
    
    [[[textImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0 : 0 : 0 ]];
    [[[textImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[textImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[textImp material] setPhongShininess: 20];
    
    [[[textImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.5 : 0.2 : 0.2 ]];
    [textImp setClickable:false];;
    
    return textImp;
}


- (YAImpersonator*) genText: (NSString*) text
{

    int textImpersonatorId = [_world createImpersonatorFromText: text];
    YAImpersonator* textImp = [_world getImpersonator:textImpersonatorId];
    
    [textImp setShadowCaster:NO];
    [textImp setClickable:NO];
    
    [[textImp translation] setVector: [[YAVector3f alloc] initVals: 0 : 0 : 0]];
    [textImp resize:0.3];
    [[textImp rotation] setVector: [[YAVector3f alloc] initVals:90: 0 : 0]];
    
    [[[textImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0 : 0 : 0 ]];
    [[[textImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[textImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[textImp material] setPhongShininess: 20];
    
    [[[textImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.5 : 0.2 : 0.2 ]];
    [textImp setClickable:false];;
    
    return textImp;
}

- (NSArray*) createPlayerColorRings: (YAGameContext*) gameContext
{
    // NSLog(@"Create player rings.");
    
    NSMutableArray* imps = [[NSMutableArray alloc] initWithCapacity:4];
    
    for(int playerId = 0; playerId < 4; playerId++) {
        int impId = [_world createImpersonator:@"playerColorRing"];
        YAImpersonator* imp = [_world getImpersonator:impId];
        [imp setVisible:false];

        YAVector3f* color = [[gameContext colorVectors] objectAtIndex:[gameContext getColorForPlayer:playerId]];
        [[[imp material] phongAmbientReflectivity] setVector:color];
        [[[imp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
        [[[imp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
        [[imp material] setPhongShininess: 20];
        
        [imps addObject:imp];
    }
    
    return [[NSArray alloc] initWithArray:imps];
}

- (NSArray*) createPlayerColorChart: (YAGameContext*) gameContext
{
    NSMutableArray* imps = [[NSMutableArray alloc] initWithCapacity:4];
    
    for(int playerId = 0; playerId < 4; playerId++) {
        int impId = [_world createImpersonator:@"Cylinder"];
        YAImpersonator* imp = [_world getImpersonator:impId];
        [imp setVisible:false];
        
        YAVector3f* color = [[gameContext colorVectors] objectAtIndex:[gameContext getColorForPlayer:playerId]];
        [[[imp material] phongAmbientReflectivity] setVector:color];

        const float diffuse = -0.46;
        const float specular = 0.65;

        [[[imp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: diffuse : diffuse : diffuse ]];
        [[[imp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: specular : specular : specular ]];
        [[imp material] setPhongShininess:5];
        imp.material.reflection = 0.65;
        imp.material.refraction = 0.0;
        
        [imps addObject:imp];
    }


    return [[NSArray alloc] initWithArray:imps];
}


- (NSArray*) createPlayerColorBalls: (YAGameContext*) gameContext
{
    // NSLog(@"Create player balls.");
    
    NSArray* models = [[NSArray alloc] initWithObjects:
              @"BallColorA", @"BallColorB", @"BallColorC", @"BallColorD", @"BallColorE", @"BallColorF", @"BallColorG", @"BallColorH" , nil ];

    NSMutableArray* imps = [[NSMutableArray alloc] initWithCapacity:4];
    
    for(int playerId = 0; playerId < 4; playerId++) {
        int colorId = [gameContext getColorForPlayer:playerId];

        int impId = [_world createImpersonator:[models objectAtIndex:colorId]];
        YAImpersonator* imp = [_world getImpersonator:impId];
        [imp setVisible:false];
        [[imp translation] setValues:0 :1 :0];
        
        [imps addObject:imp];
    }
    
    return [[NSArray alloc] initWithArray:imps];
}


- (void) materialDebug: (YAImpersonator*) imp
{
    __block float yLPadPos = 0;
    __block float xLPadPos = 0;
    
    __block float yRPadPos = 0;
    __block float xRPadPos = 0;
    
    YABlockAnimator* colorDebug = [_world createBlockAnimator];
    [colorDebug addListener:^(float sp, NSNumber *event, int message) {
        int evBin = message & 255;
        float evVal = (float)(message & 255) / 255.0f - 0.5f;
        
        YAVector3f* ambient = [[imp material] phongAmbientReflectivity];
        YAVector3f* diffuse = [[imp material] phongDiffuseReflectivity];
        YAVector3f* specular = [[imp material] phongSpecularReflectivity];
        
        
        switch (event.intValue) {
            case KEY_Q:
                imp.material.reflection += 0.005;
                break;
            case KEY_A:
                imp.material.reflection -= 0.005;
                break;
            case KEY_W:
                imp.material.refraction += 0.025;
                break;
            case KEY_S:
                imp.material.refraction -= 0.025;
                break;
            case KEY_E:
                imp.material.phongAmbientReflectivity.x += 0.025;
                break;
            case KEY_D:
                imp.material.phongAmbientReflectivity.x -= 0.025;
                break;
            case KEY_R:
                imp.material.phongAmbientReflectivity.y += 0.025;
                break;
            case KEY_F:
                imp.material.phongAmbientReflectivity.y -= 0.025;
                break;

            case KEY_T:
                imp.material.phongAmbientReflectivity.z += 0.025;
                break;
            case KEY_G:
                imp.material.phongAmbientReflectivity.z -= 0.025;
                break;
            case GAMEPAD_LEFT_Y:
                yLPadPos = evVal * 0.5f;
                break;
            case GAMEPAD_LEFT_X:
                xLPadPos = evVal * 0.5f;
                break;
            case GAMEPAD_RIGHT_Y:
                yRPadPos = evVal * 0.5f;
                break;
            case GAMEPAD_RIGHT_X:
                xRPadPos = evVal * 0.5f;
                break;
            case GAMEPAD_BUTTON_A:
                if(evBin == 1)
                    ;
                else
                    ;
                break;
            case GAMEPAD_BUTTON_B:
                if(evBin == 1)
                    ;
                else
                    ;
                break;
            case SPACE:
                    // NSLog(@"ambient: %@", ambient);
                    // NSLog(@"diffuse: %@", diffuse);
                    // NSLog(@"specular: %@", specular);
                    // NSLog(@"shininess: %f", imp.material.phongShininess);
                    // NSLog(@"reflection: %f", imp.material.reflection);
                    // NSLog(@"refraction: %f", imp.material.refraction);
                break;
            case GAMEPAD_BUTTON_OK:
                if(evBin == 1) {
                    // NSLog(@"ambient: %@", ambient);
                    // NSLog(@"diffuse: %@", diffuse);
                    // NSLog(@"specular: %@", specular);
                    // NSLog(@"shininess: %f", imp.material.phongShininess);
                    // NSLog(@"reflection: %f", imp.material.reflection);
                    // NSLog(@"refraction: %f", imp.material.refraction);
                } else
                    ;
                break;
            case GAMEPAD_BUTTON_CANCEL:
                if(evBin == 1) {
                    [[[imp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.6f : 0.6f : 0.6f ]];
                    [[[imp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
                    [[[imp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
                    [[imp material] setPhongShininess: 10.0f];
                } else
                    ;
                break;
            default:
                break;
        }
        
        const float ds = 0.035;
        const float mg = 0.01;
        
        if(fabs(yLPadPos) > mg)
            [ambient setValues:ambient.x - yLPadPos * ds :ambient.y - yLPadPos  * ds :ambient.z - yLPadPos  * ds];
        if(fabs(xLPadPos) > mg)
            [diffuse setValues:diffuse.x + xLPadPos * ds :diffuse.y + xLPadPos  * ds :diffuse.z + xLPadPos  * ds];
        if(fabs(yRPadPos) > mg)
            [specular setValues:specular.x - yRPadPos * ds :specular.y - yRPadPos  * ds :specular.z - yRPadPos  * ds];
        if(fabs(xRPadPos) > mg)
            [[imp material] setPhongShininess: imp.material.phongShininess + xRPadPos * 0.15];
    }];

}

- (float) rotatateAvatar: (float) myTime
{
    float newTime = myTime;
    for(int pos = AVATAR_FRONT_GAMEBOARD; pos <= AVATAR_TABLE_DEBUG; pos++) {
        [self moveAvatarPositionTo:pos At:newTime];
        newTime += 2;
    }
    return newTime;
}

- (void) frustumDebug
{
    
    YABlockAnimator* frustumDebug = [_world createBlockAnimator];
    
    __block float yLPadPos = 0;
    __block float yRPadPos = 0;
    
    __block float lastSP = -1;
    __block int multiplier = 1;
    const float zeroZone = 0.05f;
    
    
    [frustumDebug addListener:^(float sp, NSNumber *event, int message) {
       
        int evBin = message & 255;
        float evVal = (float)(message & 255) / 255.0f - 0.5f;
        
        switch (event.intValue) {
            case GAMEPAD_LEFT_Y:
                yLPadPos = evVal;
                break;
            case GAMEPAD_RIGHT_Y:
                yRPadPos = evVal;
                break;
            case GAMEPAD_BUTTON_OK:
                if(evBin == 1)
                    // NSLog(@"%@", _world.transformer.projectionInfo);
                break;
            case GAMEPAD_BUTTON_A:
                if(evBin == 1)
                    multiplier = 10;
                else
                    multiplier = 1;
                break;
            default:
                break;
        }

        if(lastSP != sp) {
            lastSP = sp;
            if(fabs(yLPadPos) > zeroZone) {
                _world.transformer.projectionInfo.zNear -= yLPadPos * multiplier;
                [[_world transformer] recalcCam];
                // NSLog(@"%@", _world.transformer.projectionInfo);
            } else if (fabs(yRPadPos) > zeroZone) {
                _world.transformer.projectionInfo.zFar -= yRPadPos * multiplier;
                [[_world transformer] recalcCam];
                // NSLog(@"%@", _world.transformer.projectionInfo);
            }
            
        }
    }];
}

- (void) updateSpotLightFrustum
{
    YABlockAnimator* anim = [_world createBlockAnimator];
    [anim setOneExecution:YES];
    [anim setDelay:0];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        [self updateSpotLightFrustumUnblocked];
    }];
}

- (void) updateSpotLightFrustumUnblocked
{
    NSArray* trapezoid = [[_world transformer] trapezoid];

    float minDist = FLT_MAX;
    float maxDist = FLT_MIN;
    
    YAVector3f* spotLightPos = _spotLight.position;
    
    for(YAVector3f* vec in trapezoid) {
        const float distance = [spotLightPos distanceTo:vec];
        if(distance < minDist)
            minDist = distance;
        else if(distance > maxDist)
            maxDist = distance;
    }
    
    const float magic = 2;
    if(minDist < maxDist) {
        _world.shadowTransformer.projectionInfo.zNear = minDist > 3 ? minDist - magic : 1;

        _world.shadowTransformer.projectionInfo.zFar = maxDist + magic;
        [[_world shadowTransformer] recalcCam];
    }
}



- (void) updateSpotLightFrustumAt: (float) myTime
{
    YABlockAnimator* anim = [_world createBlockAnimator];
    [anim setOneExecution:YES];
    [anim setDelay:myTime];
    [anim addListener:^(float sp, NSNumber *event, int message) {
        [self updateSpotLightFrustum];
    }];
}

@end
