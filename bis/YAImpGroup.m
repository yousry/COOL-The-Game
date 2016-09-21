//
//  YAImpGroup.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 20.06.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//


#import "YAQuaternion.h"
#import "YAVector3f.h"

#import "YAImpGroup.h"

@implementation YAImpGroup


static int nextId = 100000;

@synthesize translation = _translation;
@synthesize rotation = _rotation;
@synthesize size = _size;
@synthesize state = _state;
@synthesize states = _states;
@synthesize visible = _visible;

@synthesize observers = _observers;
@synthesize boxOffset,boxHalfExtents;
@synthesize friction,mass,restitution, gravity;
@synthesize collisionName;

- (id) init
{
    self = [super init];
    
    if(self) {
        _identifier = nextId++;
        
        self.states = [[NSMutableArray alloc] init];
        _translation = [[YAVector3f alloc] init];
        _rotation = [[YAVector3f alloc] init];
        _size = [[YAVector3f alloc] initVals:1 :1 :1 ];
        _visible = true;
        
        _useQuaternionRotation = false;
        _rotationQuaternion =[[YAQuaternion alloc] init];
        
        _observers = [[NSMutableArray alloc] init];
        
        transferredKeys = [[NSArray alloc] initWithObjects:
                           @"visible",
                           @"translation",
                           @"rotation",
                           @"size",
                           @"state",
                           @"rotationQuaternion",
                           @"useQuaternionRotation",
                           nil];
        
        
        // for physics
        mass = [NSNumber numberWithFloat:0];
        friction = [NSNumber numberWithFloat:0.5f];
        restitution = [NSNumber numberWithFloat:0.0f];
    }
    return self;
}


- (void)dealloc
{
    for(id impersonator in _observers)
        for(NSString* kp in transferredKeys)
            [self removeObserver:impersonator forKeyPath:kp];
}

- (void) addImp: (NSObject*) impersonator;
{
    for(NSString* kp in transferredKeys)
        [self addObserver:impersonator forKeyPath:kp options:NSKeyValueObservingOptionNew context:NULL];
    
    [_observers addObject:impersonator];
    
}

- (void) addModifier: (NSString*) forState Impersonator: (int) impId  Modifier: (NSString*) modifier Value: (id) value
{
    __block NSString* fs = forState.copy;
    __block NSNumber* ii = [NSNumber numberWithInt:impId];
    __block NSString* mo = modifier.copy;
    __block id va = [value copy];
    __block NSArray* newModifier = [[NSArray alloc] initWithObjects:fs, ii, mo, va, nil ];
    _states = [_states arrayByAddingObject:newModifier];
}

- (NSMutableArray*) allImps
{
    return _observers;
}


@end
