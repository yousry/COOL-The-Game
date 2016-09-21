//
//  NSMutableArray+QueueAdditions.m
//  YAWorld
//
//  Created by Yousry Abdallah on 23.05.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "NSMutableArray+QueueAdditions.h"

@implementation NSMutableArray (QueueAdditions)

static NSLock* messageLock;

- (void) setUp 
{
    messageLock = [NSLock new];
}

- (id) dequeue {
    
    if ([self count] == 0)
        return nil;
    
    id headObject = [self objectAtIndex:0];
    if (headObject != nil) {
        [messageLock lock];
        [self removeObjectAtIndex:0];
        [messageLock unlock];
    }
        
    
    return headObject;
}

- (void) enqueue:(id)anObject {
    [messageLock lock];
    [self addObject:anObject];
    [messageLock unlock];

}

- (bool) isEmpty
{
    return ([self count] == 0);
}


@end
