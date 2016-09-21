//
//  YAGameContext.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 23.07.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YAAlienRace.h"
@class YARenderLoop;

@interface YAGameContext : NSObject {
    NSMutableDictionary* playerInputDevices;
    NSLock* deviceLock;
    
    NSMutableDictionary* playerColors;
    NSLock* colorLock;
    
    NSMutableDictionary* playerSpecies;
    NSLock* speciesLock;
}

@property int activePlayer; // for shopping and flying events

@property bool gameOver;
@property int round;
@property int playerNumber;
@property int gameDifficulty;
@property int lastAuction;

@property (strong, readwrite) NSArray* playerGameData;
@property (strong, readonly) NSArray* colorVectors;

-(void)setDeviceId: (int) deviceId forPlayer: (int) player;
-(void)clearDeviceId: (int) deviceId;
-(void)clearAllDevices;

-(int)deviceIdforPlayer: (int) player;
-(int) playerForDevice: (int) deviceId;

-(BOOL) allInputDevicesAssigned;

-(void) setColor: (int) color forPlayer: (int) player;
-(int) getColorForPlayer: (int) player;
- (bool) colorAvailable: (int) color;

-(bool) allPlayerColorsAssigned;

-(void) setSpecies: (NSString*) species forPlayer: (int) player;
-(NSString*) getSpeciesForPlayer: (int) player;

- (void)setupPlayerGameData: (YARenderLoop*) world;

- (YAAlienRace*) playerDataForId: (int) id;

- (int) finalRound;

- (float) calcAuctionTime;
- (float) calcDevelopmentTime;

@end


