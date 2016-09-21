//
//  YAVector4f.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 18.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YAVector4f : NSObject {
@private
    float x;
    float y;
    float z;
    float w;
}

@property(readwrite,assign)float x;
@property(readwrite,assign)float y;
@property(readwrite,assign)float z;
@property(readwrite,assign)float w;


- (id) initVals: (float)xVal : (float)yVal : (float)zVal : (float)wVal; 
- (id) initCopy: (YAVector4f*) orig;
- (YAVector4f*) normalize;
- (void) setVector: (const YAVector4f*) other;

@end
