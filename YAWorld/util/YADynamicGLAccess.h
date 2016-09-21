//
//  YADynamicGLAccess.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 09.11.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YAShader;

@interface YADynamicGLAccess : NSObject

+ (NSArray*) shaderInputs: (YAShader*) shader active: (GLenum) activeE maxLength: (GLenum) maxLengthE;

+ (NSArray*) getshaderAttribs: (YAShader*) shader;
+ (NSArray*) getshaderUniforms: (YAShader*) shader;



@end
