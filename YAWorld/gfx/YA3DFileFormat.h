//
//  YA3DFileFormat.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 01.10.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

@class NSString, NSData, NSMutableData;

@interface YA3DFileFormat : NSObject {
@private
    NSString* _filename;
    NSData* modelData;
    NSString* textureName;
    NSString* normalName;
    NSString* modelFormat;
    
    NSData* vboData;
    NSData* iboData;
    
    int vboElemLength;
    
}

@property(readonly) NSData* vboData;
@property(readonly) NSData* iboData;
@property(readonly) NSString* modelFormat;
@property(readonly) NSString* textureName;
@property(readonly) NSString* normalName;


- (id) initWithResource: (NSString*) filename;

- (bool)load;    
- (bool)setup; 

@end
