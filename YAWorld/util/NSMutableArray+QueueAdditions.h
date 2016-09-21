//
//  NSMutableArray+QueueAdditions.h
//  YAWorld
//
//  Created by Yousry Abdallah on 23.05.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (QueueAdditions)

- (id) dequeue;
- (void) enqueue:(id)obj;
- (bool) isEmpty;
- (void) setUp;

@end
