//
//  YAGameContext.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 23.07.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YAVector3f.h"

#import "YARenderLoop.h"
#import "YAAlienRace.h"
#import "YAHumanRace.h"
#import "YAMechatronRace.h"
#import "YABonzoidRace.h"
#import "YAFlapperRace.h"
#import "YAGollumerRace.h"
#import "YALeggiteRace.h"
#import "YAPackerRace.h"
#import "YASpheroidRace.h"

#import "YAGameContext.h"

@implementation YAGameContext
@synthesize playerNumber, gameDifficulty, colorVectors, playerGameData, round;
@synthesize activePlayer, gameOver;

- (id) init
{
    self = [super init];
    if (self) {
        
        round = 0;
        playerNumber = 0;
        gameDifficulty = 0;
        gameOver = NO;
        
        playerInputDevices = [[NSMutableDictionary alloc] init];
        deviceLock = [NSLock new];
        
        playerColors =  [[NSMutableDictionary alloc] init];
        colorLock = [NSLock new];
        
        playerSpecies = [[NSMutableDictionary alloc] init];
        speciesLock = [NSLock new];
        
        colorVectors = [[NSArray alloc] initWithObjects:
                        [[YAVector3f alloc] initVals:1 :0 :0],
                        [[YAVector3f alloc] initVals:1 :1 :0],
                        [[YAVector3f alloc] initVals:0 :1 :0],
                        [[YAVector3f alloc] initVals:0 :0 :1],
                        [[YAVector3f alloc] initVals:0 :1 :1],
                        [[YAVector3f alloc] initVals:0.475 :0 :0.196],
                        [[YAVector3f alloc] initVals:1 :0 :1],
                        [[YAVector3f alloc] initVals:0.333 :0 :0.455],
                        nil ];
        
        
        activePlayer = -1;
    }
    
    
    return self;
}

-(void)setDeviceId: (int) deviceId forPlayer: (int) player
{
    [deviceLock lock];
    [playerInputDevices setObject:[NSNumber numberWithInt:deviceId] forKey:[NSNumber numberWithInt:player]];
    [deviceLock unlock];
    
}
-(int)deviceIdforPlayer: (int) player
{
    [deviceLock lock];
    NSNumber* deviceId = [playerInputDevices objectForKey:[NSNumber numberWithInt:player]];
    [deviceLock unlock];
    
    if (deviceId == nil)
        return - 1;
    else
        return [deviceId intValue];
}

-(void)clearAllDevices
{
    [deviceLock lock];
    playerInputDevices = [[NSMutableDictionary alloc] init];
    [deviceLock unlock];
}

-(void)clearDeviceId: (int) deviceId
{
    int playerId = -1;
    
    [deviceLock lock];
    NSArray* allplayer = [playerInputDevices allKeys];
    [deviceLock unlock];
    
    for (NSNumber* playerNum in allplayer) {
        int actDevice = [[playerInputDevices objectForKey:playerNum] intValue];
        if(actDevice == deviceId)
            playerId = playerNum.intValue;
    }
    
    if(playerId != -1)
        [playerInputDevices removeObjectForKey:[NSNumber numberWithInt:playerId]];
}


-(int) playerForDevice: (int) deviceId
{
    int playerId = -1;
    
    [deviceLock lock];
    NSArray* allplayer = [playerInputDevices allKeys];
    [deviceLock unlock];
    
    for (NSNumber* playerNum in allplayer) {
        int actDevice = [[playerInputDevices objectForKey:playerNum] intValue];
        if(actDevice == deviceId)
            playerId = playerNum.intValue;
    }
    
    return playerId;
}

-(BOOL) allInputDevicesAssigned
{
    return playerInputDevices.count >= playerNumber;
}

-(void) setColor: (int) color forPlayer: (int) player
{
    [colorLock lock];
    [playerColors setObject:[NSNumber numberWithInt:color] forKey:[NSNumber numberWithInt:player]];
    [colorLock unlock];
}

-(int) getColorForPlayer: (int) player
{
    [colorLock lock];
    NSNumber* colorNum = [playerColors objectForKey:[NSNumber numberWithInt: player]];
    [colorLock unlock];
    
    if(colorNum == nil)
        return -1;
    else
        return colorNum.intValue;
}


- (bool) colorAvailable: (int) color
{
    return [[playerColors allValues] indexOfObject:[NSNumber numberWithInt:color]] == NSNotFound;
}

-(bool) allPlayerColorsAssigned
{
    return playerNumber == [playerColors count];
}


-(void) setSpecies: (NSString*) species forPlayer: (int) player
{
    [speciesLock lock];
    [playerSpecies setObject:species forKey:[NSNumber numberWithInt:player]];
    [speciesLock unlock];
}

-(NSString*) getSpeciesForPlayer: (int) player
{
    [speciesLock lock];
    NSString* species = [playerSpecies objectForKey:[NSNumber numberWithInt:player] ];
    [speciesLock unlock];
    
    // Bots use Mechatron
    if(species == nil)
        species = @"Mechatron";
    
    return species;
}


- (void)setupPlayerGameData: (YARenderLoop*) world
{

    NSMutableArray* tempArray = [[NSMutableArray alloc] initWithCapacity:4];
    
    for(int i = 0; i < 4; i++) {
        NSString* playerRaceName = [self getSpeciesForPlayer:i];
        
        YAAlienRace* player = nil;
        
        if([playerRaceName isEqualToString:@"Bonzoid"]) {
            player = [[YABonzoidRace alloc] initInWorld:world PlayerId:i];
            player.money = 1000;
        } else if([playerRaceName isEqualToString:@"Flapper"]) {
            player = [[YAFlapperRace alloc] initInWorld:world PlayerId:i];
            player.money = 1600;
        } else if([playerRaceName isEqualToString:@"Gollumer"]) {
            player = [[YAGollumerRace alloc] initInWorld:world PlayerId:i];
            player.money = 1000;
        } else if([playerRaceName isEqualToString:@"Humanoid"]) {
            player = [[YAHumanRace alloc] initInWorld:world PlayerId:i];
            player.money = 600;
        } else if([playerRaceName isEqualToString:@"Leggit"]) {
            player = [[YALeggiteRace alloc] initInWorld:world PlayerId:i];
            player.money = 1000;
        } else if([playerRaceName isEqualToString:@"Mechatron"]) {
            player =  [[YAMechatronRace alloc] initInWorld:world PlayerId:i];
            player.money = 1000;
        } else if([playerRaceName isEqualToString:@"Paker"]) {
            player = [[YAPackerRace alloc] initInWorld:world PlayerId:i];
            player.money = 1000;
        } else if([playerRaceName isEqualToString:@"Spheroid"]) {
            player = [[YASpheroidRace alloc] initInWorld:world PlayerId:i];
            player.money = 1000;
        }
        
        if(gameDifficulty == 0) {
            player.foodUnits = 8;
            player.energyUnits = 4;
        } else  {
            player.foodUnits = 4;
            player.energyUnits = 2;
        }
        
        if(i >= playerNumber) {
                player.money = 1000;
             if(gameDifficulty >= 2)
                 player.money = 1200;
        }
        
        [tempArray addObject:player];

        
    }
    
    playerGameData = [[NSArray alloc] initWithArray:tempArray];
    
}

- (YAAlienRace*) playerDataForId: (int) id
{
    YAAlienRace* player;
    for(YAAlienRace* ar in playerGameData) {
        if(ar.playerId == id)
            player = ar;
    }

    return player;
}

- (int) finalRound
{
    if(gameDifficulty == 0)
        return 6;
    else
        return 12;
}

- (float) calcAuctionTime
{
    const float auctionTime = gameDifficulty != 0 ? 15 : 25;
    return auctionTime;
}

- (float) calcDevelopmentTime
{
    const float developmentTime = gameDifficulty != 0 ? 45 : 55;
    return developmentTime;
}


-(NSString*) description 
{
    NSString* result = [NSString stringWithFormat:@"\nactivePlayer:%d\ngameOver:%d\nround:%d\nplayerNumber:%d\ngameDifficulty:%d\nlastAuction:%d"
        ,activePlayer, gameOver, round ,playerNumber, gameDifficulty ,_lastAuction];

    return result;
}

@end
