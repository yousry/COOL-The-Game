//
//  YAEagleController.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 16.10.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YAGameContext.h"
#import "YAInertiaMovement.h"
#import "YASpotLight.h"
#import "YAVector2f.h"
#import "YAVector2i.h"
#import "YASoundCollector.h"
#import "YAImpCollector.h"
#import "YAEvent.h"
#import "YAEventChain.h"
#import "YAOpenAL.h"
#import "YABulletEngineTranslator.h"
#import "YAQuaternion.h"
#import "YATerrain.h"
#import "YAAvatar.h"
#import "YASceneUtils.h"
#import "YAMaterial.h"
#import "YAImpersonator.h"
#import "YAColonyMap.h"
#import "YAVector3f.h"
#import "YARenderLoop.h"
#import "YABlockAnimator.h"
#import "YAImpGroup.h"
#import "YAEagleController.h"

#define ToRadian(x) ((x) * M_PI / 180.0f)
#define ToDegree(x) ((x) * 180.0f / M_PI)
#define ToGrad(x) ((x) * M_PI / 360.0f)

#define turnLimit 3.0f
#define speedXLimit 0.025
#define speedZLimit 0.01
#define speedYLimit 0.01
#define rotXLimit 0.25
#define rotZLimit 0.8
#define gPadSpeedMap 120.0f
#define zeroRg 0.1

#define AVERAGE_SAMPLES 5

@implementation YAEagleController {
    // movement
    YAVector3f *newRotation;
    YAQuaternion *quatRot;
    YAVector3f *direction;
    float intervalTime;
    
    YAInertiaMovement* inertiaMovement;
    
    // Mouse values
    YAVector2f* screenCoords;
    YAVector2i* scrollDelta;
    
    int _activePlayer;
}

@synthesize state;

const float flightBox = 5.5;
const float maxHeigh = 3.5;


int latestSamplePos = 0;
float samples[AVERAGE_SAMPLES];


float addAndGetAverage(float val) {
    
    const int samplePos = ++latestSamplePos % AVERAGE_SAMPLES;
    samples[samplePos] = val;
    
    float result = 0;
    for(int i = 0; i < AVERAGE_SAMPLES; i++)
        result += samples[i];
    
    return result / AVERAGE_SAMPLES;
}

- (id) initFor: (YAImpGroup*) eagleGroup
       inWorld: (YARenderLoop*) world
     colonyMap: (YAColonyMap*) colMap
      flyAbove: (YAImpersonator*) terrainImp
     withUtils: (YASceneUtils*) sceneUtils
    forTerrain: (YATerrain*) terrain
    withPhysic: (YABulletEngineTranslator*) be
soundCollector: (YASoundCollector*) sc
    eventChain: (YAEventChain*) eventChain
  impCollector: (YAImpCollector*) ic
   gameContext: (YAGameContext*) gameContext
{
    
    self = [super init];
    if(self) {
        
        screenCoords = [[YAVector2f alloc] init];
        scrollDelta = [[YAVector2i alloc] init];
        
        for(int i = 0; i < AVERAGE_SAMPLES; i++)
            samples[i] = 1.0f;
        
        intervalTime = 1.0f;
        
        xSpeed = 0;
        ySpeed = 0;
        zSpeed = 0;
        turnSpeed = 0;
        
        xLPadPos = 0;
        ybPadPos = 0;
        zLPadPos = 0;
        xRPadPos = 0;
        
        if([eagleGroup.state isEqualToString:@"withPod"])
            hasCargo = true;
        else
            hasCargo = false;
        
        _world = world;
        _eagleGroup = eagleGroup;
        _colMap = colMap;
        _terrainImp = terrainImp;
        _sceneUtils = sceneUtils;
        _terrain = terrain;
        afterburners = [eagleGroup.observers subarrayWithRange:(NSRange){eagleGroup.observers.count - 4, 4}];
        
        // Bullet Engine
        _be = be;
        
        _soundHandler = sc.soundHandler;
        _soundThrustId = [sc getSoundId:@"EagleThrust"];
        _soundBackdrive = [sc getSoundId:@"EagleBackDrive"];
        _soundEngineId = [sc getSoundId:@"EagleEngine"];
        
        _eventChain = eventChain;
        _gameContext = gameContext;
        
        _ic = ic;
        _sc = sc;
        
        inertiaMovement =  [[YAInertiaMovement alloc] init];
        inertiaMovement.transformator = world.transformer;
        inertiaMovement.avatar = world.avatar;
    }
    
    return self;
}

static inline void collisonDetection(YAImpersonator *_terrainImp, YAImpGroup *_eagleGroup, YATerrain *_terrain, YAEagleController *wS)
{
    // collision detection
    int terrainGrid = _terrain.terrainDimension;
    
    float terrainSize = _terrainImp.size.x;
    const float worldOffset = terrainSize;
    int x = (_eagleGroup.translation.x + worldOffset) / (terrainSize * 2) * terrainGrid;
    int z = (_eagleGroup.translation.z + worldOffset) / (terrainSize * 2) * terrainGrid;
    
    float height = -1;
    
    int shipSizeInGrids = 3;
    
    if(_terrain.terrainDimension == 65)
        shipSizeInGrids = 2;
    else if(_terrain.terrainDimension == 33)
        shipSizeInGrids = 1;

    for(int shS = -shipSizeInGrids; shS <= shipSizeInGrids; shS++) {
        float h = -1;
        int xx = x;
        int zz = z + shS;
        
        if(xx >= 0 && xx <= 127 && zz >= 0 && zz <= 127)
            h = [wS->_terrain heightAt:xx :zz];
        
        if (h > height)
            height = h;
    }

    
    height = (height / 255) * _terrainImp.normalMapFactor * _terrainImp.size.y + 0.025;
    
    if(_eagleGroup.translation.y < height)
        _eagleGroup.translation.y = height;
    else if(_eagleGroup.translation.y > maxHeigh)
        _eagleGroup.translation.y = maxHeigh;
    
    if(fabs(_eagleGroup.translation.x) > flightBox)
        _eagleGroup.translation.x = copysignf(flightBox, _eagleGroup.translation.x);
    
    if(fabs(_eagleGroup.translation.z) > flightBox)
        _eagleGroup.translation.z = copysignf(flightBox, _eagleGroup.translation.z);
    
    [wS->_be syncImp:wS->_eagleGroup.identifier];
    wS->_height = height;
}

static inline void updateAfterburner(float zLPadPos, YAEagleController *wS, NSArray *afterburners)
{
    float steam = fabs(wS->zLPadPos * 2);
    for(YAImpersonator* imp in wS->afterburners)
        [[imp material] setEta:steam];
}

- (void)eagleLand:(YAEagleController *)wS
{
    YAVector3f* rot = [wS->_eagleGroup rotation];
    rot.x = 0;
    rot.z = 0;
    
    YAVector3f* pos = [wS->_eagleGroup translation];
    
    rot.y = fmod(rot.y, 360);
    if(rot.y < 0)
        rot.y = 360 + rot.y;
    
    if(rot.y > 90 && rot.y < 180)
        rot.y += (180 - rot.y) / 15;
    else if (rot.y > 180 && rot.y < 270)
        rot.y -= (rot.y - 180) / 15;
    else if (rot.y > 0 && rot.y < 90)
        rot.y -= rot.y / 15;
    else if(rot.y >= 270 && rot.y < 360)
        rot.y += (360 - rot.y) / 15;
    
    YAVector3f* fPos = [[YAVector3f alloc] initCopy:[[wS->_colMap getHouseGroupAtX:3 Z:3] translation]];
    fPos.x += 0.22978;
    fPos.y += 0.03042;
    
    if(pos.y > fPos.y)
        pos.y -= (pos.y -fPos.y) / 15;
    
    if(pos.x > fPos.x)
        pos.x -= (pos.x - fPos.x) / 15;
    else if(pos.x < fPos.x)
        pos.x += (fPos.x - pos.x) / 15;
    
    if(pos.z > fPos.z)
        pos.z -= (pos.z - fPos.z) / 15;
    else if(pos.z < fPos.z)
        pos.z += (fPos.z - pos.z) / 15;
    
    
    if((fabs(rot.y - 180) < 0.05 || fabs(rot.y) < 0.05) && [fPos distanceTo:pos] < 0.002 ) {
        [pos setVector:fPos];
        wS->state = EAGLE_LANDED;
        [wS fly:false at:0 withPlayer:_activePlayer];
        wS->zLPadPos = 0;
    }
    
    [wS->_eagleGroup setRotation:rot];
    wS->quatRot = [[YAQuaternion alloc] initEulerDeg:-newRotation.y pitch:newRotation.x roll:newRotation.z];
    [wS->_eagleGroup setRotationQuaternion:wS->quatRot];
    [wS->_eagleGroup setTranslation:pos];
    
}

- (void)eagleControlled:(YAEagleController *)wS sp:(float)sp
{
    const bool isMouse = [_gameContext deviceIdforPlayer:_activePlayer] == 1000;
    
    wS->zSpeed += wS->zLPadPos / gPadSpeedMap;
    wS->xSpeed += wS->xLPadPos / gPadSpeedMap;
    wS->ySpeed += wS->ybPadPos / gPadSpeedMap;
    
    if(isMouse) {
        // NSLog(@"%@", scrollDelta);
        wS->xSpeed += scrollDelta.x * 0.025;
        // scrollDelta.x = 0;
        wS->ySpeed += scrollDelta.y * -0.025;
        // scrollDelta.y = 0;
    }
    
    wS->zSpeed = fmin(fmax(wS->zSpeed, -speedXLimit), speedXLimit / 2);
    wS->xSpeed = fmin(fmax(wS->xSpeed, -speedZLimit), speedZLimit);
    wS->ySpeed = fmin(fmax(wS->ySpeed, -speedYLimit), speedYLimit / 1.2);
    
    wS->turnSpeed = fmin(fmax(wS->turnSpeed + wS->xRPadPos / 2, -turnLimit), turnLimit);
    
    float aktXRot = _eagleGroup.rotation.x;
    float aktYRot = _eagleGroup.rotation.y;
    float aktZRot = _eagleGroup.rotation.z;
    
    
    // save computation time
    if(!isMouse && fabs(wS->turnSpeed) < 0.005f && fabs(wS->zSpeed) < 0.00001f && fabs(wS->xSpeed) < 0.00001f && fabs(wS->ySpeed) < 0.00001f) {
        wS->turnSpeed = 0;
        wS->zSpeed = 0;
        wS->xSpeed = 0;
        wS->ySpeed = 0;
        return;
    }
    
    float delayMultiplier = addAndGetAverage(lastCall * 60.0f);
    
    newRotation = [[YAVector3f alloc] initVals:fmin(fmax(wS->zLPadPos * 8 , aktXRot - rotXLimit), aktXRot + rotXLimit)
                                              :aktYRot - wS->turnSpeed * delayMultiplier
                                              :fmin(fmax(-wS->xLPadPos * 16 , aktZRot - rotZLimit), aktZRot + rotZLimit)];
    
    // Necessary as rotation buffer
    [_eagleGroup setRotation:newRotation];
    
    quatRot = [[YAQuaternion alloc] initEulerDeg:-newRotation.y pitch:newRotation.x roll:newRotation.z];
    
    if(isMouse) {
        YAVector3f* rot = [[YAVector3f alloc]initVals:screenCoords.x :0 :screenCoords.y];

        float angle = 0;
        if(screenCoords.length != 0) {
            [rot normalize];
            angle = 180 + ToDegree(acosf([rot dotVector: [[YAVector3f alloc] initZAxe]]));

            if(rot.x < 0)
                angle *= -1;
        }
        
        _eagleGroup.rotation.y = -angle;
        quatRot = [[YAQuaternion alloc] initEulerDeg:angle pitch:0 roll: 0];
    }
    
    [_eagleGroup setRotationQuaternion:quatRot];
    
    YAVector3f* shipPosition = [_eagleGroup translation];

    const float txSpeed = wS->xSpeed * delayMultiplier;
    const float tySpeed = wS->ySpeed * delayMultiplier;
    const float tzSpeed = (!isMouse) ? wS->zSpeed * delayMultiplier : screenCoords.length * -0.025 * delayMultiplier;

    direction = [[YAVector3f alloc] initZAxe];
    [direction rotate:-_eagleGroup.rotation.y axis:[[YAVector3f alloc] initYAxe]];
    [direction normalize];
    [direction mulScalar:tzSpeed];
    [shipPosition addVector:direction];
    
    direction = [[YAVector3f alloc] initXAxe];
    [direction rotate:-_eagleGroup.rotation.y axis:[[YAVector3f alloc] initYAxe]];
    [direction rotate:-_eagleGroup.rotation.x axis:[[YAVector3f alloc] initXAxe]];
    [direction normalize];
    [direction mulScalar:-txSpeed];
    [shipPosition addVector:direction];
    
    direction = [[YAVector3f alloc] initYAxe];
    [direction mulScalar:tySpeed];
    [shipPosition addVector:direction];

    wS->zSpeed /= 1.05f;
    wS->xSpeed /= 1.1f;
    wS->turnSpeed /= 1.1f;
    wS->ySpeed /= 1.1f;

    if(fabs(wS->zSpeed) < 0.0005)
        wS->zSpeed = 0.0f;
    
    if(fabs(wS->xSpeed) < 0.0005)
        wS->xSpeed = 0.0f;
    
    if(fabs(wS->turnSpeed) < 0.02)
        wS->turnSpeed = 0.0f;
    
    if(fabs(wS->ySpeed) < 0.0005)
        wS->ySpeed = 0.0f;
    
    float dist = [[[wS->_colMap getHouseGroupAtX:3 Z:3] translation] distanceTo:shipPosition];
    if(dist <= 0.5 && wS->state != EAGLE_LANDING) {
        wS->state = EAGLE_LANDING;
        [self cleanup];
        // NSLog(@"Landing");
    }
}

- (void) cleanup
{
    // NSLog(@"Cleanup");
    
    // Delay cleanup to play landing kinematic
    YABlockAnimator* once = [_world createBlockAnimator];
    [once setOneExecution:YES];
    [once setDelay:1.0];
    [once addListener:^(float sp, NSNumber *event, int message) {
        
        // stop engine sound
         [_sc.soundHandler stopSound:[_sc getSoundId:@"EagleEngine"]];
        
        // end kinematics
        [eagleFly setDeleteme:YES];
        eagleFly = nil;
        
        // disable mouse tracking
        [_world setTraceMouseMove:NO];
        
        [_sceneUtils updateFrustumTo:-1];
        
        if([[_eventChain getEvent:@"shopping"] valid])
            [_eventChain resetEvents:[NSArray arrayWithObject:@"shopping"]];
        else
            [_eventChain startEvent:@"shopping"];
    }];
}


- (void) deployCargo
{
    [_eagleGroup setState:@"withoutPod"];
    [_sc playForImp:(YAImpersonator*)_eagleGroup Sound:[_sc getSoundId:@"Jump"]];
    
    
    YAImpersonator* podImp = _ic.podImp;
    YAImpersonator* parachuteImp = _ic.parachuteImp;
    
    YAVector3f* podPos = [[YAVector3f alloc] initCopy:[[[_eagleGroup observers] objectAtIndex:17] translation]];
    YAVector3f* podRot = [[YAVector3f alloc] initCopy:[(YAImpersonator*)[[_eagleGroup observers] objectAtIndex:17] rotation]];
    
    [podImp setVisible:YES];
    [[podImp translation] setVector:podPos];
    [[podImp rotation] setVector:podRot];
    
    [[parachuteImp translation] setVector:podPos];
    
    YABlockAnimator* drop = [_world createBlockAnimator];
    YABlockAnimator* _drop = drop;
    float height = _height;
    
    YAVector2i* claimId = [_colMap getClaimIdAt:_eagleGroup.translation];
    
    YAImpersonator* socketI = [_colMap getSocketImpAtX:claimId.x Z:claimId.y];
    YAImpGroup* groupI = [_colMap getHouseGroupAtX:claimId.x Z:claimId.y];
    
    if(socketI)
        height = socketI.translation.y + (0.67 * socketI.size.y);
    else if (groupI)
        height = groupI.translation.y +  (0.07 * groupI.size.y);
    
    bool destroyed = YES;
    
    if([_colMap plotOwnerAtX:claimId.x Z:claimId.y] == _activePlayer) {
        float distance = [socketI.translation distanceTo:[[YAVector3f alloc] initVals :podImp.translation.x  :socketI.translation.y :podImp.translation.z]];
        if( distance < 0.5) {
            destroyed = NO;
        } else {
            height = _height;
        }
    }
    
    
    __block float lastSP = -1.0;
    
    [drop setInterval:4.0];
    [drop addListener:^(float sp, NSNumber *event, int message) {
        
        if(lastSP != sp) {
            
            float timeSpan = lastSP != -1 ?  sp - lastSP :0.004150f;
            if(timeSpan < 0)
                timeSpan = 1 - lastSP + sp;
            
            lastSP = sp;
            
            float fall = timeSpan * 24.09638554216867f; // 0.1
            
            if(sp >= 0.03) {
                [parachuteImp setVisible:YES];
                fall = timeSpan * 9.63855421686747f; // 0.04
            }
            
            if(podImp.translation.y > height) {
                podImp.translation.y -= fall;
                parachuteImp.translation.y = podImp.translation.y + 0.2;
            } else {
                podImp.translation.y = height;
                [parachuteImp setVisible:NO];
                
                if(!destroyed) {                       
                    int jingleId = [_sc getJingleId:@"melodyF"];
                    [_sc playJingle: jingleId];
                    [_sc playForImp:podImp Sound:[_sc getSoundId:@"Explosion"]];
                    
                    if([[_eventChain getEvent:@"setupFab"] valid])
                        [_eventChain resetEvents:[NSArray arrayWithObject:@"setupFab"]];
                    else
                        [_eventChain startEvent:@"setupFab"];
                    
                } else {
                    [_sc playForImp:podImp Sound:[_sc getSoundId:@"ExplosionB"]];
                    if([[_eventChain getEvent:@"plotAssey"] valid])
                        [_eventChain resetEvents:[NSArray arrayWithObject:@"plotAssey"]];
                    else
                        [_eventChain startEvent:@"plotAssey"];
                }
                
                
                [_drop setDeleteme:YES];
            }
        }
    }];
    
}

- (void) fly: (bool) activate at: (float) time withPlayer: (int) activePlayer;
{
    
    _activePlayer = activePlayer;
    
    // reset State if controller is reused
    if([_eagleGroup.state isEqualToString:@"withPod"])
        hasCargo = true;
    else
        hasCargo = false;
    
    __block float lastVal = 0;
    lastSp = -1;
    lastCall = 0;
    
    if(!activate) {
        [eagleFly setDeleteme:true];
        eagleFly = nil;
    } else if(eagleFly == nil) {
        
        __block YAEagleController* wS = self;
        __weak YAImpGroup* wEagleGroup = _eagleGroup;

        
        // Perhaps the last command from the shop is stored
        __block bool ignoreFirst = false;
        
        state = EAGLE_CONTROLLED;
        collisonDetection(wS->_terrainImp, wS->_eagleGroup, wS->_terrain, wS);
        [[_sceneUtils avatar] lookAt:_eagleGroup.translation];
        
        if([wS->_gameContext deviceIdforPlayer:activePlayer] == 1000)
            [_world setTraceMouseMove:YES];
        
        eagleFly = [_world createBlockAnimator];
        [eagleFly setProgress:cyclic];
        [eagleFly setInterval: intervalTime];
        [eagleFly setDelay:time];
        [eagleFly addListener:^(float sp, NSNumber *event, int message) {
            
            //Time Up?
            if(wS->_gameContext.activePlayer == -1) {
                // NSLog(@"Eaglie Time Is Up.");
                
                // stop engine sound
                [wS->_sc.soundHandler stopSound:[wS->_sc getSoundId:@"EagleEngine"]];
                
                // end kinematics
                [wS->eagleFly setDeleteme:YES];
                wS->eagleFly = nil;
                // disable mouse tracking
                [wS->_world setTraceMouseMove:NO];
                [wS->_sceneUtils updateFrustumTo:-1];
                return;
            }
            
            if(!ignoreFirst) {
                ignoreFirst = true;
                return;
            }
            
            int deviceId = -1;
            deviceId = message >> 16;
            int ev = event.intValue;
            
            if(deviceId == [wS->_gameContext deviceIdforPlayer:activePlayer])
                [wS readGamePad:event Message:message]; // only HIDs send a device ID
            else if([wS->_gameContext deviceIdforPlayer:activePlayer] == 1000 &&
                    (
                        ev == 2 || ev == 3 || ev == 13 || ev ==14 || ev == 33 || ev == 34 ||
                        ev == 35 || ev == 36 || ev == 37 || ev == 38 ||
                        ev == KEY_A || ev == KEY_S || ev == KEY_D || ev == KEY_W
                    )
                   )
                [wS readMouse:event Message:message];
            
            float evVal = (float)(message & 255) / 255.0f - 0.5f;
            
            if(wS->state == EAGLE_CONTROLLED)
                collisonDetection(wS->_terrainImp, wS->_eagleGroup, wS->_terrain, wS);
            
            // audio
            YAVector3f* pos =  [[YAVector3f alloc] initCopy:wS->_eagleGroup.translation];
            [pos subVector:wS->_sceneUtils.avatar.position];
            
            if(![wS->_soundHandler isPlaying:wS->_soundThrustId] &&
               fabs(evVal) > fabs(lastVal) &&
               event.intValue == GAMEPAD_LEFT_Y && fabs(lastVal) <= zeroRg &&
               deviceId == [wS->_gameContext deviceIdforPlayer:activePlayer])
            {
                [wS->_soundHandler updateSound:wS->_soundThrustId toPosition:pos];
                [wS->_soundHandler playSound:wS->_soundThrustId];
            }
            
            if(![wS->_soundHandler isPlaying:wS->_soundEngineId]) {
                [wS->_soundHandler playSound:wS->_soundEngineId];
            }
            
            [wS->_soundHandler updateSound:wS->_soundEngineId toPosition:pos];
            
            if(wS->zSpeed > 0) {
                if(![wS->_soundHandler isPlaying:wS->_soundBackdrive])
                    [wS->_soundHandler playSound:wS->_soundBackdrive];
                
                [wS->_soundHandler updateSound:wS->_soundThrustId toPosition:pos];
                
            } else {
                if([wS->_soundHandler isPlaying:wS->_soundBackdrive])
                    [wS->_soundHandler stopSound:wS->_soundBackdrive];
            }
            
            if(event.intValue == GAMEPAD_LEFT_Y)
                lastVal = evVal;
            
            if(wS->lastSp == -1)
                wS->lastSp = sp;
            
            if(wS->lastSp != sp) {
                
                wS->lastCall = wS->lastSp < sp ? (sp - wS->lastSp) : ((1.0 - wS->lastSp) + sp);
                wS->lastCall *= wS->intervalTime;
                
                wS->lastSp = sp;
                
                if(wS->state == EAGLE_CONTROLLED)
                    [wS eagleControlled:wS sp:sp];
                else if (wS->state == EAGLE_LANDING) {
                    [wS eagleLand:wS];
                }
                
                updateAfterburner(wS->zLPadPos, wS, wS->afterburners);
                [wS->_be syncImp:wS->_eagleGroup.identifier];
                
                if(wS->_colMap.vacantPlots < 10)
                    [[wS->_sceneUtils avatar] recenter:wEagleGroup.translation MarginAtlas:12 MarginAxis:30];
                else
                    [wS->inertiaMovement lookAt:wEagleGroup.translation];
                
                [wS->_sceneUtils.spotLight spotAt:wEagleGroup.translation];
                [wS->_sceneUtils updateSpotLightFrustumUnblocked];
            }
            
        }];
        
    }
}

- (void) readMouse: (NSNumber*) event Message:(int) message
{
    const int scrollOffset = 255;
    int x, y;
    
    // [scrollDelta setValues:0 :0];
    
    switch (event.intValue) {
        case MOUSE_VECTOR:
            x = (message >> 16);
            y = message & 511;
            screenCoords.x = ((float) x / 511 - 0.5) * 2;
            screenCoords.y = ((float) y / 511 - 0.5) * 2;
            break;
         case KEY_LEFT:   
         case KEY_A:
            scrollDelta.x = message >= 1 ? -scrollOffset : 0;
            break; 
         case KEY_RIGHT:   
         case KEY_D:
            scrollDelta.x = message >= 1 ? scrollOffset : 0;
            break;
          case KEY_UP:     
          case KEY_W:
            scrollDelta.y = message >= 1 ? -scrollOffset : 0;
            break;
         case KEY_DOWN:      
         case KEY_S:
            scrollDelta.y = message >= 1 ? +scrollOffset : 0;
            break;   
        case MOUSE_DOWN:
            if(hasCargo) {
                [self deployCargo];
                hasCargo = NO;
            }
            break;
        default:
            break;
    }
}


- (void) readGamePad: (NSNumber*) event Message:(int) message
{
    int evBin = message & 255;
    float evVal = (float)(message & 255) / 255.0f - 0.5f;
    
    switch (event.intValue) {
        case GAMEPAD_LEFT_Y:
            if(fabs(evVal) > zeroRg) {
                zLPadPos = evVal;
            }else
                zLPadPos = 0;
            break;
        case GAMEPAD_LEFT_X:
            if(fabs(evVal) > zeroRg)
                xLPadPos = evVal;
            else
                xLPadPos = 0;
            break;
        case GAMEPAD_RIGHT_Y:
            break;
        case GAMEPAD_RIGHT_X:
            if(fabs(evVal) > zeroRg)
                xRPadPos = evVal;
            else
                xRPadPos = 0;
            break;
        case GAMEPAD_BUTTON_LB:
        case GAMEPAD_BUTTON_A:
            if(evBin == 1)
                ybPadPos = -0.4;
            else
                ybPadPos = 0;
            break;
        case GAMEPAD_BUTTON_RB:
        case GAMEPAD_BUTTON_B:
            if(evBin == 1)
                ybPadPos = + 0.1;
            else
                ybPadPos = 0;
            break;
        case GAMEPAD_BUTTON_OK:
            if(evBin == 1) {
                if(hasCargo) {
                    [self deployCargo];
                    hasCargo = NO;
                }
            }
            break;
        case GAMEPAD_BUTTON_CANCEL:
            break;
        default:
            break;
    }
}

@end
