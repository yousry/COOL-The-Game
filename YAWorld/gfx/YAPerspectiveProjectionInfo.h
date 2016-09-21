//
//  YAPerspectiveProjectionInfo.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 18.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YAPerspectiveProjectionInfo : NSObject {
@private
    float fieldOfView;
    float width;
    float height;
    float zNear;
    float zFar;
}


@property(readwrite,assign)float fieldOfView;
@property(readwrite,assign)float width;
@property(readwrite,assign)float height;
@property(readwrite,assign)float zNear;
@property(readwrite,assign)float zFar;


@end
