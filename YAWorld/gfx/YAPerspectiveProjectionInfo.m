//
//  YAPerspectiveProjectionInfo.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 18.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import "YAPerspectiveProjectionInfo.h"

@implementation YAPerspectiveProjectionInfo

@synthesize fieldOfView;
@synthesize width;
@synthesize height;
@synthesize zNear;
@synthesize zFar;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSString *)description 
{
    NSString* result = [NSString stringWithFormat: @"Projection Info [FOW: %f, W: %f, H: %f  N: %f F: %f]", fieldOfView, width, height, zNear, zFar];
    return result;
}


@end
