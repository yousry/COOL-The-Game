//
//  YAMapEvents.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 31.12.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YAEvaluable.h"
@interface YAMapEvents : NSObject

- (ListenerEvent) plotSelectionEvent;
- (ListenerEvent) plotAuctionEvent;
- (ListenerEvent) comoditiesAuctionEvent;

@end
