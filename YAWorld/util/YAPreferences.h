//
//  YAPreferences.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 10.04.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YAPreferences : NSObject

@property NSString* resourceDir;
@property NSString* configDir;
@property bool isMultisampling;
@property unsigned int multispamplingPixel;
@property bool vSync;
@property unsigned int shadowBufferRes;
@property float gamma;
@property unsigned int sfx;
@property float fov;

@end