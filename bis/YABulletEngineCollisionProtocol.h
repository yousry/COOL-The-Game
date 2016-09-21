//
//  YABulletEngineCollisionProtocol.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 18.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YAImpersonator;

@protocol YABulletEngineCollisionProtocol <NSObject>

@property (assign ,readwrite) YAImpersonator* collisionImp;

@end
