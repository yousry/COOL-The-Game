//
//  YALog.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 14.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YALog : NSObject {
}

+ (bool) isDebug;
+ (void) setDebug: (bool)debug; 
+ (void) debug: (const NSString*) tag message: (NSString*) message;
+ (void) log: (const NSString*) tag message: (NSString*) message;

+ (bool) isGLStateOk: (const NSString*) tag message: (NSString*) message;

+ decode: (NSString*) code;


@end
