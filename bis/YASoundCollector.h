//
//  YASoundCollector.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 17.01.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YARenderLoop, YAOpenAL;
@class YAImpersonator;
@class YAVector3f;
@class YAGameStateMachine;

@interface YASoundCollector : NSObject {
    YARenderLoop* _world;
    NSDictionary* _soundSources;
    NSDictionary* _jingleSources;

    NSMutableDictionary* _sounds;
    YAVector3f* _origin;
    
    float baseSfx;
}

- (id) initInWorld: (YARenderLoop*) world;

@property (strong, readonly) YAOpenAL* soundHandler;
@property (weak, readwrite) YAGameStateMachine* gamestateMachine;

- (int) getSoundId: (NSString*) soundName;
- (void) playForImp: (YAImpersonator*) impersonator Sound: (int) soundId;

- (int) getJingleId: (NSString*) jingleTitle;
- (void) playJingle: (int) soundId;
- (void) stopJingle: (int) soundId;
-(void) stopAllSounds;

@end
