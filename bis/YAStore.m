//
//  YAStore.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 03.05.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YAChronograph.h"
#import "YAOpenAL.h"
#import "YASoundCollector.h"
#import "YALog.h"
#import "YAProbability.h"
#import "YAVector2i.h"
#import "YAVector4f.h"
#import "YAMatrix4f.h"
#import "YAPerspectiveProjectionInfo.h"
#import "YATransformator.h"
#import "YAEvent.h"
#import "YAEventChain.h"
#import "YAAlienRace.h"
#import "YAInterpolationAnimator.h"
#import "YAAvatar.h"
#import "YAQuaternion.h"
#import "YABulletEngineTranslator.h"
#import "YADromedarMover.h"
#import "YAMaterial.h"
#import "YAImpersonatorMover.h"
#import "YAAlienRace.h"
#import "YAGameContext.h"
#import "YAVector3f.h"
#import "YAImpersonator+Physic.h"
#import "YAImpGroup.h"
#import "YASceneUtils.h"
#import "YAColonyMap.h"
#import "YABlockAnimator.h"
#import "YARenderLoop.h"

#import "YAStore.h"

#define zeroRg 0.1
#define ToRadian(x) ((x) * M_PI / 180.0f)
#define ToDegree(x) ((x) * 180.0f / M_PI)
#define ToGrad(x) ((x) * M_PI / 360.0f)

#define CAMEL_SELL_PRICE 100

@implementation YAStore

@synthesize contactImps;
@synthesize collisionImp;
@synthesize crystaliteFabPrice, smithoreFabPrice, energyFabPrice, farmFabPrice, assayPrice;
@synthesize camelPrice, camelsAvailable;
@synthesize soundCollector = sc;
@synthesize crystaliteUnitPrice,smithoreUnitPrice, energyUnitPrice, foodUnitPrice, plotUnitPriceEmpty, plotUnitPriceDeveloped;
@synthesize foodStock,energyStock,smithoreStock, crystaliteStock;



- (id) initInWorld: (YARenderLoop*) world
             utils: (YASceneUtils*) sceneUtils
            colony: (YAColonyMap*) colonyMap
       gameContext: (YAGameContext*) gameContext
        eventChain: (YAEventChain*) eventChain
{
    self = [super init];
    if (self) {
        _world = world;
        _sceneUtils = sceneUtils;
        _colonyMap = colonyMap;
        _gameContext = gameContext;
        _eventChain = eventChain;
        contactImps = [[NSMutableArray alloc] init];
        _localPhysicImps = [[NSMutableArray alloc] init];
        
        camelBought = NO;
        crystaliteBought = NO;
        smithoreBought = NO;
        energyBought = NO;
        farmBought = NO;
        
        crystaliteFabPrice = 100;
        smithoreFabPrice = 75;
        energyFabPrice = 50;
        farmFabPrice = 25;
        assayPrice = 20;
        
        
        // default stock and prices
        
        if(gameContext.gameDifficulty == 0) {
            foodStock = 16;
            energyStock = 16;
            smithoreStock = 0;
            camelsAvailable = 25;
            maxCamels = 25;
        } else {
            foodStock = 8;
            energyStock = 8;
            smithoreStock = 8;
            camelsAvailable = 14;
            maxCamels = 14;
        }
        
        crystaliteStock = 0;
   
        foodUnitPrice = 25;
        energyUnitPrice = 25;
        smithoreUnitPrice = 50;
        crystaliteUnitPrice = 100;
        plotUnitPriceEmpty = 50;
        plotUnitPriceDeveloped = 100;
        camelPrice = 100; // minimum price is 100
        
        _lastPurchase = -1;
        
        _screenCoords = [[YAVector3f alloc] init];
        _lastValidCoords = [[YAVector3f alloc] init];
        
    }
    return self;
}

- (float) showShopAt: (float) startTime
{
    YABlockAnimator* landZoom = [_world createBlockAnimator];
    [landZoom setDelay:startTime];
    [landZoom setOneExecution: YES];
    [landZoom addListener:^(float sp, NSNumber *event, int message) {
        YAImpGroup* blag = [_colonyMap getHouseGroupAtX:3 Z:3];
        [_sceneUtils setPoi:blag.translation];
        
        _world.transformer.projectionInfo.zNear = 0.01f;
        [[_world transformer] recalcCam];
        
        [_sceneUtils moveAvatarPositionTo:AVATAR_RELATIV_POI At:0];
    }];
    
    return startTime + 1.0;
}

- (float) activatePodDoor: (float) startTime
{
    const float interval = 0.2;
    
    YABlockAnimator* doorAnim = [_world createBlockAnimator];
    [doorAnim setDelay:startTime];
    [doorAnim setOneExecution:true];
    [doorAnim setAsyncProcessing:NO];
    [doorAnim addListener:^(float sp, NSNumber *event, int message) {
        YAImpGroup* shopGroup = [_colonyMap getHouseGroupAtX:3 Z:3];
        doorImp = shopGroup.observers.lastObject;

        float sign = doorImp.rotation.z != 0 ? -1.0f : 1.0f;
        
        YABasicAnimator* flub = [_world createBasicAnimator];
        [flub setInterval:interval];
        [flub setProgress:damp];
        [flub setOnce:true];
        [flub setOnceReset:false];
        [flub addListener:doorImp.rotation factor:97.5 * sign];
        [flub setInfluence:Z_AXE];
    }];
    
    return startTime + interval;
}

- (void)checkAndBuy:(bool)buttonAction
{
    if(collisionImp) {
        NSString* collisionName = collisionImp.collisionName;
        
        if([collisionName isEqualToString:@"eagle"]) {
            
            if(eagleImp == nil)
                eagleImp = collisionImp;
            
            if(buttonAction) {
                YAVector3f* pos =  [[YAVector3f alloc] initCopy:meeple.translation ];
                [pos subVector:_sceneUtils.avatar.position];
                [sc.soundHandler updateSound:[sc getSoundId:@"Explosion"] toPosition:pos];
                [sc.soundHandler playSound:[sc getSoundId:@"Explosion"]];
                
                [_moveAlien setDeleteme:YES];
                [followMeeple setDeleteme:YES];
                
                [self activatePodDoor:0];
                
                // remove Imps from bullet engine
                NSMutableArray* physicImps = [_be physicImps];
                NSMutableArray* newPhysicImps = [[NSMutableArray alloc] init];
                
                for(YAImpersonator* imp in physicImps) {
                    if(![contactImps containsObject:imp] && imp != meeple && imp != dromedarImp && ![_localPhysicImps containsObject:imp] ) {
                        [newPhysicImps addObject:imp];
                    }
                }
                
                for(YAImpersonator* cr in _playerColorRings)
                    [cr setVisible:NO];
                
                [_be setPhysicImps:newPhysicImps];
                [_be restart];
                
                [_world removeImpersonator:crystaliteImp.identifier];
                [_world removeImpersonator:smithoreImp.identifier];
                [_world removeImpersonator:energyImp.identifier];
                [_world removeImpersonator:farmImp.identifier];
                [_world removeImpersonator:shopSignText.identifier];
                crystaliteImp = nil;
                smithoreImp = nil;
                energyImp = nil;
                farmImp = nil;
                shopSignText = nil;
                
                for(YAImpersonator* cr in _playerColorRings)
                    [_world removeImpersonator:cr.identifier];
                
                [dm setActive:none];
                [dm reset];
                [dm cleanup];
                dm = nil;
                [_world removeImpersonator:dromedarImp.identifier];
                
                YABlockAnimator* once = [_world createBlockAnimator];
                [once setOneExecution:YES];
                [once addListener:^(float sp, NSNumber *event, int message) {
                    [_animator setActive:none];
                    [_animator reset];
                    [meeple setVisible:NO];
                }];
                
                double scale = 1.0 / 23.0;
                [_world rescaleScene:scale];
                // NSLog(@"World Rescaled");
                [_sceneUtils updateFrustumTo:-1]; // default
                
                // disable mouse tracking
                [_world setTraceMouseMove:NO];
                
                [_colonyMap resetFabs];
                if([[_eventChain getEvent:@"eagleFly"] valid])
                    [_eventChain resetEvents:[NSArray arrayWithObject:@"eagleFly"]];
                else
                    [_eventChain startEvent:@"eagleFly" At:0.5];
            }
        } else if([collisionName isEqualToString:@"Crystalite"]  && !crystaliteBought) {
            [self createMiniShopCrystaliteFrom:collisionImp Visible:YES];
            if(buttonAction) {
                if(camelBought) {
                    if(arPlayer.money >= crystaliteFabPrice) {
                        [self buyCrystaliteFrom: collisionImp];
                        arPlayer.money -=  crystaliteFabPrice;
                        YAVector3f* pos =  [[YAVector3f alloc] initCopy:meeple.translation ];
                        [pos subVector:_sceneUtils.avatar.position];
                        [sc.soundHandler updateSound:[sc getSoundId:@"Powerup"] toPosition:pos];
                        [sc.soundHandler playSound:[sc getSoundId:@"Powerup"]];
                    } else {
                        [_world updateTextIngredient:[YALog decode:@"notEnoughMoney"] Impersomator:shopSignText];
                        YAVector3f* pos =  [[YAVector3f alloc] initCopy:meeple.translation ];
                        [pos subVector:_sceneUtils.avatar.position];
                        [sc.soundHandler updateSound:[sc getSoundId:@"Hit"] toPosition:pos];
                        [sc.soundHandler playSound:[sc getSoundId:@"Hit"]];
                    }
                } else {
                    [_world updateTextIngredient:[YALog decode:@"buyCamel"] Impersomator:shopSignText];
                    [[[shopSignText material] phongAmbientReflectivity] setVector:_sceneUtils.color_red];
                    
                    YAVector3f* pos =  [[YAVector3f alloc] initCopy:meeple.translation ];
                    [pos subVector:_sceneUtils.avatar.position];
                    [sc.soundHandler updateSound:[sc getSoundId:@"Hit"] toPosition:pos];
                    [sc.soundHandler playSound:[sc getSoundId:@"Hit"]];
                }
                
            }
        } else if([collisionName isEqualToString:@"Smithore"]  && !smithoreBought) {
            [self createMiniShopSmithoreFrom:collisionImp Visible:YES];
            if(buttonAction) {
                if(camelBought) {
                    if(arPlayer.money >= smithoreFabPrice) {
                        [self buySmithoreFrom:collisionImp];
                        arPlayer.money -=  smithoreFabPrice;
                        YAVector3f* pos =  [[YAVector3f alloc] initCopy:meeple.translation ];
                        [pos subVector:_sceneUtils.avatar.position];
                        [sc.soundHandler updateSound:[sc getSoundId:@"Powerup"] toPosition:pos];
                        [sc.soundHandler playSound:[sc getSoundId:@"Powerup"]];
                    } else {
                        [_world updateTextIngredient:[YALog decode:@"notEnoughMoney"] Impersomator:shopSignText];
                        YAVector3f* pos =  [[YAVector3f alloc] initCopy:meeple.translation ];
                        [pos subVector:_sceneUtils.avatar.position];
                        [sc.soundHandler updateSound:[sc getSoundId:@"Hit"] toPosition:pos];
                        [sc.soundHandler playSound:[sc getSoundId:@"Hit"]];
                    }
                } else {
                    [_world updateTextIngredient:[YALog decode:@"buyCamel"] Impersomator:shopSignText];
                    [[[shopSignText material] phongAmbientReflectivity] setVector:_sceneUtils.color_red];
                    YAVector3f* pos =  [[YAVector3f alloc] initCopy:meeple.translation ];
                    [pos subVector:_sceneUtils.avatar.position];
                    [sc.soundHandler updateSound:[sc getSoundId:@"Hit"] toPosition:pos];
                    [sc.soundHandler playSound:[sc getSoundId:@"Hit"]];
                }
            }
        } else if([collisionName isEqualToString:@"Energy"]  && !energyBought) {
            [self createMiniShopEnergyFrom:collisionImp Visible:YES];
            if(buttonAction) {
                if(camelBought) {
                    if(arPlayer.money >= energyFabPrice) {
                        [self buyEnergyFrom:collisionImp];
                        arPlayer.money -=  energyFabPrice;
                        YAVector3f* pos =  [[YAVector3f alloc] initCopy:meeple.translation ];
                        [pos subVector:_sceneUtils.avatar.position];
                        [sc.soundHandler updateSound:[sc getSoundId:@"Powerup"] toPosition:pos];
                        [sc.soundHandler playSound:[sc getSoundId:@"Powerup"]];
                    }  else {
                        [_world updateTextIngredient:[YALog decode:@"notEnoughMoney"] Impersomator:shopSignText];
                        YAVector3f* pos =  [[YAVector3f alloc] initCopy:meeple.translation ];
                        [pos subVector:_sceneUtils.avatar.position];
                        [sc.soundHandler updateSound:[sc getSoundId:@"Hit"] toPosition:pos];
                        [sc.soundHandler playSound:[sc getSoundId:@"Hit"]];
                    }
                } else {
                    [_world updateTextIngredient:[YALog decode:@"buyCamel"] Impersomator:shopSignText];
                    [[[shopSignText material] phongAmbientReflectivity] setVector:_sceneUtils.color_red];
                    YAVector3f* pos =  [[YAVector3f alloc] initCopy:meeple.translation ];
                    [pos subVector:_sceneUtils.avatar.position];
                    [sc.soundHandler updateSound:[sc getSoundId:@"Hit"] toPosition:pos];
                    [sc.soundHandler playSound:[sc getSoundId:@"Hit"]];
                }
            }
        } else if([collisionName isEqualToString:@"Farm"]  && !farmBought) {
            [self createMiniFarmFrom:collisionImp Visible:YES];
            if(buttonAction) {
                if(buttonAction) {
                    if(camelBought) {
                        if(arPlayer.money >= farmFabPrice) {
                            [self buyFarmFrom:collisionImp];
                            arPlayer.money -=  farmFabPrice;
                            YAVector3f* pos =  [[YAVector3f alloc] initCopy:meeple.translation ];
                            [pos subVector:_sceneUtils.avatar.position];
                            [sc.soundHandler updateSound:[sc getSoundId:@"Powerup"] toPosition:pos];
                            [sc.soundHandler playSound:[sc getSoundId:@"Powerup"]];
                        } else {
                            [_world updateTextIngredient:[YALog decode:@"notEnoughMoney"] Impersomator:shopSignText];
                            YAVector3f* pos =  [[YAVector3f alloc] initCopy:meeple.translation ];
                            [pos subVector:_sceneUtils.avatar.position];
                            [sc.soundHandler updateSound:[sc getSoundId:@"Hit"] toPosition:pos];
                            [sc.soundHandler playSound:[sc getSoundId:@"Hit"]];
                        }
                    } else {
                        [_world updateTextIngredient:[YALog decode:@"buyCamel"] Impersomator:shopSignText];
                        [[[shopSignText material] phongAmbientReflectivity] setVector:_sceneUtils.color_red];
                        YAVector3f* pos =  [[YAVector3f alloc] initCopy:meeple.translation ];
                        [pos subVector:_sceneUtils.avatar.position];
                        [sc.soundHandler updateSound:[sc getSoundId:@"Hit"] toPosition:pos];
                        [sc.soundHandler playSound:[sc getSoundId:@"Hit"]];
                        
                    }
                }
            }
        }else if([collisionName isEqualToString:@"Camel"] && buttonAction) {
            if(!camelBought) {
                if(arPlayer.money >= camelPrice) {
                    [self buyCamel];
                    arPlayer.money -=  camelPrice;
                    camelsAvailable--;
                    [sc playForImp:meeple Sound:[sc getSoundId:@"Powerup"]];
                } else {
                    [_world updateTextIngredient:[YALog decode:@"notEnoughMoney"] Impersomator:shopSignText];
                    [sc playForImp:meeple Sound:[sc getSoundId:@"Powerup"]];
                }
                
            } else {
                [self sellCamel];
                arPlayer.money += CAMEL_SELL_PRICE;
                camelsAvailable++;
                [sc playForImp:meeple Sound:[sc getSoundId:@"Powerup"]];
            }
        } else if([collisionName isEqualToString:@"Pub"] && buttonAction) {
            // NSLog(@"Pub");
            [sc playForImp:meeple Sound:[sc getSoundId:@"Powerup"]];
            _gameContext.activePlayer = -1;
            _gambling = YES;
            [self timeIsUp];
        } else if([collisionName isEqualToString:@"Land"] && buttonAction && _comission != COMISSION_LAND) {
            // NSLog(@"Land");
            [sc playForImp:meeple Sound:[sc getSoundId:@"Powerup"]];
            _comission = COMISSION_LAND;
        } else if([collisionName isEqualToString:@"Assay"] && buttonAction  && _comission != COMISSION_ASSAY) {
            // NSLog(@"Assay");
            if(arPlayer.money >= assayPrice) {
                [sc playForImp:meeple Sound:[sc getSoundId:@"Powerup"]];
                arPlayer.money -=  assayPrice;
                _comission = COMISSION_ASSAY;
            } else {
                [_world updateTextIngredient:[YALog decode:@"notEnoughMoney"] Impersomator:shopSignText];
                [sc playForImp:meeple Sound:[sc getSoundId:@"Powerup"]];
            }
        }
        
        collisionImp = nil;
    }
}

- (void) goShoppingWith: (int) player
{
    
    [_screenCoords setValues:0 :0 :0];
    [_lastValidCoords setValues:0 :0 :0];
    
    _player = player;
    arPlayer = [_gameContext.playerGameData objectAtIndex:_player];

    YAImpGroup* shopGroup = [_colonyMap getHouseGroupAtX:3 Z:3];
    doorImp = shopGroup.observers.lastObject;
    [doorImp setClickable:YES];

    // Shop ist initialized once per game so reset necessary params
    
    _comission = COMISSION_NONE;
    
    camelBought = NO;
    crystaliteBought = NO;
    smithoreBought = NO;
    energyBought = NO;
    farmBought = NO;
    
    shopSignText = nil;
    actualShopSignText = [YALog decode:@"welcomeEridu"];
    shopSignText = [_sceneUtils genText:actualShopSignText];
    [shopSignText resize:0.412];
    [[[shopSignText material] phongAmbientReflectivity] setVector:_sceneUtils.color_dark_blue];
    [[shopSignText material] setEta:0];
    [[shopSignText translation] setVector:_shopPlaceSign.translation];
    shopSignText.translation.z -= 0.05;
    shopSignText.translation.x -= 2.0;
    shopSignText.translation.y += 0.4;
    
    
    shopSignText.rotation.x = 0;
    
    
    int dromedarId = [_world createImpersonatorWithShapeShifter: @"Dromedar"];
    dromedarImp = [_world getImpersonator:dromedarId];
    
    // dromedar is positioned according shop center
    [[dromedarImp translation] setVector: _shopSocket.translation];
    [[dromedarImp translation] subVector:[[YAVector3f alloc] initVals:-0.933914 :-0.72 :3.4]];
    
    
    [dromedarImp setUseQuaternionRotation:YES];
    [[dromedarImp rotation] setVector: [[YAVector3f alloc] initVals: -90: 180 : 0]];
    [dromedarImp setRotationQuaternion:[[YAQuaternion alloc] initEulerDeg:180 pitch:-90 roll:0]];
    
    [dromedarImp resize:0.095];
    [[[dromedarImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.7 : 0.7 : 0.7 ]];
    [[[dromedarImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[[dromedarImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4f : 0.4f : 0.4f ]];
    [[dromedarImp material] setPhongShininess: 20];
    
    
    // physics for collision detection
    [dromedarImp setMass:@1.0f]; // x->z y->x z->y
    YAVector3f* dromedarExtensions = [[YAVector3f alloc] initVals:2.834f  :9.997f  :5.794f];
    [dromedarExtensions mulScalar:0.5];
    [dromedarImp setBoxHalfExtents:dromedarExtensions];
    [dromedarImp setBoxOffset:[[YAVector3f alloc] initVals:0 :2.89663f :-1.46849]];
    
    
    dm = [[YADromedarMover alloc] initWithImp:dromedarImp inWorld:_world];
    [dm setActive:parade];
    
    [[_be physicImps] addObject:dromedarImp];
    
    _playerColorRings = [_sceneUtils createPlayerColorRings:_gameContext];
    __block YAImpersonator* colorRing = [_playerColorRings objectAtIndex:player];
    [[colorRing rotation] setValues:-90 :0 :0];
    [colorRing setBackfaceCulling:true];
    [colorRing resize:0.575];
    
    //TODO: The Term Race is Crap but species was already taken :(
    YAAlienRace* ar = [[_gameContext playerGameData] objectAtIndex:player];
    
    [ar sizeSmall];
    meeple = ar.impersonator;
    
    __block id<YAImpersonatorMover> animator = ar.impMover;
    _animator = animator;
    
    [meeple setVisible:true];
    [[meeple translation] setVector:_shopSocket.translation];
    meeple.translation.y += _shopSocket.boxHalfExtents.y * _shopSocket.size.y;
    
    // set imp to quat rotation
    [meeple setUseQuaternionRotation:YES];
    __block YAQuaternion* quat = [[YAQuaternion alloc]initEulerDeg:00 pitch:-90 roll:0];
    [meeple setRotationQuaternion:quat];
    
    [[_be physicImps] addObject:meeple];
    
    [colorRing setVisible:true];
    [[colorRing translation] setVector:meeple.translation];
    colorRing.translation.y += 0.035;
    
    __block float lastSp = -1;
    __block int deviceId = [_gameContext deviceIdforPlayer:player];
    
    if(deviceId == 1000)
        [_world setTraceMouseMove:YES];
    
    __block float zLPadPos = 0;
    __block float xLPadPos = 0;
    __block float zRPadPos = 0;
    __block float xRPadPos = 0;
    __block int buttonA = 0;
    __block int buttonB = 0;
    
    const float plSpeedFactor = 0.1;
    const YAVector3f* zAxis = [[YAVector3f alloc] initZAxe];
    __block YAVector3f* origin = [[YAVector3f alloc] init];
    __block YAVector3f* direction = [[YAVector3f alloc] init];
    
    __block bool buttonAction = NO;
    
    __block bool followMouse = NO;
    __block YAVector3f* mouseDirection = [[YAVector3f alloc] init];

    YABlockAnimator* moveAlien = [_world createBlockAnimator];
    _moveAlien = moveAlien;

    [moveAlien setInterval:2];
    [moveAlien addListener:^(float sp, NSNumber *event, int message) {

        //Time Up?
        if(_gameContext.activePlayer == -1) {
            [self timeIsUp];
            return;
        }
        
        buttonAction = NO;
        int _deviceId = message >> 16;
        
        const int evi = event.intValue;
        // looking for pad input events
        if(evi >= GAMEPAD_LEFT_X && evi <= MOUSE_MOVE_Y && deviceId == _deviceId) {
            
            int evBin = message & 255;
            float evVal = (float)(message & 255) / 255.0f - 0.5f;
            
            
            switch (evi) {
                case GAMEPAD_LEFT_Y:
                    if(fabs(evVal) > zeroRg)
                        zLPadPos = evVal;
                    else
                        zLPadPos = 0;
                    break;
                case GAMEPAD_LEFT_X:
                    if(fabs(evVal) > zeroRg)
                        xLPadPos = evVal;
                    else
                        xLPadPos = 0;
                    break;
                case GAMEPAD_RIGHT_Y:
                    if(fabs(evVal) > zeroRg)
                        zRPadPos = evVal;
                    else
                        zRPadPos = 0;
                    break;
                case GAMEPAD_RIGHT_X:
                    if(fabs(evVal) > zeroRg)
                        xRPadPos = evVal;
                    else
                        xRPadPos = 0;
                    break;
                case GAMEPAD_BUTTON_OK:
                    if(evBin == 1) {
                        
                        if(buttonA == 0) // assure that collision detection is only called once
                            buttonAction = YES;
                        
                        buttonA = 1;
                    }else
                        buttonA = 0;
                    break;
                case GAMEPAD_BUTTON_CANCEL:
                    if(evBin == 1)
                        buttonB = 1;
                    else
                        buttonB = 0;
                    break;
                case GAMEPAD_BUTTON_A:
                    break;
                case GAMEPAD_BUTTON_B:
                    break;
                default:
                    break;
            }
            
        } else if(deviceId == 1000 && (evi == MOUSE_DOWN || evi == MOUSE_UP || evi == MOUSE_VECTOR) ) {
            
            int x,y;
            
            switch (evi) {
                case MOUSE_DOWN:
                    if(message == camelTable.identifier && [meeple.translation distanceTo:camelTable.translation] <= 2.5) {
                        buttonAction = YES;
                        collisionImp = camelTable;
                    } else if(message == pubTable.identifier && [meeple.translation distanceTo:pubTable.translation] <= 2.5) {
                        buttonAction = YES;
                        collisionImp = pubTable;
                    } else if(message == landTable.identifier && [meeple.translation distanceTo:landTable.translation] <= 2.5) {
                        buttonAction = YES;
                        collisionImp = landTable;
                    } else if(message == assayTable.identifier && [meeple.translation distanceTo:assayTable.translation] <= 2.5) {
                        buttonAction = YES;
                        collisionImp = assayTable;
                    } else if(message == crystaliteImp.identifier) {
                        buttonAction = YES;
                        collisionImp = crystaliteBoardImp;
                    } else if(message == smithoreImp.identifier) {
                        buttonAction = YES;
                        collisionImp = smithoreBoardImp;
                    } else if(message == energyImp.identifier) {
                        buttonAction = YES;
                        collisionImp = energyBoardImp;
                    } else if(message == farmImp.identifier) {
                        buttonAction = YES;
                        collisionImp = farmBoardImp;
                    }  else if(message == doorImp.identifier && [meeple.translation distanceTo:doorImp.translation] <= 2.5) {
                        buttonAction = YES;
                        collisionImp = eagleImp;
                    } else
                        followMouse = YES;
                    break;
                case MOUSE_UP:
                    followMouse = NO;
                    [_lastValidCoords setVector:_screenCoords];
                    break;
                case MOUSE_VECTOR:
                        x = (message >> 16);
                        y = message & 511;
                        _screenCoords.x = ((float) x / 511 - 0.5) * 2;
                        _screenCoords.y = 0;
                        _screenCoords.z = ((float) y / 511 - 0.5) * 2;
                    break;
                default:
                    break;
            }
            
        }

        if(followMouse) {
            YATransformator* transformer = _world.transformer;
            [transformer setRotateQuatMatrix: [meeple quatMatrix]];
            [[transformer scale] setVector:meeple.size];
            [[transformer translate] setVector:[meeple translation]];
            const YAMatrix4f* mat = [transformer transform];
            YAVector4f* result = [mat mulVector3f:[[YAVector3f alloc] init]];
            YAVector3f* meepleScreen = [[YAVector3f alloc]initVals:(result.x / result.w) :0 :(result.y /result.w)];
            [mouseDirection setVector:_screenCoords];
            [mouseDirection subVector:meepleScreen];
            mouseDirection.z *= -1;

            float speed = [mouseDirection distanceTo:origin] * 5;
            if (speed > 0.5)
                speed = 0.5;
            
            [mouseDirection normalize];
            [mouseDirection mulScalar:speed];
            
        } else if([_lastValidCoords distanceTo:origin] != 0) {
            YATransformator* transformer = _world.transformer;
            [transformer setRotateQuatMatrix: [meeple quatMatrix]];
            [[transformer scale] setVector:meeple.size];
            [[transformer translate] setVector:[meeple translation]];
            const YAMatrix4f* mat = [transformer transform];
            YAVector4f* result = [mat mulVector3f:[[YAVector3f alloc] init]];
            YAVector3f* meepleScreen = [[YAVector3f alloc]initVals:(result.x / result.w) :0 :(result.y /result.w)];

            [mouseDirection setVector:_lastValidCoords];
            [mouseDirection subVector:meepleScreen];
            mouseDirection.z *= -1;
            
            const float distance = [mouseDirection distanceTo:origin];

            if(distance < 0.001) {
                [_lastValidCoords setValues:0 :0 :0];
                [mouseDirection setValues:0 :0 :0];
            } else {
                float speed = distance * 5;
                if (speed > 0.5)
                    speed = 0.5;
                
                [mouseDirection normalize];
                [mouseDirection mulScalar:speed];
            }
                
            
            
            
        } else
            [mouseDirection setValues:0 :0 :0];
        
        
        if(!crystaliteBought)
            [crystaliteImp setVisible:NO];
        if(!smithoreBought)
            [smithoreImp setVisible:NO];
        if(!energyBought)
            [energyImp setVisible:NO];
        if(!farmBought)
            [farmImp setVisible:NO];
        
        
        NSString* tempText;

        if(camelTable == nil && [collisionImp.collisionName isEqualToString:@"Camel"]) {
            camelTable = collisionImp;
            [camelTable setClickable:YES];
        }
        
        if(pubTable == nil && [collisionImp.collisionName isEqualToString:@"Pub"]) {
            pubTable = collisionImp;
            [pubTable setClickable:YES];
        }

        if(assayTable == nil && [collisionImp.collisionName isEqualToString:@"Assay"]) {
            assayTable = collisionImp;
            [assayTable setClickable:YES];
        }

        if(landTable == nil && [collisionImp.collisionName isEqualToString:@"Land"]) {
            landTable = collisionImp;
            [landTable setClickable:YES];
        }

        if( pubTable != nil && ([meeple.translation distanceTo:pubTable.translation] < 1.5) ) {
            tempText = [YALog decode:@"visitPub"];
        } else if( landTable != nil && ([meeple.translation distanceTo:landTable.translation] < 1.5) ) {
            tempText = [YALog decode:@"visitLand"];
            
            if(_comission == COMISSION_LAND)
                tempText = [tempText stringByReplacingOccurrencesOfString:@"_" withString: [YALog decode:@"boughtFromTable"]];
            else
                tempText = [tempText stringByReplacingOccurrencesOfString:@"_" withString: @""];
        } else if( assayTable != nil && ([meeple.translation distanceTo:assayTable.translation] < 1.5) ) {
            tempText = [YALog decode:@"visitAssay"];
            
            if(_comission == COMISSION_ASSAY)
                tempText = [tempText stringByReplacingOccurrencesOfString:@"_" withString: [YALog decode:@"boughtFromTable"]];
            else
                tempText = [tempText stringByReplacingOccurrencesOfString:@"_" withString: @""];
        } else if (([meeple.translation distanceTo:crystaliteImp.translation] < 1.5) &&  !crystaliteBought) {
            [crystaliteImp setVisible:YES];
            tempText = [NSString stringWithFormat:@"%@ %d", [YALog decode:@"crystaliteFabCost"], crystaliteFabPrice ];
        } else if(([meeple.translation distanceTo:smithoreImp.translation] < 1.5) &&  !smithoreBought) {
            [smithoreImp setVisible:YES];
            tempText = [NSString stringWithFormat:@"%@ %d", [YALog decode:@"smithoreFabCost"], smithoreFabPrice];
        } else if(([meeple.translation distanceTo:energyImp.translation] < 1.5) &&  !energyBought) {
            [energyImp setVisible:YES];
            tempText = [NSString stringWithFormat:@"%@ %d", [YALog decode:@"energyFabCost"], energyFabPrice];
        } else if(([meeple.translation distanceTo:farmImp.translation] < 1.5) &&  !farmBought) {
            [farmImp setVisible:YES];
            tempText = [NSString stringWithFormat:@"%@ %d", [YALog decode:@"foodFabCost"], farmFabPrice];
        } else if([meeple.translation distanceTo:camelTable.translation] < 1.5 && !camelBought) {
            tempText = [NSString stringWithFormat:@"%@ %d (%d)", [YALog decode:@"buyMyCamel"], camelPrice, camelsAvailable];
        } else {
            tempText = [NSString stringWithFormat:@"%@ %d", [YALog decode:@"welcomeEridu"], ar.money];
            
        }
        
        if(![tempText isEqualToString: actualShopSignText]) {
            // [sc playForImp:meeple Sound:[sc getSoundId:@"Select"]];
            actualShopSignText = tempText;
            [_world updateTextIngredient:actualShopSignText Impersomator:shopSignText];
            [[[shopSignText material] phongAmbientReflectivity] setVector:_sceneUtils.color_dark_blue];
        }
        
        
        [self checkAndBuy:buttonAction];
        if(_moveAlien.deleteme)
            return;
        
        if(lastSp != sp) {
            
            float timeSpan = lastSp != -1 ?  sp - lastSp : 1 / 125.0f;
            
            if(timeSpan < 0)
                timeSpan = 1 - lastSp + sp;
            
            
            lastSp = sp;
            
            // invoke collision check once per frame
            [_be checkCollision:meeple Targets:contactImps CollisionListener:self];
            
            // Use the controller inputs as vector
            
            if(deviceId != 1000)
                [direction setValues:xLPadPos :0 :zLPadPos];
            else
                [direction setVector:mouseDirection];
            
            
            const float speed = [direction distanceTo:origin] * plSpeedFactor;
            
            // Check length because 0 vectors should not be normalized
            if(!direction.x == direction.y == direction.z == 0)
                [direction normalize];
            
            // Scalarproduct to calculate the
            float angle = ToDegree(acosf([direction dotVector: zAxis]));
            
            // Find angle orientation
            if(xLPadPos < 0 || mouseDirection.x < 0)
                angle = 360 - angle; // Pads have a inversed orientation (a)
            
            if(speed > 0.001) { // move
                
                // audio
                // if(![sc.soundHandler isPlaying:[sc getSoundId:@"Step"]] ) {
                //     [sc playForImp:meeple Sound:[sc getSoundId:@"Step"]];
                // }
                
                quat = [[YAQuaternion alloc]initEulerDeg:-angle pitch:-90 roll:0];
                [meeple setRotationQuaternion:quat];
                
                
                [direction mulScalar:speed * timeSpan * 125];
                direction.z *= -1;
                [animator setActive:walk];
                
                [[meeple translation] addVector:direction];
                
                [[colorRing translation] setVector:meeple.translation];
                colorRing.translation.y += 0.035;
                
                [_be syncImp:meeple.identifier];
                
                
            } else { // stop
                [animator reset];
                [animator setActive:none];
            }
            
        }
    }];
    
}

- (void) sellCamel
{
    // NSLog(@"Sell Camel");
    camelBought = false;
    [followMeeple setDeleteme:YES];
    
    YABlockAnimator* duringRefresh = [_world createBlockAnimator];
    [duringRefresh setOneExecution:true];
    [duringRefresh addListener:^(float sp, NSNumber *event, int message) {
        [dm setActive:none];
        [dm reset];
        [dromedarImp resize:0.095];
        [[dromedarImp translation] setVector: _shopSocket.translation];
        [[dromedarImp translation] subVector:[[YAVector3f alloc] initVals:-0.933914 :-0.72 :3.4]];
        [dromedarImp setRotationQuaternion:[[YAQuaternion alloc] initEulerDeg:180 pitch:-90 roll:0]];
        [_be syncImp:dromedarImp.identifier];
        [_be restart];
    }];
    
}

- (void) buyCamel
{
    // NSLog(@"Buy Camel");
    camelBought = true;
    [[dromedarImp translation] setVector:_shopSocket.translation];
    [[dromedarImp translation] subVector:[[YAVector3f alloc] initVals:4.961764 :-5 :-0.8]];
    [dromedarImp setRotationQuaternion:[[YAQuaternion alloc] initEulerDeg:-90 pitch:-90 roll:0]];
    [dromedarImp resize:0.25];
    [dm setActive:none];
    [dm reset];
    [_be restart];
    
    __weak YAImpersonator* _dromedarImp = dromedarImp;
    __block YADromedarMover* _dm = dm;
    __block YABulletEngineTranslator* __be = _be;
    
    const float dromedarSpeed = 0.04f;
    const float desiredDistance = 2.5f;
    const float margin = 0.5f;
    __block YAVector3f* direction;
    __block float distance;
    __block bool isRotationg;
    
    __block float groundLevel = _shopSocket.translation.y;
    groundLevel += _shopSocket.boxHalfExtents.y * _shopSocket.size.y;
    
    __weak YAImpersonator* _meeple = meeple;
    
    followMeeple = [_world createBlockAnimator];
    [followMeeple setDelay:1.5];
    [followMeeple setAsyncProcessing:NO];
    [followMeeple addListener:^(float sp, NSNumber *event, int message) {
        
        distance = [_dromedarImp.translation distanceTo: _meeple.translation];
        
        direction = [[YAVector3f alloc] initCopy:_dromedarImp.translation];
        [direction subVector:_meeple.translation];
        
        if(!direction.x == direction.y == direction.z == 0)
            [direction normalize];
        
        float angle = ToDegree(acosf([direction dotVector: [[YAVector3f alloc] initZAxe]]));
        
        
        if(_meeple.translation.x < _dromedarImp.translation.x)
            angle = 360 - angle;
        
        
        YAQuaternion* quat = [[YAQuaternion alloc]initEulerDeg:-angle pitch:-90 roll:0];
        
        if(angle != _dromedarImp.rotation.y)
            isRotationg = true;
        else
            isRotationg = false;
        
        _dromedarImp.rotation.y = angle; // memorize last orientation
        [_dromedarImp setRotationQuaternion:quat];
        
        
        if(distance > desiredDistance + margin) {
            [_dm setActive:walk];
            [direction mulScalar:dromedarSpeed];
            [[_dromedarImp translation] subVector:direction];
            _dromedarImp.translation.y = groundLevel;
            [__be syncImp:_dromedarImp.identifier];
        } else if (distance < desiredDistance - margin) {
            [_dm setActive:walk];
            [direction mulScalar:dromedarSpeed];
            [[_dromedarImp translation] addVector:direction];
            _dromedarImp.translation.y = groundLevel;
            [__be syncImp:_dromedarImp.identifier];
        } else {
            if(!isRotationg) {
                [_dm setActive:none];
                [_dm reset];
            } else {
                [_dm setActive:walk];
            }
        }
        
    }];
    
    
}


- (void) createMiniShopCrystaliteFrom: (YAImpersonator*) board Visible: (bool) visible
{
    
    if(crystaliteImp == nil) {
        crystaliteBoardImp = board;
        int crystaliteImpId = [_world createImpersonator:@"CrystaliteTile"];
        crystaliteImp = [_world getImpersonator:crystaliteImpId];
        [[crystaliteImp translation] setVector:board.translation];
        [[crystaliteImp rotation] setValues:-90 :0 :0];
        [crystaliteImp resize:0.5];
        crystaliteImp.translation.y += 0.66666;
        [[[crystaliteImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.202 : 0.202 : 0.202 ]];
        [[[crystaliteImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.371 : 0.371 : 0.371 ]];
        [[[crystaliteImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.326 : 0.326 : 0.326 ]];
        [[crystaliteImp material] setPhongShininess: 3.679];
        
        YABasicAnimator* ba = [_world createBasicAnimator];
        [ba addListener:crystaliteImp.rotation factor:360];
        [ba setInfluence:Y_AXE];
    }
    
    [crystaliteImp setVisible:visible];
    [crystaliteImp setClickable:visible];
}

- (void) createMiniShopSmithoreFrom: (YAImpersonator*) board Visible: (bool) visible
{
    if(smithoreImp == nil) {
        smithoreBoardImp = board;
        int smithoreImpId = [_world createImpersonator:@"SmithoreTile"];
        smithoreImp = [_world getImpersonator:smithoreImpId];
        [[smithoreImp translation] setVector:board.translation];
        [[smithoreImp rotation] setValues:-90 :0 :0];
        [smithoreImp resize:0.25];
        smithoreImp.translation.y += 0.66666;
        [[[smithoreImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.209 : 0.209 : 0.209 ]];
        [[[smithoreImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.056 : 0.056 : 0.056 ]];
        [[[smithoreImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.785 : 0.785 : 0.785 ]];
        [[smithoreImp material] setPhongShininess: 1.05];
        
        YABasicAnimator* ba = [_world createBasicAnimator];
        [ba addListener:smithoreImp.rotation factor:360];
        [ba setInfluence:Y_AXE];
    }
    
    [smithoreImp setVisible:visible];
    [smithoreImp setClickable:visible];
}

- (void) createMiniShopEnergyFrom: (YAImpersonator*) board Visible: (bool) visible
{
    if(energyImp == nil) {
        energyBoardImp = board;
        int energyImpId = [_world createImpersonator:@"SolarplantTile"];
        energyImp = [_world getImpersonator:energyImpId];
        [[energyImp translation] setVector:board.translation];
        [[energyImp rotation] setValues:-90 :0 :0];
        [energyImp resize:0.10];
        energyImp.translation.y += 0.66666;
        [[[energyImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.209 : 0.209 : 0.209 ]];
        [[[energyImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.056 : 0.056 : 0.056 ]];
        [[[energyImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.785 : 0.785 : 0.785 ]];
        [[energyImp material] setPhongShininess: 1.05];
        
        YABasicAnimator* ba = [_world createBasicAnimator];
        [ba addListener:energyImp.rotation factor:360];
        [ba setInfluence:Y_AXE];
    }
    
    [energyImp setVisible:visible];
    [energyImp setClickable:visible];

}

- (void) createMiniFarmFrom: (YAImpersonator*) board Visible: (bool) visible
{
    if(farmImp == nil) {
        farmBoardImp = board;
        int farmImpId = [_world createImpersonator:@"FarmhouseTile"];
        farmImp = [_world getImpersonator:farmImpId];
        [[farmImp translation] setVector:board.translation];
        [[farmImp rotation] setValues:-90 :0 :0];
        [farmImp resize:0.10];
        farmImp.translation.y += 0.66666;
        [[[farmImp material] phongAmbientReflectivity] setVector:[[YAVector3f alloc] initVals: 0.209 : 0.209 : 0.209 ]];
        [[[farmImp material] phongDiffuseReflectivity] setVector:[[YAVector3f alloc] initVals: 0.056 : 0.056 : 0.056 ]];
        [[[farmImp material] phongSpecularReflectivity] setVector:[[YAVector3f alloc] initVals: 0.4 : 0.4 : 0.4 ]];
        [[farmImp material] setPhongShininess: 1.05];
        
        YABasicAnimator* ba = [_world createBasicAnimator];
        [ba addListener:farmImp.rotation factor:360];
        [ba setInfluence:Y_AXE];
    }
    
    [farmImp setVisible:visible];
    [farmImp setClickable:visible];
}


- (void) buyCrystaliteFrom: (YAImpersonator*) board
{
    crystaliteBought = true;
    // NSLog(@"Buy Crystalite Factory");
    YAInterpolationAnimator* bb = [_world createInterpolationAnimator];
    [bb addListener:crystaliteImp.translation];
    [bb addIpo:crystaliteImp.translation timeFrame:0.2];
    [bb addIpo:[[YAVector3f alloc] initVals:crystaliteImp.translation.x :crystaliteImp.translation.y :-1] timeFrame:1];
    [bb addIpo:[[YAVector3f alloc] initVals:crystaliteImp.translation.x + 10.5 :crystaliteImp.translation.y - 1 :-1] timeFrame:1.5];
    
    _lastPurchase = HOUSE_CRYSTALYTE;
    
}

- (void) buySmithoreFrom: (YAImpersonator*) board
{
    smithoreBought = true;
    // NSLog(@"Buy Smithore Factory");
    YAInterpolationAnimator* bb = [_world createInterpolationAnimator];
    [bb addListener:smithoreImp.translation];
    [bb addIpo:smithoreImp.translation timeFrame:0.2];
    [bb addIpo:[[YAVector3f alloc] initVals:smithoreImp.translation.x :smithoreImp.translation.y :-1] timeFrame:1];
    [bb addIpo:[[YAVector3f alloc] initVals:smithoreImp.translation.x + 8.5 :smithoreImp.translation.y - 2 :-1] timeFrame:1.5];
    
    _lastPurchase = HOUSE_SMITHORE;
    
}

- (void) buyEnergyFrom: (YAImpersonator*) board
{
    energyBought = true;
    // NSLog(@"Buy Energy Factory");
    YAInterpolationAnimator* bb = [_world createInterpolationAnimator];
    [bb addListener:energyImp.translation];
    [bb addIpo:energyImp.translation timeFrame:0.2];
    [bb addIpo:[[YAVector3f alloc] initVals:energyImp.translation.x :energyImp.translation.y :-1] timeFrame:1];
    [bb addIpo:[[YAVector3f alloc] initVals:energyImp.translation.x + 6.5 :energyImp.translation.y - 1 :-1] timeFrame:1.5];
    
    _lastPurchase = HOUSE_ENERGY;
}

- (void) buyFarmFrom: (YAImpersonator*) board
{
    farmBought = true;
    // NSLog(@"Buy Farm");
    YAInterpolationAnimator* bb = [_world createInterpolationAnimator];
    [bb addListener:farmImp.translation];
    [bb addIpo:farmImp.translation timeFrame:0.2];
    [bb addIpo:[[YAVector3f alloc] initVals:farmImp.translation.x :farmImp.translation.y :-1] timeFrame:1];
    [bb addIpo:[[YAVector3f alloc] initVals:farmImp.translation.x + 4.5 :farmImp.translation.y - 1 :-1] timeFrame:1.5];
    
    _lastPurchase = HOUSE_FARM;
}

// WARNING: Must be set at runtime at correct scale
- (void) setEnvironment: (YABulletEngineTranslator*) be
{
    const bool isTournament = _gameContext.gameDifficulty >= 2;

    _be = be;
    NSMutableArray* phsicImps = [be physicImps];
    YAImpGroup* shop = [_colonyMap getHouseGroupAtX:3 Z:3];
    
    NSMutableArray* shopImps = shop.allImps;
    
    int loopEnum = 0;
    for(YAImpersonator* imp in shopImps) {
        loopEnum++;
        NSString* impIngredient = imp.ingredientName;
        
        if([impIngredient isEqualToString:@"shopSocket"]) {
            _shopSocket = imp;
            const float scaleHalfe = 0.5f;
            imp.mass = @0.0f; // immovable
            YAVector3f* origin = [[YAVector3f alloc] initVals:0 :0 :0];
            YAVector3f* boxHalfExtents = [[YAVector3f alloc] initVals :0.799 :0.03033 :0.805];
            [boxHalfExtents mulScalar:scaleHalfe];
            imp.boxOffset = origin;
            imp.boxHalfExtents = boxHalfExtents;
            [phsicImps addObject:imp];
            [_localPhysicImps addObject:imp];
        } else if([impIngredient isEqualToString:@"shopTable"]) {
            
            if(!isTournament &&  loopEnum == 72) {
                imp.visible = false;
                continue;
            }
            
            const float scaleHalfe = 0.5f;
            imp.mass = @0.0f; // immovable
            YAVector3f* origin = [[YAVector3f alloc] initVals:0 :-0.0193 / 2 :0];
            YAVector3f* boxHalfExtents = [[YAVector3f alloc] initVals:0.03147 :0.0196 :0.06311];
            [boxHalfExtents mulScalar:scaleHalfe];
            imp.boxOffset = origin;
            imp.boxHalfExtents = boxHalfExtents;
            [imp setShadowCaster:YES];
            [contactImps addObject:imp];
            [phsicImps addObject:imp];
        } else if([impIngredient isEqualToString:@"shopPole"]) { // x->z y->x z->y
            const float scaleHalfe = 0.5f;
            imp.mass = @0.0f; // immovable
            YAVector3f* origin = [[YAVector3f alloc] initVals:0 :-0.02778 / 2 :0];
            YAVector3f* boxHalfExtents = [[YAVector3f alloc] initVals:0.01670 :0.02778 :0.01670];
            [boxHalfExtents mulScalar:scaleHalfe];
            imp.boxOffset = origin;
            imp.boxHalfExtents = boxHalfExtents;
            [phsicImps addObject:imp];
            [_localPhysicImps addObject:imp];
        } else if([impIngredient isEqualToString:@"shopPoleJoint"]) { // x->z y->x z->y
            const float scaleHalfe = 0.5f;
            imp.mass = @0.0f; // immovable
            YAVector3f* origin = [[YAVector3f alloc] initVals:0 :0 :0];
            YAVector3f* boxHalfExtents = [[YAVector3f alloc] initVals:0.01670 :0.002794 :0.03425];
            [boxHalfExtents mulScalar:scaleHalfe];
            imp.boxOffset = origin;
            imp.boxHalfExtents = boxHalfExtents;
            [phsicImps addObject:imp];
            [_localPhysicImps addObject:imp];
        } else if([impIngredient isEqualToString:@"shopBulletinBoard"]) { // x->z y->x z->y
            
            if(!isTournament && loopEnum == 2) {
                imp.visible = false;
                continue;
            }
                
            
            const float scaleHalfe = 0.5f;
            imp.mass = @0.0f; // immovable
            YAVector3f* origin = [[YAVector3f alloc] initVals:0 :0 :0];
            YAVector3f* boxHalfExtents = [[YAVector3f alloc] initVals:0.02486 :0.0284 :0.0282];
            [boxHalfExtents mulScalar:scaleHalfe];
            imp.boxOffset = origin;
            imp.boxHalfExtents = boxHalfExtents;
            [phsicImps addObject:imp];
            [contactImps addObject:imp];
        } else if([impIngredient isEqualToString:@"shopPlaceSign"]) { // x->z y->x z->y
            _shopPlaceSign = imp;
        } else if([impIngredient isEqualToString:@"shopAssayMag"] && !isTournament) {
            imp.visible = false;
        } else if([impIngredient isEqualToString:@"shopPaperCrystalite"] && !isTournament) {
            imp.visible = false;
        }
    }
    
}

- (void) produceCamels
{
    int missingCamels = maxCamels - camelsAvailable;
    int usedSmithore = (missingCamels * 2) < smithoreStock ? missingCamels * 2 : smithoreStock;
    smithoreStock -= usedSmithore;
    camelsAvailable += (usedSmithore / 2);
    // NSLog(@"Camels Produced: %d", (usedSmithore / 2));
}

- (void) updatePrices
{
    int missingCamels = maxCamels - camelsAvailable;
    float necessarySmithore = (missingCamels * 2);

    float  necessaryFood = 3 * 4;
    if (_gameContext.round >= 5)
        necessaryFood = 4 * 4;
    else if(_gameContext.round >= 9)
        necessaryFood = 5 * 4;
    
    float necessaryEnergy = 0;
     [_colonyMap getAllProduction];
    
    for (YAVector2i* plot in [_colonyMap getAllProduction]) {
        house_type house = [_colonyMap plotHouseAtX:plot.x Z:plot.y];
        if(house != HOUSE_ENERGY && house != HOUSE_NONE)
            necessaryEnergy += 1.0f;
    }
    
    int playerFoodResources = 0;
    int playerEnergyResources = 0;
    for (YAAlienRace* player in [_gameContext playerGameData]) {
        playerFoodResources += player.foodUnits;
        playerEnergyResources += player.energyUnits;
    }
        
    float foodDiv = foodStock + playerFoodResources;
    float energyDiv = energyStock + playerEnergyResources;
    float smithoreDiv = smithoreStock;
    
    if(foodDiv <= 0)
        foodDiv = 1;
    
    if(energyDiv <= 0)
        energyDiv = 1;
    
    if(smithoreDiv <= 0)
        smithoreDiv = 1;
    
    float foodRatio = necessaryFood / foodDiv;
    float energyRatio = necessaryEnergy / energyDiv;
    float smithoreRatio = necessarySmithore / smithoreDiv;
    
    foodUnitPrice = (foodUnitPrice * 0.25) + (foodUnitPrice * foodRatio * 0.75);
    energyUnitPrice = (energyUnitPrice * 0.25) + (energyUnitPrice * energyRatio * 0.75);
    smithoreUnitPrice = (smithoreUnitPrice * 0.25) + (smithoreUnitPrice * smithoreRatio * 0.75);
    crystaliteUnitPrice = 50 + [YAProbability random] * 100;

    if(foodUnitPrice < 10)
        foodUnitPrice = 10;
    else if(foodUnitPrice > 200)
        foodUnitPrice = 200;

    if(energyUnitPrice < 10)
        energyUnitPrice = 10;
    else if (energyUnitPrice > 200)
        energyUnitPrice = 200;
    
    if(smithoreUnitPrice < 25)
        smithoreUnitPrice = 25;
    else if(smithoreUnitPrice > 200)
        smithoreUnitPrice = 200;
    
    camelPrice = (smithoreUnitPrice * 2);
}

-(void) timeIsUp
{
    // NSLog(@"Store Time Is Up.");
    [_moveAlien setDeleteme:YES];
    [followMeeple setDeleteme:YES];
    
    // remove Imps from bullet engine
    NSMutableArray* physicImps = [_be physicImps];
    NSMutableArray* newPhysicImps = [[NSMutableArray alloc] init];
    
    for(YAImpersonator* imp in physicImps) {
        if(![contactImps containsObject:imp] && imp != meeple && imp != dromedarImp && ![_localPhysicImps containsObject:imp] ) {
            [newPhysicImps addObject:imp];
        }
    }
    
    
    [_be setPhysicImps:newPhysicImps];
    [_be restart];
    
    [_world removeImpersonator:crystaliteImp.identifier];
    [_world removeImpersonator:smithoreImp.identifier];
    [_world removeImpersonator:energyImp.identifier];
    [_world removeImpersonator:farmImp.identifier];
    [_world removeImpersonator:shopSignText.identifier];
    crystaliteImp = nil;
    smithoreImp = nil;
    energyImp = nil;
    farmImp = nil;
    shopSignText = nil;
    
    for(YAImpersonator* cr in _playerColorRings) {
        [cr setVisible:NO];
        [_world removeImpersonator:cr.identifier];
    }
    
    
    [dm setActive:none];
    [dm reset];
    [dm cleanup];
    dm = nil;
    [_world removeImpersonator:dromedarImp.identifier];
    
    YABlockAnimator* once = [_world createBlockAnimator];
    [once setOneExecution:YES];
    [once addListener:^(float sp, NSNumber *event, int message) {
        [_animator setActive:none];
        [_animator reset];
        [meeple setVisible:NO];
    }];
    
    double scale = 1.0 / 23.0;
    [_world rescaleScene:scale];
    // NSLog(@"World Rescaled");
    [_sceneUtils updateFrustumTo:-1]; // default
    
    // disable mouse tracking
    [_world setTraceMouseMove:NO];
    [_colonyMap resetFabs];
    return;

}

@end
