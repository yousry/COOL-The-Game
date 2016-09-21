//
//  YAScene.h
//
//  Created by Yousry Abdallah.
//  Copyright 2013 yousry.de. All rights reserved.

#import <Foundation/Foundation.h>
@class YARenderLoop, YAGameContext, YAImpGroup, YASoundCollector, YAOpenAL;

@interface YAScene: NSObject {
	YARenderLoop* renderLoop;
    YASoundCollector* soundCollector;
    YAOpenAL* al;

	YAGameContext* gameContext;

    YAImpGroup *buttonStart, *buttonDifficulty, *buttonNumberOfPlayer; 
    int sensorStart, sensorDifficulty, sensorNumPlayer;

}

- (id) initIn: (YARenderLoop*) loop;

- (void) setup;

@end