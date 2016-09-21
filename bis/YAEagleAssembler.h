//
//  YAEagleAssembler.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 18.09.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YAImpGroup, YARenderLoop;


@interface YAEagleAssembler : NSObject

+(void) buildEagle: (YARenderLoop*)world Group: (YAImpGroup*) group;

@end
