//
//  NSData+RangeAdditions.m
//  YAWorld
//
//  Created by Yousry Abdallah on 23.05.12.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (RangeAdditions)

-(NSRange)rangeOfData:(NSData *)aData
              options:(NSUInteger)mask
                range:(NSRange)aRange;

@end