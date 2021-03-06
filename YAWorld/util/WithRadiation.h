//
//  WithRadiation.h
//  YAWorld
//
//  Created by Yousry Abdallah on 29.08.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YAVector3f;

@protocol WithRadiation <NSObject>

@required
@property (strong, readonly) YAVector3f* intensity;

@end
