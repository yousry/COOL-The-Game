//
//  YASceneDevelop.h
//
//  Created by Yousry Abdallah.
//  Copyright 2013 yousry.de. All rights reserved.

#import <Foundation/Foundation.h>
@class YARenderLoop, YAOpenAL;

@interface YASceneDevelop: NSObject {
	YARenderLoop* renderLoop;
	YAOpenAL* al;
}

- (id) initIn: (YARenderLoop*) loop;
- (void) setup;

@end