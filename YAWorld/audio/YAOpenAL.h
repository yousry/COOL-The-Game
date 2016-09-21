//
//  YAOpenAL.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 04.10.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <AL/alc.h>
#import <Foundation/Foundation.h>
@class YAImpersonator, YARenderLoop, YAVector3f;


@interface YAOpenAL : NSObject
{
@private
    NSMutableArray* _buffers;
    NSMutableArray* _sources;

    YARenderLoop* _world;
    
    ALCcontext* context;
    
}

- (id) initInWorld: (YARenderLoop*) world;

- (int) loadSound: (NSString*) soundFileName;
- (int) loadOgg: (NSString*) oggFileName;

- (int)setupSound: (int) bufferIndex atPosition: (YAVector3f*) position loop: (bool) looping;
- (void)playSound: (int) sourceIndex;
- (bool)isPlaying: (int) sourceIndex;
- (void) stopSound: (int) sourceIndex;
- (void) updateSound: (int) sourceIndex toPosition: (YAVector3f*) position;
- (void) setVolume: (int) sourceIndex gain: (float) gain;

-(void) cleanup;

@property float baseVolume;
@property (assign, readwrite) ALCdevice* device;

@end
