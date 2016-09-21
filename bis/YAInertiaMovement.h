//
//  YAInertiaMovement.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 13.02.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YAVector3f, YAAvatar, YATransformator, YAVector2f;

typedef enum {
    STORED_ENERGY,
    STORED_VECTOR
} inertia_memory_t;

@interface YAInertiaMovement : NSObject {
@private
    YAVector2f* _headRotateDirection[2];
    bool _actRotId, _lstRotId;
    
    float _speedFactor;
    YAVector3f* _position;
    YAVector3f* _lastTarget;
}

@property (assign, readwrite) inertia_memory_t memory;
@property (weak, readwrite) YAAvatar* avatar;
@property (weak, readwrite) YATransformator* transformator;

- (void) lookAt: (YAVector3f*) target;

@end
