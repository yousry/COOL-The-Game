//
//  YAPreferences.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 10.04.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "YAPreferences.h"

@implementation YAPreferences

#import <unistd.h>
#import <pwd.h>


- (id) init
{
	self = [super init];

	if(self) {

		if(!self.loadConfig) {
			[self generateDefaultConfig];
			if(!self.saveConfig)
				NSLog(@"WARNING: Can't save Configuration file!!");
		}

	}

	return self;
}

-(void) generateDefaultConfig
{


	char buf[1024];  
	int pathLength = readlink("/proc/self/exe", buf, 1024 - 1);  
	NSString* applicationPath = [[NSString alloc] initWithBytes:buf length:pathLength encoding:NSASCIIStringEncoding];
	NSString *sub = [applicationPath lastPathComponent];
	applicationPath = [applicationPath substringToIndex: applicationPath.length - sub.length];		

	int uid = getuid();
	struct passwd *upwd = getpwuid(uid); 
	NSString* configPath = [NSString stringWithFormat:@"%s/.config/COOL",upwd->pw_dir];

	_resourceDir = [NSString stringWithFormat:@"%@res", applicationPath];
	_configDir = configPath;
	_isMultisampling = false;
	_multispamplingPixel = 2;
	_vSync = true;
	_shadowBufferRes = 512;
	_gamma = 0.0;
	_sfx = 100;
	_fov = 24.879f;

}

-(bool) saveConfig
{
	NSFileManager *fileManager= [NSFileManager defaultManager]; 
	BOOL isDir;
	if(![fileManager fileExistsAtPath:_configDir isDirectory:&isDir]) {
		if(![fileManager createDirectoryAtPath:_configDir withIntermediateDirectories:YES attributes:nil error:NULL]) 
			return false;
	}

	NSDictionary* dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
		_configDir, 									@"CONFIGDIR",
		[NSNumber numberWithInt:_isMultisampling],		@"MULTISAMPLING",
		[NSNumber numberWithInt:_multispamplingPixel],	@"MULTISAMPLINGPIXEL",
		[NSNumber numberWithBool:_vSync], 				@"VSYNC",
		[NSNumber numberWithInt:_shadowBufferRes],		@"SHADOWBUFFERRES",
		[NSNumber numberWithFloat:_gamma],				@"GAMMA",
		[NSNumber numberWithInt:_sfx],					@"SFX",
		[NSNumber numberWithFloat:_fov],				@"FIELDOFVIEW",
		nil
	];

	NSString* filePath = [NSString stringWithFormat:@"%@/COOL.cfg", _configDir]; 
	return [dictionary writeToFile:filePath atomically:NO];
}


-(bool) loadConfig
{
	int uid = getuid();
	struct passwd *upwd = getpwuid(uid); 
	NSString* configPath = [NSString stringWithFormat:@"%s/.config/COOL",upwd->pw_dir];

	NSString* filePath = [NSString stringWithFormat:@"%@/COOL.cfg", configPath]; 

	NSDictionary* dictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];

	if(dictionary == nil)
		return false;
	

	char buf[1024];  
	int pathLength = readlink("/proc/self/exe", buf, 1024 - 1);  
	NSString* applicationPath = [[NSString alloc] initWithBytes:buf length:pathLength encoding:NSASCIIStringEncoding];
	NSString *sub = [applicationPath lastPathComponent];
	applicationPath = [applicationPath substringToIndex: applicationPath.length - sub.length];		
	_resourceDir = [NSString stringWithFormat:@"%@res", applicationPath];


	_configDir = [dictionary objectForKey:@"CONFIGDIR"];
	_isMultisampling = (( NSNumber*)[dictionary objectForKey:@"MULTISAMPLING"]).boolValue;
	_multispamplingPixel = ((NSNumber*)[dictionary objectForKey:@"MULTISAMPLINGPIXEL"]).intValue;
	_vSync = ((NSNumber*)[dictionary objectForKey:@"VSYNC"]).boolValue;
	_shadowBufferRes = ((NSNumber*)[dictionary objectForKey:@"SHADOWBUFFERRES"]).intValue;
	_gamma = ((NSNumber*)[dictionary objectForKey:@"GAMMA"]).floatValue;
	_sfx = ((NSNumber*)[dictionary objectForKey:@"SFX"]).intValue;
	_fov = ((NSNumber*)[dictionary objectForKey:@"FIELDOFVIEW"]).floatValue;

	return true;

}


- (NSString*) description
{

	NSString* result = [NSString stringWithFormat:@"\nConfiguration:\nResource Directory: %@", _resourceDir];
	result = [NSString stringWithFormat:@"%@\nConfiguration Directory: %@", result, _configDir];
	result = [NSString stringWithFormat:@"%@\nAntialias Multisampling: %d", result, _isMultisampling];
	result = [NSString stringWithFormat:@"%@\nMultisampling Pixel: %d", result, _multispamplingPixel];
	result = [NSString stringWithFormat:@"%@\nVertical Sync (vSync): %d", result, _vSync];
	result = [NSString stringWithFormat:@"%@\nShadowbuffer Size (128/256/512/1024): %d", result, _shadowBufferRes];
	result = [NSString stringWithFormat:@"%@\nGamma Correction: %f", result, _gamma];
	result = [NSString stringWithFormat:@"%@\nSound Volume: %d", result, _sfx];
	result = [NSString stringWithFormat:@"%@\nField Of View: %f", result, _fov];

	return result;
}

@end