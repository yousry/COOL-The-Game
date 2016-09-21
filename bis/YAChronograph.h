//
//  YAChronograph.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 04.03.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YAChronograph : NSObject {
@private
    double POI;
    NSTimer* timer;
    NSRunLoop* currentLoop;
}

- (void) start;
- (double) getTime;
- (void) wait: (float) seconds;

// TODO: add signal if listening is neccessary

@end
