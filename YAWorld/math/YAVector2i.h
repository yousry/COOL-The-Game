//
//  Vector2i.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 18.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YAVector2i : NSObject {
@private
    int x;
    int y;
}

- (id)initVals: (int)xVal : (int) yVal;
- (id)initCopy: (YAVector2i*) orig;

@property(readwrite, assign)int x;
@property(readwrite, assign)int y;

- (double) distanceTo: (YAVector2i*) other;
- (void) setValues: (int) xVal : (int) yVal;

@end
