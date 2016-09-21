//
//  YAOpenAL.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 04.10.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

// #import <CoreServices/CoreServices.h>
// #import <AudioToolbox/AudioToolbox.h>
#import <AL/al.h>
#import <AL/alc.h>
#import <AL/alut.h>

#import <vorbis/vorbisfile.h>

#import "YAPreferences.h"
#import "YARenderLoop.h"
#import "YAVector3f.h"
#import "YALog.h"
#import "YAOpenAL.h"

#define BYTES_READ_BUFFER_SIZE 32768
#define AUDIO_DIR @"audio"

@implementation YAOpenAL
static const NSString* TAG = @"YAOpenAL";

- (id) initInWorld: (YARenderLoop*) world;
{
    self = [super init];
    if(self) {
        _world = world;
        _world.openAL = self;
 
        const ALCchar* deviceName = alcGetString(NULL, ALC_DEFAULT_DEVICE_SPECIFIER);
        NSLog(@"Try to initialize device: [%s]", deviceName);

        _device = alcOpenDevice(deviceName);

        if(_device == NULL) {
            NSLog(@"Could not open OpenAL Device.");
            return nil;
        }

        context = alcCreateContext(_device, 0);
        alcMakeContextCurrent(context);
        alcProcessContext(context);
        [YAOpenAL isALStateOk:TAG message:@"context status"];

        alListener3f (AL_POSITION, 0.0, 0.0, 0.0);
        [YAOpenAL isALStateOk:TAG message:@"init / AL_POSITION FAILED"];


        if(!alutInitWithoutContext(NULL,NULL)) {
            // NSLog(@"Could not setup alut");
            [YAOpenAL isALutStateOk:TAG message:@"alutCreateBufferFromFile status"];
        }


        // cleanup done by dealloc
        // atexit(func); 

        _buffers = [[NSMutableArray alloc] init];
        _sources = [[NSMutableArray alloc] init];
        _baseVolume = 1.0;
    }

    return self;
}

- (int) loadOgg: (NSString*) oggFileName
{     
    [YALog debug:TAG message:@"loadOgg"];
    [YAOpenAL isALStateOk:TAG message:@"loadOgg / init FAILED"];
    
    YAPreferences* prefs = [[YAPreferences alloc] init];
    NSString* audioURL = [NSString stringWithFormat:@"%@/%@/%@", prefs.resourceDir, AUDIO_DIR, oggFileName];
    [YALog debug:TAG message:[NSString stringWithFormat:@"File url %@", audioURL ]];  

    FILE* f = fopen([audioURL cStringUsingEncoding:NSASCIIStringEncoding], "rb");

    if(f == NULL)
        NSLog(@"Could not open ogg file: %s", [audioURL cStringUsingEncoding:NSASCIIStringEncoding]);
    
    OggVorbis_File oggFile;
    int err = ov_open(f, &oggFile, NULL, 0);

    if(err < 0) 
        return -1;

    vorbis_info *pInfo = ov_info(&oggFile, -1);

    ALenum format = (pInfo->channels == 1) ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16;            
    ALsizei freq = pInfo->rate;
    
    char bytesReadArray[BYTES_READ_BUFFER_SIZE]; 
    long bytesRead = 0;
    int bitStream;

    NSMutableData* buffer = [[NSMutableData alloc] init];

    do {
        bytesRead = ov_read(&oggFile, bytesReadArray, BYTES_READ_BUFFER_SIZE, 0, 2, 1, &bitStream);
        
        if(bytesRead > 0)
            [buffer appendBytes:bytesReadArray length: bytesRead];

    } while (bytesRead > 0);


    ov_clear(&oggFile);

    ALuint bufferId;
    alGenBuffers(1, &bufferId);
    [YAOpenAL isALStateOk:TAG message:@"alGenBuffers / addSound FAILED"];
    
    alBufferData(bufferId,
                 format,
                 buffer.bytes,
                 (ALsizei)buffer.length,
                 (ALsizei)freq);

    if([YAOpenAL isALStateOk:TAG message:@"alBufferData / addSound FAILED"])
            [_buffers addObject:[NSNumber numberWithUnsignedInt:bufferId]];

    return bufferId;
}


- (int) loadSound: (NSString*) soundFileName
{
    [YALog debug:TAG message:@"loadSound"];
    [YAOpenAL isALStateOk:TAG message:@"loadSound / init FAILED"];
    
    YAPreferences* prefs = [[YAPreferences alloc] init];
    NSString* audioURL = [NSString stringWithFormat:@"%@/%@/%@", prefs.resourceDir, AUDIO_DIR, soundFileName];
    [YALog debug:TAG message:[NSString stringWithFormat:@"File url %@", audioURL ]];    


    ALuint handler = alutCreateBufferFromFile([audioURL cStringUsingEncoding:NSASCIIStringEncoding]);
 

    [YAOpenAL isALutStateOk:TAG message:@"alutCreateBufferFromFile status"];
    [YAOpenAL isALStateOk:TAG message:@"alutCreateBufferFromFile status"];


    if(handler == AL_NONE) 
        NSLog(@"Could not load file.");
    else  
        [_buffers addObject:[NSNumber numberWithUnsignedInt:handler]];  


    [YALog debug:TAG message:@"File loaded."];
    return handler;
}

- (int)setupSound: (int) bufferIndex atPosition: (YAVector3f*) position loop: (bool) looping
{
    [YALog debug:TAG message:@"startSound"];
    [YAOpenAL isALStateOk:TAG message:@"startSound / init FAILED"];

    ALuint source = -1;
    alGenSources(1, &source);
    [YAOpenAL isALStateOk:TAG message:@"alGenSources / startSound FAILED"];

    if(looping)
        alSourcei(source, AL_LOOPING, AL_TRUE);
    else
        alSourcei(source, AL_LOOPING, AL_FALSE);
    
    [YAOpenAL isALStateOk:TAG message:@"alGenSources / AL_LOOPING FAILED"];
    alSourcef(source, AL_GAIN, AL_MAX_GAIN * _baseVolume);
    [YAOpenAL isALStateOk:TAG message:@"alGenSources / AL_GAIN FAILED"];
    alSource3f(source, AL_POSITION, position.x, position.y, position.z);
    [YAOpenAL isALStateOk:TAG message:@"alGenSources / AL_GAIN FAILED"];
    
    // TODO: set as parameter
    alSourcef(source, AL_REFERENCE_DISTANCE, 2.0);

    
    alSourcei(source, AL_BUFFER, bufferIndex);
    [YAOpenAL isALStateOk:TAG message:@"alGenSources / AL_GAIN FAILED"];
    
    [_sources addObject:[NSNumber numberWithUnsignedInt:source]];
    return source;
}

- (void)playSound: (int) sourceIndex
{
    alSourcePlay(sourceIndex);
    [YAOpenAL isALStateOk:TAG message:@"alGenSources / AL_GAIN FAILED"];
    
}

- (bool)isPlaying: (int) sourceIndex
{
    ALint state;
    alGetSourcei(sourceIndex,AL_SOURCE_STATE,&state);
    
    if(state == AL_PLAYING)
        return true;
    else
        return false;
}



- (void) stopSound: (int) sourceIndex
{
    alSourceStop(sourceIndex);
}

- (void) updateSound: (int) sourceIndex toPosition: (YAVector3f*) position
{
    alSource3f(sourceIndex, AL_POSITION, position.x, position.y, position.z);
    [YAOpenAL isALStateOk:TAG message:@"alGenSources / AL_GAIN FAILED"];
}


-(void) cleanup
{
    [YALog debug:TAG message:@"cleanup"];
    for(NSNumber* n in _sources) {
        ALuint source = n.unsignedIntValue;
        alSourceStop(source);
        alDeleteSources(1, &source);
    }
    
    for(NSNumber* n in _buffers) {
        ALuint buffer = n.unsignedIntValue;
        alDeleteBuffers(1, &buffer);
    }

    alcDestroyContext(context);
    alcCloseDevice(_device);
}

- (void) dealloc
{
    [self cleanup];
}

+ (bool) isALutStateOk: (const NSString*) tag message: (NSString*) message
{
    ALenum alutError = alutGetError();
    const char* errorDescription = alutGetErrorString(alutError);

    if(alutError != ALUT_ERROR_NO_ERROR) {
        NSLog(@"[%@] %@  [OpenALut] %s", tag, message, errorDescription);
        return false;
    }
    else {
        return true;
    }

}



+ (bool) isALStateOk: (const NSString*) tag message: (NSString*) message
{
    ALenum alErr = alGetError();
	if (alErr == AL_NO_ERROR) {
        return true;
    }
    NSString* errorType = nil;
    
	switch (alErr) {
		case AL_INVALID_NAME:
            errorType = @"AL_INVALID_NAME";
            break;
		case AL_INVALID_VALUE:
            errorType = @"AL_INVALID_VALUE";
            break;
		case AL_INVALID_ENUM:
            errorType = @"AL_INVALID_ENUM";
            break;
		case AL_INVALID_OPERATION:
            errorType = @"AL_INVALID_OPERATION";
            break;
		case AL_OUT_OF_MEMORY:
            errorType = @"AL_OUT_OF_MEMORY";
            break;
	}

    if(YALog.isDebug)
        NSLog(@"[%@] %@  [OpenAL] %@", tag, message, errorType);
    
    return false;
}

- (void) setVolume: (int) sourceIndex gain: (float) gain
{
    alSourcef(sourceIndex, AL_GAIN, gain * _baseVolume);
}


@end
