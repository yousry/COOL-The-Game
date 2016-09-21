//
//  YAYAShopAssembler.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 27.09.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YAImpGroup, YARenderLoop, YASceneUtils;

@interface YAShopAssembler : NSObject

+(void) buildShop: (YARenderLoop*)world SceneUtils:(YASceneUtils*) utils Group: (YAImpGroup*) group;


@end
