//
//  YAKinematic.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 26.12.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YAQuaternion;

@interface YAKinematic : NSObject {
@private
    NSMutableDictionary* originalJoints;
    NSArray* forwardJoints; 
}

- (void) reset;

- (id)initWithJoints: (NSMutableDictionary*) joints;
- (void) createKinematic;
- (NSMutableDictionary*) getJoint: (NSString*) name;

- (void) setJointOrientation: (NSString*) jointName quaternion: (YAQuaternion*) quaternion;

@end
