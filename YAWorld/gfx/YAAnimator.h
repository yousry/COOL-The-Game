//
//  Animator.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 17.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

// #import <Foundation/Foundation.h>

@class YAShader, YAModel, YAMatrix4f, YATransformator;

@interface YAAnimator : NSObject {
@private 
    NSString* _name;
    YAShader* _shader;
    YAModel* _model;
    
    float lastComputation;
    float maxDuration;
    
    float xOffset;
    float yOffset;
    
    float _stageTime;
    
    YATransformator* transformator;
}


@property(readonly) YATransformator* transformator;   

- (id) initSetup: (NSString*) name shader: (YAShader*) shader model: (YAModel*) model;   
- (void) stage: (float)stageTime; 
- (void) pose;

@end
