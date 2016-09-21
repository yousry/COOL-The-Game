//
//  YAVertex.m
//  YAWorld
//
//  Created by Yousry Abdallah on 11.02.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YAVector3f.h"
#import "YAVertex.h"

@implementation YAVertex 
@synthesize coordinate,normal;

-(id) init {
    self = [super init];
    if(self) {
        coordinate = [[YAVector3f alloc] initVals:0.0f :0.0f :0.0f];
        normal = [[YAVector3f alloc] initVals:0.0f :0.0f :0.0f];
    }
    return self;
}

-(void) copyVertex: (YAVertex*) other 
{
    coordinate = [[YAVector3f alloc] initCopy:[other coordinate]];
    normal = [[YAVector3f alloc] initCopy:[other normal]];
}

-(void) copyVertexRefNormal: (YAVertex*) other
{
    coordinate = [[YAVector3f alloc] initCopy:[other coordinate]];
    normal = [other normal];
}



- (NSString *)description
{
    return [NSString stringWithFormat:@"Coordinate: %@ Normal %@", coordinate, normal];
}

@end
