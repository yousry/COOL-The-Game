//
//  YAInGameStage.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 03.04.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#include <bsd/stdlib.h>

#import "YAOpenAL.h"

// utility class for imp transfer
#import "YAImpCollector.h"
#import "YASoundCollector.h"

// event management
#import "YADevelopmentEvent.h"
#import "YAMapEvents.h"
#import "YAInfoEvents.h"
#import "YAMoonClockEvent.h"
#import "YAMainEvents.h"
#import "YAEagleFlightEvents.h"
#import "YAShopEvent.h"
#import "YACounterEvent.h"
#import "YASocketEvents.h"
#import "YAProductionEvent.h"

#import "YAEventChain.h"
#import "YATrigger.h"
#import "YATimerTrigger.h"
#import "YAEventChain.h"
#import "YAEvent.h"
#import "YASituation.h"
#import "YACondition.h"

#import "YAProbability.h"
#import "YAStore.h"
#import "YABulletEngineTranslator.h"
#import "YAEagleController.h"
#import "YAEagleAssembler.h"
#import "YAShopAssembler.h"
#import "YAMapManagement.h"
#import "YAPlotAuction.h"
#import "YAIngredientSetup.h"
#import "YATerrainEditor.h"
#import "YAColonyMap.h"
#import "YASceneUtils.h"
#import "YATransformator.h"
#import "YAPerspectiveProjectionInfo.h"
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
#import "YAImpersonator+Physic.h"
#import "YAVector4f.h"
#import "YAVector3f.h"
#import "YAVector2f.h"
#import "YAMatrix4f.h"
#import "YABasicAnimator.h"
#import "YABlockAnimator.h"
#import "YASpotLight.h"
#import "YALight.h"
#import "YAGouradLight.h"
#import "YAMaterial.h"
#import "YATriangleGrid.h"
#import "YATerrain.h"
#import "YARenderLoop.h"
#import "YAIntroStage.h"
#import "YAImpGroup.h"
#import "YAGameContext.h"
#import "YAGameStateMachine.h"

#import "YAInGameStage.h"

#define ToDegree(x) ((x) * 180.0f / M_PI)

@implementation YAInGameStage
@synthesize gameContext;

- (id) initWithWorld: (YARenderLoop*) pWorld StateMachine: (YAGameStateMachine*) pStateMachine
{
    self = [super init];
    
    if(self) {
        renderLoop = pWorld;
        stateMachine = pStateMachine;
        
        _ic = [[YAImpCollector alloc] init];
        _eventChain = [[YAEventChain alloc] init];
        _mainEvents = [[YAMainEvents alloc] init];
        _moonClockEvent = [[YAMoonClockEvent alloc] init];
        _infoEvents = [[YAInfoEvents alloc] init];
        _mapEvents = [[YAMapEvents alloc] init];
        _eagleFlightEvent = [[YAEagleFlightEvents alloc] init];
        _shopEvent = [[YAShopEvent alloc] init];
        _counterEvent = [[YACounterEvent alloc] init];
        _socketEvents = [[YASocketEvents alloc] init];
        _developmentEvent = [[YADevelopmentEvent alloc] init];
        _productionEvent = [[YAProductionEvent alloc] init];
    }
    
    return self;
}

- (void) setupImps
{
    // add terrain to scene
    int terrainSize = 32;
    
    terrain = [[YATerrain alloc] initSize: terrainSize + 1];
    
    
    seed = ((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * 1000;
    [terrain generate: seed];
    
    [renderLoop createHeightmapTexture:terrain withName:@"terrainHeightMap"];
    
    NSString* terrainIngredientName = @"terrain";
    YAIngredient* terrainIngredient = [renderLoop createIngredient:terrainIngredientName];
    [terrainIngredient setFlavour:Terrain];
    [terrainIngredient setTexture:@"terrainHeightMap"];
    
    YATriangleGrid* grid = [[YATriangleGrid alloc] initWithDim:terrainSize];
    [terrainIngredient createModelfromGrid:[grid triangles:terrain]];
    
    int terrainImpId = [renderLoop createImpersonator:terrainIngredientName];
    terrainImp = [renderLoop getImpersonator:terrainImpId];
    
    [[terrainImp translation] setVector: [[YAVector3f alloc] initVals: 0 : 0 : 0]];
    [[terrainImp rotation] setVector: [[YAVector3f alloc] initVals: 0: 0 : 0]];
    [terrainImp resize:5.845];
    
    [[[terrainImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.6f : 0.6f : 0.6f ]];
    [[[terrainImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[terrainImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[terrainImp material] setPhongShininess: 20.0f];
    
    // depreicated uniforms reused for laser pointer
    terrainImp.material.reflection = 0;
    terrainImp.material.refraction = 0;
    terrainImp.material.specPower = 1.0f;
    
    [[terrainImp material] setEta:0.45];
    [terrainImp setShadowCaster:true];
    
    float cH = 2.3;
    int cursorInnerImpId = [renderLoop createImpersonator:@"cursorInner"];
    cursorInnerImp = [renderLoop getImpersonator:cursorInnerImpId];
    [[cursorInnerImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
    [cursorInnerImp resize:0.5];
    [[[cursorInnerImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.3f : 0.3f : 0.3f ]];
    [[[cursorInnerImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[cursorInnerImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.1f : 0.1f : 0.1f ]];
    [[cursorInnerImp material] setPhongShininess: 10.0f];
    cursorInnerImp.material.eta = 1;
    [[cursorInnerImp translation] setY:cH];
    [cursorInnerImp setShadowCaster:true];
    
    int cursorOuterImpId = [renderLoop createImpersonator:@"cursorOuter"];
    cursorOuterImp = [renderLoop getImpersonator:cursorOuterImpId];
    [[cursorOuterImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
    [cursorOuterImp resize:0.5];
    [[[cursorOuterImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.3f : 0.3f : 0.3f ]];
    [[[cursorOuterImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[cursorOuterImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.1f : 0.1f : 0.1f ]];
    [[cursorOuterImp material] setPhongShininess: 10.0f];
    cursorOuterImp.material.eta = 1;
    [[cursorOuterImp translation] setY:cH];
    [cursorOuterImp setShadowCaster:true];
    
    
    starImps = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < 3; i++) {
        int starId = [renderLoop createImpersonator:@"Star"];
        YAImpersonator* imp = [renderLoop getImpersonator:starId];
        [starImps addObject:imp];
        [[[imp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.8f : 0.559f : 0.0f ]];
        [[[imp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
        [[[imp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.1f : 0.1f : 0.1f ]];
        imp.material.eta = 1;
        
        if(i == 0) {
            [[imp translation] setValues:-5.543136 :4.250978 :-0.149020];
            [[imp rotation] setZ: 30];
            [imp resize:0.8];
            imp.size.z = 0.3f;
        } else if (i == 1) {
            [[imp translation] setValues:-6.747066 :3.449020 :-0.807845];
            [[imp rotation] setZ: 55];
            [imp resize:0.5];
            imp.size.z = 0.3f;
        } else if (i == 2) {
            [[imp translation] setValues:-4.462750 :3.245075 :1.149022];
            [[imp rotation] setZ: 0];
            [imp resize:0.7];
            imp.size.z = 0.3f;
        }
    }
    
    int planeImpId = [renderLoop createImpersonator:@"Plane"];
    planeImp = [renderLoop getImpersonator:planeImpId];
    [[planeImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
    [planeImp resize:4];
    [[planeImp translation] setY:0.01];
    [[[planeImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.0f : 0.0f : 0.0f ]];
    [[[planeImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.0f : 0.0f : 0.0f ]];
    [[[planeImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.0f : 0.0f : 0.0f ]];
    planeImp.material.eta = 1;
    
    int MoonImpId = [renderLoop createImpersonator:@"Moon"];
    moonImp = [renderLoop getImpersonator:MoonImpId];
    [[moonImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
    [moonImp resize:0.5];
    [[[moonImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.3f : 0.3f : 0.3f ]];
    [[[moonImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[moonImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.1f : 0.1f : 0.1f ]];
    [[moonImp material] setPhongShininess: 10.0f];
    [[moonImp translation] setY:4];
    [[moonImp translation] setX:4];
    [moonImp setShadowCaster:false];
    
    int SunImpId = [renderLoop createImpersonator:@"Sun"];
    sunImp = [renderLoop getImpersonator:SunImpId];
    [[sunImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
    [sunImp resize:0.8];
    [[[sunImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 1.0f : 1.5f : 1.0f ]];
    [[[sunImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[sunImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[sunImp material] setPhongShininess: 10.0f];
    [[sunImp translation] setY:4];
    [[sunImp translation] setX:-0.5];
    [sunImp setShadowCaster:false];
    
    int barrackImpId = [renderLoop createImpersonator:@"Barrack"];
    barrackImp = [renderLoop getImpersonator:barrackImpId];
    [[barrackImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 90 : 0]];
    [barrackImp resize:0.5];
    [[[barrackImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[barrackImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[barrackImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[barrackImp material] setPhongShininess: 10.0f];
    [[barrackImp translation] setY:0.1];
    [barrackImp setShadowCaster:true];
    
    int SunCoverImpId = [renderLoop createImpersonator:@"SunCover"];
    sunCoverImp = [renderLoop getImpersonator:SunCoverImpId];
    [[sunCoverImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
    [sunCoverImp resize:0.8];
    [[[sunCoverImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.3f : 0.3f : 0.3f ]];
    [[[sunCoverImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[sunCoverImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[sunCoverImp material] setPhongShininess: 10.0f];
    [[sunCoverImp translation] setY:4];
    [[sunCoverImp translation] setX:-0.5];
    [sunCoverImp setShadowCaster:false];
    
    int deskImpId = [renderLoop createImpersonator:@"DeskHole"];
    deskImp = [renderLoop getImpersonator:deskImpId];
    [[deskImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
    [deskImp resize:3];
    [[[deskImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.35f : 0.35f : 0.35f ]];
    [[[deskImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[deskImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[deskImp material] setPhongShininess: 10.0f];
    [[deskImp translation] setY:-0.1];
    [deskImp setShadowCaster:false];
    
    int boardImpId = [renderLoop createImpersonator:@"PlayboardGame"];
    boardImp = [renderLoop getImpersonator:boardImpId];
    [[boardImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
    [boardImp resize:3];
    [[[boardImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.8f : 0.0f : 0.009204f ]];
    [[[boardImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.446809 : 0 : 0 ]];
    [[[boardImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[boardImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[boardImp material] setPhongShininess: 10.0f];
    [[boardImp translation] setY:-0.015];
    
    
    int boardTitleImpId = [renderLoop createImpersonator:@"PlayboardTitle"];
    boardTitleImp = [renderLoop getImpersonator:boardTitleImpId];
    [[boardTitleImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
    [boardTitleImp resize:3];
    [[[boardTitleImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[boardTitleImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[boardTitleImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[boardTitleImp material] setPhongShininess: 10.0f];
    [[boardTitleImp translation] setY:-0.015];
    
    int spaceShipId = [renderLoop createImpersonator:@"SpaceShip"];
    spaceShipImp = [renderLoop getImpersonator:spaceShipId];
    [[spaceShipImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 0 : 0]];
    [spaceShipImp resize:0.25];
    [[[spaceShipImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[spaceShipImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[spaceShipImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[spaceShipImp material] setPhongShininess: 10.0f];
    [[spaceShipImp translation] setY:0];
    
    
    int coffeeCupId = [renderLoop createImpersonator:@"CoffeeCup"];
    coffeeCupImp = [renderLoop getImpersonator:coffeeCupId];
    [[coffeeCupImp rotation] setVector: [[YAVector3f alloc] initVals: -90 :166 :0]];
    [coffeeCupImp resize:1.25];
    
    float df = 1;
    float sp = 0.2;
    
    [[[coffeeCupImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.740000 : 0.715000 : 0.765000 ]];
    [[[coffeeCupImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: df : df : df ]];
    [[[coffeeCupImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: sp : sp : sp ]];
    [[coffeeCupImp material] setPhongShininess: 40.0f];
    [[coffeeCupImp material] setReflection: 0.01f];
    [[coffeeCupImp material] setRefraction: 0.325f];
    
    [[coffeeCupImp translation] setValues:-3.272554 :-0.099 :10.096041];
    [coffeeCupImp setShadowCaster:true];
    
    
    int tableId = [renderLoop createImpersonator:@"table"];
    tableImp = [renderLoop getImpersonator:tableId];
    [[[tableImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[tableImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[tableImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[tableImp material] setPhongShininess: 10.0f];
    [[tableImp translation] setValues:17.694117 :-0.09 :-15.029452];
    [[tableImp rotation] setValues:-90 :178.900574 :0.000000];
    [tableImp resize:2.899998];
    
    
    
    int wallId = [renderLoop createImpersonator: @"Wall"];
    wallImp = [renderLoop getImpersonator:wallId];
    [[wallImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : 0.0f]];
    [[wallImp translation] setVector: [[YAVector3f alloc] initVals: 0.0f : -0.1f : 0.0f]];
    [[wallImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    [wallImp resize:3];
    [[[wallImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.961442 : 0.961442 : 0.961442 ]];
    [[[wallImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.314711 : 0.314711 : 0.314711 ]];
    [[[wallImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0 : 0 : 0 ]];
    [[wallImp material] setPhongShininess: 10.0f];
    
    
    int bookshelfId = [renderLoop createImpersonator: @"Bookshelf"];
    bookshelfImp = [renderLoop getImpersonator:bookshelfId];
    [[bookshelfImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : 0.0f]];
    [[bookshelfImp translation] setVector: [[YAVector3f alloc] initVals: 12.503926 : -0.100000 : 26.490189]];
    
    
    [bookshelfImp resize:2.899998];
    [[[bookshelfImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[bookshelfImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[bookshelfImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[bookshelfImp material] setPhongShininess: 10.0f];
    
    
    int booksLevelAId = [renderLoop createImpersonator: @"booksLevelA"];
    booksLevelAImp = [renderLoop getImpersonator:booksLevelAId];
    [[booksLevelAImp rotation] setVector: [[YAVector3f alloc] initVals: -179.99999567428898f : 0.0f : -0.0f]];
    [[[booksLevelAImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[booksLevelAImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[booksLevelAImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[booksLevelAImp material] setPhongShininess: 10.0f];
    
    
    int booksLevelBId = [renderLoop createImpersonator: @"booksLevelB"];
    booksLevelBImp = [renderLoop getImpersonator:booksLevelBId];
    [[booksLevelBImp rotation] setVector: [[YAVector3f alloc] initVals: -179.99999567428898f : 0.0f : -0.0f]];
    [[[booksLevelBImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[booksLevelBImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[booksLevelBImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[booksLevelBImp material] setPhongShininess: 10.0f];
    
    int booksLevelCId = [renderLoop createImpersonator: @"booksLevelC"];
    booksLevelCImp = [renderLoop getImpersonator:booksLevelCId];
    [[booksLevelCImp rotation] setVector: [[YAVector3f alloc] initVals: -179.99999567428898f : 0.0f : -0.0f]];
    [[[booksLevelCImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[booksLevelCImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[booksLevelCImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[booksLevelCImp material] setPhongShininess: 10.0f];
    
    [booksLevelCImp.translation setValues:12.574231 :2.747681 :23.851957];
    [booksLevelCImp resize:2.899998];
    
    [booksLevelBImp.translation setValues:12.574231 :8.031994 :23.851957];
    [booksLevelBImp resize:2.899998];
    
    [booksLevelAImp.translation setValues:12.574231 :13.402581 :23.851957];
    [booksLevelAImp resize:2.899998];
    
    int LedgeId = [renderLoop createImpersonator: @"Ledge"];
    LedgeImp = [renderLoop getImpersonator:LedgeId];
    [[LedgeImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : 0.0f]];
    [[LedgeImp translation] setVector: [[YAVector3f alloc] initVals: 0.0f : -0.1f : 0.0f]];
    [LedgeImp resize:3];
    
    [[LedgeImp.material phongAmbientReflectivity] setValues:0.434162  :0.435632 :0.225338 ];
    [[LedgeImp.material phongDiffuseReflectivity] setValues:0.108966  :0.108966 :0.108966 ];
    [[LedgeImp.material phongSpecularReflectivity] setValues:0.441904  :0.441904 :0.441904 ];
    [LedgeImp.material setPhongShininess:4];
    LedgeImp.material.eta = 1;
    
    
    int MagAId = [renderLoop createImpersonator: @"MagA"];
    MagAImp = [renderLoop getImpersonator:MagAId];
    [[MagAImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : -229.03894641932865f : -0.0f]];
    [[MagAImp translation] setVector: [[YAVector3f alloc] initVals: -13.762874 : -0.090 : 11.046548]];
    
    [MagAImp resize:3];
    [[[MagAImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[MagAImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[MagAImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    
    int MagBId = [renderLoop createImpersonator: @"MagB"];
    MagBImp = [renderLoop getImpersonator:MagBId];
    [[MagBImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 156.52035547282375f : -0.0f]];
    [[MagBImp translation] setVector: [[YAVector3f alloc] initVals: -10.755349 : -0.080 : 7.895782]];
    
    
    [[MagBImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    [MagBImp resize:3];
    [[[MagBImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[MagBImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[MagBImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    
    int PosterSharksId = [renderLoop createImpersonator: @"PosterSharks"];
    PosterSharksImp = [renderLoop getImpersonator:PosterSharksId];
    [[PosterSharksImp rotation] setVector: [[YAVector3f alloc] initVals: 180.00000068324533f : -90 : -0.7482187288794532f]];
    [[PosterSharksImp translation] setVector: [[YAVector3f alloc] initVals: 29.743181 : 17 : -7.792262]];
    [PosterSharksImp resize:5];
    [[[PosterSharksImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[PosterSharksImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[PosterSharksImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    
    int PosterSuperManId = [renderLoop createImpersonator: @"PosterSuperMan"];
    PosterSuperManImp = [renderLoop getImpersonator:PosterSuperManId];
    [[PosterSuperManImp rotation] setVector: [[YAVector3f alloc] initVals: 180.00000068324533f : -90 : -1.487613813846602f]];
    [[PosterSuperManImp translation] setVector: [[YAVector3f alloc] initVals: 29.743181 : 15 : 8]];
    [[PosterSuperManImp size] setVector: [[YAVector3f alloc] initVals: 2.100626230239868f :2.100626230239868f :2.100626230239868f]];
    [PosterSuperManImp resize:5];
    [[[PosterSuperManImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[PosterSuperManImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[PosterSuperManImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    
    int parachuteImpId = [renderLoop createImpersonator: @"Parachute"];
    parachuteImp = [renderLoop getImpersonator:parachuteImpId];
    [[parachuteImp rotation] setVector: [[YAVector3f alloc] initVals: -90 : 0 : 0]];
    [[parachuteImp translation] setVector: [[YAVector3f alloc] initVals: 0 : 2 : 0]];
    [[parachuteImp size] setVector: [[YAVector3f alloc] initVals: 1 :1 :1]];
    [[[parachuteImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[parachuteImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[parachuteImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [parachuteImp setBackfaceCulling:false];
    
    int podImpId = [renderLoop createImpersonator: @"EaglePod"];
    podImp = [renderLoop getImpersonator:podImpId];
    [[podImp rotation] setVector: [[YAVector3f alloc] initVals: -90 : 0 : 0]];
    [[podImp translation] setVector: [[YAVector3f alloc] initVals: 0 : 2 : 0]];
    [[podImp size] setVector: [[YAVector3f alloc] initVals: 1 :1 :1]];
    [[[podImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.3f : 0.3f : 0.3f ]];
    [[[podImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[podImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.1f : 0.1f : 0.1f ]];
    [podImp setBackfaceCulling:true];
    
    int shadowCupImpId = [renderLoop createImpersonator: @"shadowCup"];
    shadowCupImp = [renderLoop getImpersonator:shadowCupImpId];
    [[shadowCupImp rotation] setVector: [[YAVector3f alloc] initVals: -90 : 0 : 0]];
    [shadowCupImp resize:1];
    [[shadowCupImp translation] setValues:-4.655879 :-0.09 :11.022541];
    [shadowCupImp setShadowCaster:false];
    [[[shadowCupImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.0f : 0.0f : 0.0f ]];
    [[[shadowCupImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.0f : 0.0f : 0.0f ]];
    [[[shadowCupImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.0f : 0.0f : 0.0f ]];
    
    
    int shadowPlayBoardImpId = [renderLoop createImpersonator: @"shadowPlayBoard"];
    shadowPlayBoardImp = [renderLoop getImpersonator:shadowPlayBoardImpId];
    [[shadowPlayBoardImp rotation] setVector: [[YAVector3f alloc] initVals: -90 : 0 : 0]];
    [shadowPlayBoardImp resize:0.515];
    [[shadowPlayBoardImp translation] setValues:0:-0.09 :0];
    [shadowPlayBoardImp setShadowCaster:false];
    [[[shadowPlayBoardImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.0f : 0.0f : 0.0f ]];
    [[[shadowPlayBoardImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.0f : 0.0f : 0.0f ]];
    [[[shadowPlayBoardImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.0f : 0.0f : 0.0f ]];
    
    int shadowDeskImpId = [renderLoop createImpersonator: @"shadowDesk"];
    shadowDeskImp = [renderLoop getImpersonator:shadowDeskImpId];
    [[shadowDeskImp rotation] setVector: [[YAVector3f alloc] initVals: -90 : 0 : 0]];
    [[shadowDeskImp translation] setValues:13.512756:-0.09 :26.238729];
    [shadowDeskImp setShadowCaster:false];
    [[[shadowDeskImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.0f : 0.0f : 0.0f ]];
    [[[shadowDeskImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.0f : 0.0f : 0.0f ]];
    [[[shadowDeskImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.0f : 0.0f : 0.0f ]];
    
    
    int shadowTableImpId = [renderLoop createImpersonator: @"shadowTable"];
    shadowTableImp = [renderLoop getImpersonator:shadowTableImpId];
    [[shadowTableImp rotation] setVector: [[YAVector3f alloc] initVals: -90 : 0 : 0]];
    [shadowTableImp resize:1.687];
    shadowTableImp.size.y = 0.6;
    [[shadowTableImp translation] setValues:16.879400:-0.09 :-7.4];
    [shadowTableImp setShadowCaster:false];
    [[[shadowTableImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.0f : 0.0f : 0.0f ]];
    [[[shadowTableImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.0f : 0.0f : 0.0f ]];
    [[[shadowTableImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.0f : 0.0f : 0.0f ]];
    
    int stickSunId = [renderLoop createImpersonator:@"Stick"];
    stickSunImp = [renderLoop getImpersonator:stickSunId];
    [stickSunImp resize:0.8];
    [[[stickSunImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.342f : 0.202f : 0.07068f ]];
    [[[stickSunImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[stickSunImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.1f : 0.1f : 0.1f ]];
    [[stickSunImp material] setPhongShininess: 10.0f];
    stickSunImp.material.eta = 1;
    [[stickSunImp rotation] setVector: [[YAVector3f alloc] initVals: -90 : 0 : 0]];
    [stickSunImp setVisible:false];
    
    int stickMoonId = [renderLoop createImpersonator:@"Stick"];
    stickMoonImp = [renderLoop getImpersonator:stickMoonId];
    [stickMoonImp resize:0.5];
    [[[stickMoonImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.342f : 0.202f : 0.07068f ]];
    [[[stickMoonImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.2f : 0.2f : 0.2f ]];
    [[[stickMoonImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.1f : 0.1f : 0.1f ]];
    [[stickMoonImp material] setPhongShininess: 10.0f];
    stickMoonImp.material.eta = 1;
    [[stickMoonImp rotation] setVector: [[YAVector3f alloc] initVals: -90 : 0 : 0]];
    [stickMoonImp setVisible:false];
    
    int meteoridImpId = [renderLoop createImpersonator:@"Meteorid"];
    meteoridImp = [renderLoop getImpersonator:meteoridImpId];
    [[[meteoridImp material] phongAmbientReflectivity] setValues:.4 :.4 :.4];
    [[[meteoridImp material] phongDiffuseReflectivity] setValues:.3 :.3 :.3];
    [[[meteoridImp material] phongSpecularReflectivity] setValues:.15 :.15 :.15];
    [[meteoridImp material] setPhongShininess:15];
    [meteoridImp setVisible:false];
    
    int fireImpId = [renderLoop createImpersonator:@"fire"];
    fireImp = [renderLoop getImpersonator:fireImpId];
    [fireImp resize:0.61];
    [[fireImp material] setEta:0.85];
    fireImp.rotation.x = -90;
    [[[fireImp material] phongAmbientReflectivity] setValues:1 :1 :0];
    [[[fireImp material] phongDiffuseReflectivity] setValues:1 :0 :0];
    [[[fireImp material] phongSpecularReflectivity] setValues:0.1 :0.25 :0.01];
    fireImp.material.phongShininess = 5;
    fireImp.visible = false;
    
    
    int cloudNormalImpId = [renderLoop createImpersonator:@"cloud_normal"];
    cloudNormalImp = [renderLoop getImpersonator:cloudNormalImpId];
    [cloudNormalImp setVisible:false];
    
    int cloudLightningImpId = [renderLoop createImpersonator:@"cloud_lightning"];
    cloudLightningImp = [renderLoop getImpersonator:cloudLightningImpId];
    [cloudLightningImp setVisible:false];
    
    _ic.fireImp = fireImp;
    _ic.meteoriteImp = meteoridImp;
    _ic.cloudNormalImp = cloudNormalImp;
    _ic.cloudLightningImp = cloudLightningImp;
    _ic.tableImp = tableImp;
    _ic.stickSunImp = stickSunImp;
    _ic.stickMoonImp = stickMoonImp;
    _ic.terrainImp = terrainImp;
    _ic.cursorInnerImp = cursorInnerImp;
    _ic.cursorOuterImp = cursorOuterImp;
    _ic.moonImp = moonImp;
    _ic.sunImp = sunImp;
    _ic.sunCoverImp = sunCoverImp;
    _ic.deskImp = deskImp;
    _ic.boardImp =  boardImp;
    _ic.boardTitleImp = boardTitleImp;
    _ic.spaceShipImp = spaceShipImp;
    _ic.barrackImp = barrackImp;
    _ic.planeImp = planeImp;
    _ic.starImps = starImps;
    _ic.podImp = podImp;
    _ic.parachuteImp = parachuteImp;
}

- (void)setupLogic
{
    // events for this stage
    NSArray* logicEvents = [NSArray arrayWithObjects:
                            @"init",
                            @"standby",
                            @"setupStore",
                            @"spaceshipLands",
                            @"spaceshipStarts",
                            @"showScoreboard",
                            @"moonClockSetup",
                            @"moonClockShutdown",
                            @"moonClockShow",
                            @"moonClockHide",
                            @"roundsLeftInfo",
                            @"removeRoundsLeftInfo",
                            @"plotSelectionEvent",
                            @"plotAuction",
                            @"eagleFly",
                            @"shopping",
                            @"fiveSecondsCountDown",
                            @"fiveSecondsCountDownFinished",
                            @"gameTimer",
                            @"setupFab",
                            @"developmentEvent",
                            @"productionEvent",
                            @"comoditiesAuction",
                            @"roundTimeCountdown",
                            @"plotAssey",
                            nil];

    [_eventChain addEvents: logicEvents];
    
    // transport renderLoop data to the events
    
    
    _store = [[YAStore alloc] initInWorld:renderLoop
                                    utils:sceneUtils
                                   colony:colMap
                              gameContext:gameContext
                               eventChain:_eventChain];
    
    [_store setSoundCollector:_soundCollector];
    
    NSDictionary* eventInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                _ic, @"IMPCOLLECTOR",
                                sceneUtils , @"SCENEUTILS",
                                renderLoop , @"WORLD",
                                colMap, @"COLONYMAP",
                                terrain, @"TERRAIN",
                                gameContext, @"GAMECONTEXT",
                                be, @"PHYSICS",
                                _soundCollector, @"SOUNDCOLLECTOR",
                                _store, @"STORE",
                                nil];

    [_eventChain setEventInfo: eventInfo];
    
    // add listeners to the events (connect to the scenegraph via info)
    YAEvent* event = [_eventChain getEvent:@"standby"];
    [event addListener: _mainEvents.standByEvent];
    
    event = [_eventChain getEvent:@"setupStore"];
    [event addListener: _mainEvents.setupStoreEvent];
    
    event = [_eventChain getEvent:@"spaceshipLands"];
    [event addListener: _mainEvents.spaceshipLandEvent];
    
    event = [_eventChain getEvent:@"spaceshipStarts"];
    [event addListener: _mainEvents.spaceshipStartEvent];
    
    event = [_eventChain getEvent:@"showScoreboard"];
    [event addListener: _mainEvents.showScoreBoardEvent];
    
    event = [_eventChain getEvent:@"moonClockSetup"];
    [event addListener: _moonClockEvent.setupEvent];
    
    event = [_eventChain getEvent:@"moonClockShow"];
    [event addListener: _moonClockEvent.showEvent];
    
    event = [_eventChain getEvent:@"moonClockHide"];
    [event addListener: _moonClockEvent.hideEvent];
    
    event = [_eventChain getEvent:@"moonClockShutdown"];
    [event addListener: _moonClockEvent.shutdownEvent];
    
    event = [_eventChain getEvent:@"roundsLeftInfo"];
    [event addListener: _infoEvents.roundsleftEvent];
    
    event = [_eventChain getEvent:@"removeRoundsLeftInfo"];
    [event addListener: _infoEvents.removeRoundsleftEvent];
    
    event = [_eventChain getEvent:@"plotSelectionEvent"];
    [event addListener: _mapEvents.plotSelectionEvent];
    
    event = [_eventChain getEvent:@"plotAuction"];
    [event addListener: _mapEvents.plotAuctionEvent];
    
    event = [_eventChain getEvent:@"eagleFly"];
    [event addListener: _eagleFlightEvent.flyEvent];
    
    event = [_eventChain getEvent:@"shopping"];
    [event addListener: _shopEvent.shopEvent];
    
    event = [_eventChain getEvent:@"fiveSecondsCountDown"];
    [event addListener: _counterEvent.fiveSecondsCountdownEvent];
    
    event = [_eventChain getEvent:@"gameTimer"];
    [event addListener: _counterEvent.GameTimerEvent];
    
    event = [_eventChain getEvent:@"setupFab"];
    [event addListener: _socketEvents.setupFab];
    
    event = [_eventChain getEvent:@"developmentEvent"];
    [event addListener: _developmentEvent.developmentEvent];
    
    event = [_eventChain getEvent:@"productionEvent"];
    [event addListener:_productionEvent.productionEvent];
    
    event = [_eventChain getEvent:@"comoditiesAuction"];
    [event addListener: _mapEvents.comoditiesAuctionEvent];
    
    event = [_eventChain getEvent:@"roundTimeCountdown"];
    [event addListener: _counterEvent.roundTimeCountdownEvent];
    
    event = [_eventChain getEvent:@"plotAssey"];
    [event addListener: _socketEvents.plotAssayEvent];
    
    [_eventChain startEvent:@"standby" following:@"init" WithDelay:0.5];
    // [_eventChain startEvent:@"eagleFly" following:@"init" WithDelay:0.5];
    [_eventChain start];
}

- (void) setupScene
{
    // NSLog(@"Setup Scene");
    [renderLoop setOpenGLContextToThread];
         
    // Sound Setup
    _soundCollector = stateMachine.soundCollector;
    if(_soundCollector == nil) {
        stateMachine.soundCollector = [[YASoundCollector alloc] initInWorld:renderLoop];
        _soundCollector = stateMachine.soundCollector;
    }

    // Utility funcs
    sceneUtils = [[YASceneUtils alloc] initInWorld:renderLoop];
         
    // only for global State Machine
    sceneUtils.gameState = stateMachine;

    // Beware: Only once per Game
    [gameContext setupPlayerGameData: renderLoop];

    // TODO: remove
    // [gameContext setActivePlayer: 0];
    // [[gameContext playerDataForId:0] setMoney: 5000];

      
    // Load 3D Models for Scene
    [YAIngredientSetup ingame:renderLoop];
      
    // Set default camera positon
    [sceneUtils setAvatarPositionTo:AVATAR_FRONT_GAMEBOARD];
    [sceneUtils updateFrustumTo:AVATAR_FRONT_GAMEBOARD];

    // Set Light position and radiation
    [sceneUtils setLightPosition:sceneUtils.light to:LIGHT_NOON_RELAXED];

    [sceneUtils setRadiation:sceneUtils.light to:EMISSION_WHITE_FULL];
    [[sceneUtils light] setDirectional:true];

    // Set Spotlight position, cutoff and radiation
    [sceneUtils setLightPosition:sceneUtils.spotLight to:LIGHT_ROOM_SPOT];
    [sceneUtils.spotLight spotAt:[[YAVector3f alloc] initVals:1 :0 :0]];

    [sceneUtils.spotLight setCutoff:14.0];
    [sceneUtils.spotLight setExponent:75];
    [sceneUtils setRadiation:sceneUtils.spotLight to:EMISSION_ARTIFICIAL_FULL];
    [sceneUtils updateSpotLightFrustum];

    // Create default 3D Models
    [self setupImps];
     
    // Create logical map of the game
    colMap = [[YAColonyMap alloc] init];
    [colMap setWorld:renderLoop];
    [colMap setTerrain:terrain];
    [colMap setTerrainImp:terrainImp];
    [colMap setSceneUtils:sceneUtils];
    [colMap setGameContext:gameContext];

    // Bullet-Engine initialization
    be = [[YABulletEngineTranslator alloc] initIn:renderLoop];
    [deskImp setMass:@0.0f];
    [be setGroundImp:deskImp];

    // default visibility
    [spaceShipImp setVisible:NO];
    [moonImp setVisible:NO];
    [sunImp setVisible:NO];
    [sunCoverImp setVisible:NO];
    [cursorInnerImp setVisible:NO];
    [cursorOuterImp setVisible:NO];
    [barrackImp setVisible:NO];
    [planeImp setVisible:NO];
    [boardTitleImp setVisible:YES];
    [boardImp setVisible:NO];
    [terrainImp setVisible:NO];
    [parachuteImp setVisible:NO];
    [podImp setVisible:NO];

    // Connect Bullet Engine Physics with kinematics
    const float intervalTime = 5.0f;
    YABlockAnimator* nextStep = [renderLoop createBlockAnimator];
    [nextStep setInterval:intervalTime];
    [nextStep setAsyncProcessing:NO];
    [nextStep setDelay:0];
    __block float lastSP = -1;

    [nextStep addListener:^(float sp, NSNumber *event, int message) {
        if( lastSP >= 0) {
            float lastCall = lastSP < sp ? (sp - lastSP) : ((1.0 - lastSP) + sp);
            lastCall *= intervalTime;
            [be nextStep: lastCall];
        }
        lastSP = sp;
    }];
         
     // Start the event chain if kinematica are available
    YABlockAnimator* readyForRender = [renderLoop createBlockAnimator];
    [readyForRender setOneExecution:YES];
    [readyForRender addListener:^(float sp, NSNumber *event, int message) {
        // NSLog(@"Start event chain.");
        [_eventChain startEvent:@"init"]; // start events with first renderloop
    }];
         
    // The first Event is started by previous block. Since NSTime is working on active thread eventchain.start
    // should not be called in this block. To avoid accessing an uninitialized eventchain, it must be defined before
    // the scenegraph starts.
    [self setupLogic];
         
    // link player attributes to renderLoop entities
    for(YAAlienRace* player in gameContext.playerGameData) {
       player.store = _store;
       player.colonyMap =  colMap;
       player.gameContext = gameContext; // reverse link
    };
         
    // my ideal distance
    renderLoop.transformer.projectionInfo.fieldOfView = 24.879f;
    [[renderLoop transformer] recalcCam];

    [renderLoop changeImpsSortOrder:SORT_MODEL];
    [renderLoop setSkyMap:@"LR"];

    [renderLoop freeOpenGLContextFromThread];

    [renderLoop resetAnimators];
    [renderLoop setActiveAnimation:true];
    [renderLoop setDrawScene:true];

    NSMutableArray* physicImps = be.physicImps;
    int i = 0;
    for(YAImpersonator* starImp in starImps) {
        
        [starImp setUseQuaternionRotation:true];
        
        if(i == 0) {
            [[starImp translation] setValues:-5.543136 :4.250978 :-0.149020];
            [[starImp rotation] setZ: 30];
            [starImp setRotationQuaternion:[[YAQuaternion alloc] initEuler:-30 pitch:0 roll:30]];
        } else if (i == 1) {
            [[starImp translation] setValues:-6.747066 :3.449020 :-0.807845];
            [[starImp rotation] setZ: 55];
            [starImp setRotationQuaternion:[[YAQuaternion alloc] initEuler:60 pitch:0 roll:55]];
        } else if (i == 2) {
            [[starImp translation] setValues:-4.462750 :3.245075 :1.149022];
            [[starImp rotation] setZ: 0];
            [starImp setRotationQuaternion:[[YAQuaternion alloc] initEuler:5 pitch:0 roll:0]];
        }
        i++;
        
        [starImp setMass:@0.5f];
        [starImp setHulls:[[NSArray alloc] initWithObjects:@"StarHull", @"StarHull.001", @"StarHull.002", @"StarHull.003", nil]];
        
        if(![physicImps containsObject:starImp])
            [physicImps addObject:starImp];
    }
    
    [be restart];
    
    // add ropes to stars
    for(YAImpersonator* starImp in starImps) {
        YAVector3f* from = [[YAVector3f alloc] initCopy:[starImp translation]];
        YAVector3f* to = [[YAVector3f alloc] initCopy:[starImp translation]];
        from.y = 8;
        to.y += 2;
        [be addRopeFor:starImp.identifier top:from anchor:to];
    }

    _ropeSegments = [[NSArray alloc] init];
    for(int i = 0; i < 22; i++) {
        int starStringImpId = [renderLoop createImpersonator:@"Rope"];
        YAImpersonator* starStringImp = [renderLoop getImpersonator:starStringImpId];
        
        [[[starStringImp material] phongAmbientReflectivity] setValues:.5 :.5 :.5];
        [starStringImp setUseQuaternionRotation:YES];
        [starStringImp setVisible:NO];
        [starStringImp setShadowCaster:NO];
        
        _ropeSegments = [_ropeSegments arrayByAddingObject:starStringImp];
    }
    _ic.ropeSegments = _ropeSegments;
    
    YABlockAnimator* animRopes = [renderLoop createBlockAnimator];
    [animRopes setAsyncProcessing:NO];
    [animRopes addListener:^(float sp, NSNumber *event, int message) {
        NSArray* ropes = [be ropeDescriptions];
        
        YAVector3f* startSegment;
        int ropeSegmentIndex = 0;
        int starIndex = 0;
        
        for(NSArray* rope in ropes) {
            
            startSegment = [[starImps objectAtIndex:starIndex++] translation];
            for(YAVector3f* nextSegment in [[rope reverseObjectEnumerator] allObjects]) {
                
                
                float stringLength = [startSegment distanceTo:nextSegment];
                YAImpersonator* starStringImp = [_ropeSegments objectAtIndex:ropeSegmentIndex++];
                
                starStringImp.visible = YES;
                [starStringImp resize:0.01];
                starStringImp.size.y = stringLength / 2;
                
                YAVector3f* pos = [[YAVector3f alloc] initCopy:nextSegment];
                [pos subVector:startSegment];
                
                [pos mulScalar:.5f];
                [pos addVector:startSegment];
                [[starStringImp translation] setVector:pos];
                
                
                YAVector3f* direction = [[YAVector3f alloc] initCopy:pos];
                [direction subVector:startSegment];
                [direction normalize];
                
                float rotZ = ToDegree(acosf([direction dotVector: [[YAVector3f alloc] initZAxe]]));
                float rotX = ToDegree(acosf([direction dotVector: [[YAVector3f alloc] initXAxe]]));
                YAQuaternion* quat = [[YAQuaternion alloc]initEulerDeg:0 pitch:90-rotZ roll: (90- rotX) * -1 ];
                [starStringImp setRotationQuaternion:quat];
                
                startSegment = nextSegment;
            }
        }
        
    }];
    
    
}

- (void) clearScene
{
    // NSLog(@"Clear Scene");
    renderLoop.transformer.projectionInfo.fieldOfView = 30.0f;
    [[[renderLoop transformer] projectionInfo] setZNear:1.0f];
    [[renderLoop transformer] recalcCam];
    
    [[[sceneUtils spotLight] position] setValues:0.0f :10.0f :0.0f];
    [[[sceneUtils spotLight] direction] setValues:0.0f :-1.0f :0.0f];
    [[[sceneUtils spotLight] direction] normalize];
    [[[sceneUtils spotLight] intensity] setValues:1 :1 :1];
    sceneUtils.spotLight.exponent = 40.0f;
    sceneUtils.spotLight.cutoff = 15.0f;

    sceneUtils.light.directional = NO;
    [[[sceneUtils light] position] setValues:0.0f :10.0f :0.0f];
    [[[sceneUtils light] intensity] setValues:0.8 :0.8 :0.8];

    [renderLoop setActiveAnimation:false];
    [renderLoop setDrawScene:false];
    [renderLoop removeAllAnimators];
    [renderLoop removeAllImpersonators];
}


@end
