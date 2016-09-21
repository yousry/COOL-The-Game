//
//  YAShapeshifter.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 15.12.11.
//  Copyright 2011 yousry.de. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface YAShapeshifter : NSObject {
@private 
    GLuint tboId;
    NSMutableData* shapeData;
    NSMutableData* tboData;
}

@property (strong, readwrite) NSMutableDictionary* shapers;
@property (strong, readonly) NSString* inherentModel;

- (id)initFromJson: (NSString*) filename;
- (NSString*) inherentModel;
- (bool) createTBO;
- (bool) destroyTBO;
- (void) bind: (GLenum) position;

- (void) updateShaper: (NSDictionary*) shaper;

@end
