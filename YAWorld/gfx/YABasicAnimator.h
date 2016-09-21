//
//  YABasicAnimator.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 27.10.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YAVector3f;

enum progressType
{
    cyclic = 0,
    harmonic = 1,
    zigzag = 2,
    damp = 3,
    accelerate = 4,
    PROGRESS_ACCELERATE_DECELERATE = 5,
    PROGRESS_SLOW_ACCELERATE_DECELERATE = 6
};

enum axe 
{
    X_AXE = 0,
    Y_AXE = 1,
    Z_AXE = 2
};


@interface YABasicAnimator : NSObject {

    enum progressType progress;
    enum axe influence;
    
    float starttime;
    float interval;
    float delay;
    
    NSMutableArray* listeners;
    
    __strong NSNumber* event;
    int message;
    
    bool deleteme;
    bool once;
    bool onceReset;
    
}


// event handling
@property (assign, readwrite) bool deleteme;
@property (assign, readwrite) bool once;
@property (assign, readwrite) bool onceReset; // reset position after once loop
@property (assign, readwrite) bool asyncProcessing;

@property (strong, readwrite) NSNumber* event;
@property (assign) int message;

@property (assign, readwrite) enum axe influence;
@property (assign, readwrite) enum progressType progress;
@property (assign, readwrite) float interval;
@property (assign, readwrite) float delay;
@property (assign, readwrite) float starttime;

- (void) addListener: (YAVector3f*) listener factor: (float) factor;
- (void) addListenerWithInitSituation: (YAVector3f*) listener factor: (float) factor situation: (YAVector3f*) situation;

- (void) update: (float) now;
- (id)initAt: (float) now; 

@end
