//
//  YAKinematic.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 26.12.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import "YAVector3f.h"
#import "YAQuaternion.h"
#import "YALog.h"
#import "YAKinematic.h"

@interface YAKinematic () 

- (void) addChildRecursive: (NSArray*) sortedJoints child: (int) child parent: (int) parent;

@end

@implementation YAKinematic

static const NSString* TAG = @"YAKinematic";

- (id)initWithJoints: (NSMutableDictionary*) joints;
{
    [YALog debug:TAG message:@"initWithJoints"];
    self = [super init];
    if (self) {
        originalJoints = joints;
    }
    
    return self;
}


/***
 Setup default Forward Kinematic.
 ***/
- (void) createKinematic
{
    [YALog debug:TAG message:@"createKinematic"];

    forwardJoints = [[originalJoints allValues] sortedArrayUsingComparator:^(id a, id b){
            return [[a objectForKey:@"MYID"] compare: [b objectForKey:@"MYID"] ];
    }];
    
    for (int i = 0; i < [forwardJoints count]; i++) {
        NSMutableArray* childs = [[NSMutableArray alloc] init ];
        NSMutableDictionary* forwardJoint = [forwardJoints objectAtIndex:i];
        [forwardJoint setObject:childs forKey:@"CHILDS"];

        // create a copy of the original values
        [forwardJoint setObject:[forwardJoint objectForKey:@"JOINT"] forKey:@"JOINT_DEFAULT"];
        [forwardJoint setObject:[forwardJoint objectForKey:@"QUATERNION"] forKey:@"QUATERNION_DEFAULT"];
    }    
    
    for (int i = 0; i < [forwardJoints count]; i++) {
        NSMutableDictionary* joint = [forwardJoints objectAtIndex:i];
        id parentId = [joint objectForKey:@"PARENT"];
        if (![parentId isMemberOfClass:[NSNull class]]) {
            int parentIdInt = [parentId intValue];
            [self addChildRecursive:forwardJoints child:i parent:parentIdInt];
        }
    }
}

- (void) addChildRecursive: (NSArray*) sortedJoints child: (int) child parent: (int) parent
{
    NSMutableDictionary *parentJoint = [sortedJoints objectAtIndex:parent];
    NSMutableSet* childs = [parentJoint objectForKey:@"CHILDS"];
    NSNumber* childN = [[NSNumber alloc] initWithInt:child];
    [childs addObject:childN];
   
    id parentParentId = [parentJoint objectForKey:@"PARENT"];
    
    if (![parentParentId isMemberOfClass:[NSNull class]]) {
        int parentParentIdInt = [parentParentId intValue];
        [self addChildRecursive:sortedJoints child:child parent:parentParentIdInt];
    }
}

- (NSMutableDictionary*) getJoint: (NSString*) name
{
    return [originalJoints objectForKey:name];
}


- (void) reset
{
    for (int i = 0; i < [forwardJoints count]; i++) {
        NSMutableDictionary* joint = [forwardJoints objectAtIndex:i];
        [joint setObject:[joint objectForKey:@"QUATERNION_DEFAULT"] forKey:@"QUATERNION"];
        [joint setObject:[joint objectForKey:@"JOINT_DEFAULT"] forKey:@"JOINT"];
    }
    
}

- (void) setJointOrientation: (NSString*) jointName quaternion: (YAQuaternion*) quaternion
{
    NSMutableDictionary* joint = [originalJoints objectForKey:jointName];
    [quaternion normalize];

    [joint setObject:quaternion forKey:@"QUATERNION"];
   

    NSMutableSet* childs = [joint objectForKey:@"CHILDS"];
    NSEnumerator *enumerator = [childs objectEnumerator];
    NSNumber* childId = nil;
    NSMutableDictionary* child;
    YAVector3f *childPosition = nil;
    YAVector3f *parentPosition = [joint objectForKey:@"JOINT"];

    while((childId = [enumerator nextObject])){
        child = [forwardJoints objectAtIndex: [childId intValue]];
        childPosition = [(YAVector3f*)[YAVector3f alloc] initCopy: [child objectForKey:@"JOINT"]];

        [childPosition subVector:parentPosition];
        childPosition = [quaternion rotate:childPosition];
        [childPosition addVector:parentPosition];

        YAQuaternion* childQuat = [child objectForKey:@"QUATERNION"];
        childQuat = [quaternion mulQuaternion:childQuat];
        [childQuat normalize];

        
        [child setObject:childQuat forKey:@"QUATERNION"];
        [child setObject:childPosition forKey:@"JOINT"];
    }
    

    
    
    
    
    
}

@end
