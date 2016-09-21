//
//  YASoundCollector.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 17.01.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import "YAPreferences.h"
#import "YAAvatar.h"
#import "YAImpersonator.h"
#import "YAVector3f.h"
#import "YAOpenAL.h"
#import "YARenderLoop.h"
#import "YASoundCollector.h"

@implementation YASoundCollector

- (id) initInWorld: (YARenderLoop*) world
{
    self = [super init];
    
    if(self) {
        
 
        YAPreferences* prefs = [[YAPreferences alloc]init];
        baseSfx = sinf(powf(((float)prefs.sfx)/100.0f,4) * M_PI * 0.5);
        
        _world = world;
        _soundHandler = [[YAOpenAL alloc] initInWorld:world];
        _soundHandler.baseVolume = baseSfx;

        NSAssert(_soundHandler, @"Sound handler could not be initilized.");
        
        _origin = [[YAVector3f alloc] init];

        // entry: Filename, Loop
        _soundSources = [[NSDictionary alloc] initWithObjectsAndKeys:
                         [[NSArray alloc] initWithObjects:@"Blip_Select.wav", [NSNumber numberWithBool:NO], nil],     @"Select",
                         [[NSArray alloc] initWithObjects:@"ChirpA.wav", [NSNumber numberWithBool:NO], nil],          @"Chirp",
                         [[NSArray alloc] initWithObjects:@"Explosion.wav", [NSNumber numberWithBool:NO], nil],       @"Explosion",
                         [[NSArray alloc] initWithObjects:@"ExplosionA.wav", [NSNumber numberWithBool:NO], nil],      @"ExplosionA",
                         [[NSArray alloc] initWithObjects:@"ExplosionB.wav", [NSNumber numberWithBool:NO], nil],      @"ExplosionB",
                         [[NSArray alloc] initWithObjects:@"Hit_Hurt.wav", [NSNumber numberWithBool:NO], nil],        @"Hit",
                         [[NSArray alloc] initWithObjects:@"Jump.wav", [NSNumber numberWithBool:NO], nil],            @"Jump",
                         [[NSArray alloc] initWithObjects:@"LaserA.wav", [NSNumber numberWithBool:NO], nil],          @"LaserA",
                         [[NSArray alloc] initWithObjects:@"LaserB.wav", [NSNumber numberWithBool:NO], nil],          @"LaserB",
                         [[NSArray alloc] initWithObjects:@"LaserC.wav", [NSNumber numberWithBool:NO], nil],          @"LaserC",
                         [[NSArray alloc] initWithObjects:@"Laser_Shoot.wav", [NSNumber numberWithBool:NO], nil],     @"Laser",
                         [[NSArray alloc] initWithObjects:@"Pickup_Coin.wav", [NSNumber numberWithBool:NO], nil],     @"Pickup",
                         [[NSArray alloc] initWithObjects:@"Powerup.wav", [NSNumber numberWithBool:NO], nil],         @"Powerup",
                         [[NSArray alloc] initWithObjects:@"countdown.wav", [NSNumber numberWithBool:NO], nil],       @"Countdown",
                         [[NSArray alloc] initWithObjects:@"eagle.wav", [NSNumber numberWithBool:YES], nil],          @"EagleEngine",
                         [[NSArray alloc] initWithObjects:@"eagleBackdrive.wav", [NSNumber numberWithBool:NO], nil],  @"EagleBackDrive",
                         [[NSArray alloc] initWithObjects:@"engineThrust.wav", [NSNumber numberWithBool:NO], nil],    @"EagleThrust",
                         [[NSArray alloc] initWithObjects:@"step.wav", [NSNumber numberWithBool:NO], nil],            @"Step",
                         nil];
        

        
        _jingleSources = [[NSDictionary alloc] initWithObjectsAndKeys:
                    @"BusinessInSpace.ogg",     @"BusinessInSpace",
                    @"camel.ogg",               @"title",
                    @"TestGBA.ogg",             @"melodyA",
                    @"TestGBB.ogg",             @"melodyB",
                    @"TestGBC.ogg",             @"melodyC",
                    @"testB.ogg",               @"melodyD",
                    @"testC.ogg",               @"melodyE",
                    @"testD.ogg",               @"melodyF",
                    @"testE.ogg",               @"melodyG",
                    @"testF.ogg",               @"melodyH",
                    @"BlaueDonau.ogg",          @"BlaueDonau",
                    nil];


        _sounds = [[NSMutableDictionary alloc] initWithCapacity:_soundSources.count + _jingleSources.count];

    }
    return self;
}

// implements lazy loading: Return SoundId or try to load from soundsource
- (int) getSoundId: (NSString*) soundName;
{
    NSNumber* result = [_sounds objectForKey:soundName];

    if(!result) {
        const NSArray* soundDescriptor = [_soundSources objectForKey:soundName];
        if (!soundDescriptor)
            return -1;
        
        const NSString* soundFileName = [soundDescriptor objectAtIndex:0];
        const BOOL loopStatus = [[soundDescriptor objectAtIndex:1] boolValue];
        
        const int bufferId = [_soundHandler loadSound:(NSString*)soundFileName];
        const int soundId = bufferId != -1 ? [_soundHandler setupSound:bufferId atPosition:_origin loop:loopStatus] : -1;
        if (soundId != -1)
            [_sounds setObject:[NSNumber numberWithInt:soundId] forKey:soundName];
        
        // NSLog(@"Sound Loaded: %@ File: %@,  ID: %d", soundName, soundFileName, soundId);
        return soundId;
    } else {
        return result.intValue;
    }
}

- (int) getJingleId: (NSString*) jingleTitle
{
    NSNumber* result = [_sounds objectForKey:jingleTitle];

       if(!result) {
            NSString* soundDescriptor = [_jingleSources objectForKey:jingleTitle];

            int buffer = [_soundHandler loadOgg:soundDescriptor];        
            int soundId = [_soundHandler setupSound:buffer atPosition: [[YAVector3f alloc] init] loop:NO];

            if (soundId != -1)
                [_sounds setObject:[NSNumber numberWithInt:soundId] forKey:jingleTitle];

    return soundId;
    } else {
        return result.intValue;
    }


}


- (void) playForImp: (YAImpersonator*) impersonator Sound: (int) soundId
{
    YAVector3f* pos =  [[YAVector3f alloc] initCopy:impersonator.translation];
    [pos subVector:_world.avatar.position];
    
    // MAGIC
    const float MAGIC_DISTANCE = 0.2f;
    [pos mulScalar:MAGIC_DISTANCE];
    
    [_soundHandler updateSound:soundId toPosition:pos];
    [_soundHandler playSound:soundId];
}


- (void) playJingle: (int) soundId
{
    [_soundHandler playSound:soundId];
}

- (void) stopJingle: (int) soundId
{
    [_soundHandler stopSound:soundId];
}

-(void) stopAllSounds
{
   for(NSNumber* soundIdNum in  _sounds.allValues)
   {
        [_soundHandler stopSound:soundIdNum.intValue];
   } 
}


- (void) dealloc
{
}

@end
