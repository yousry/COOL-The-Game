//
//  YAModel.h
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 17.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UBO_SIZE 10

@class YATexture, YA3DFileFormat, YAShader;
@class YAVector3f, YAMatrix4f;

@interface YAModel : NSObject {
@protected    
    GLuint vaoId, vboId, iboId; 

    GLuint uboId;
    GLint uboSize;
    GLint uboName;
    GLvoid *uboBuffer;

    GLuint ubuElsIndices[UBO_SIZE];           
    GLint  ubuElsSize[UBO_SIZE];   
    GLint ubuElsOffset[UBO_SIZE];   
    GLint ubuElsType[UBO_SIZE];   

    YATexture *_texture, *_normal;
    
    NSString* _modelName;
    
    NSData *vbos, *ibos;

    GLsizei triangleCount;
    
    GLuint attribVertexLocation, 
           attribColorLocation, 
           attribTextureLocation, 
           attribNormalLocation, 
           attribTangentLocation;
    
    GLuint textureMapID, normalMapID;

    YAShader* modelShader;
}


@property (strong, readwrite) NSString* shaderId;

- (id)initVCNIWithShader: (NSData*) vertexBuffer indexBuffer: (NSData*) indexBuffer shader: (YAShader*) shader;
- (id)initVTNIWithShader: (YATexture*) texture vertexBuffer:(NSData*) vertexBuffer indexBuffer: (NSData*) indexBuffer shader: (YAShader*) shader;
- (id)initVTNBIWithShader: (YATexture*) texture normal: (YATexture*) normal vertexBuffer:(NSData*) vertexBuffer indexBuffer: (NSData*) indexBuffer shader: (YAShader*) shader;

- (void)destroy;
- (void) draw: (YAShader *) shader SuccessiveDraw: (bool) successive;

- (void) writeClientEye: (YAVector3f*) clientEye;
- (void) writeClientModel: (YAMatrix4f*) clientModel;
- (void) writeClientMVP: (YAMatrix4f*) clientMVP;

- (void) writeClientMaterialKa: (YAVector3f*) ka;
- (void) writeClientMaterialKd: (YAVector3f*) kd;
- (void) writeClientMaterialKs: (YAVector3f*) ks;
- (void) writeClientMaterialShininess: (float) shininess;
- (void) writeClientMaterialReflection: (float) reflection;
- (void) writeClientMaterialRefraction: (float) refraction;
- (void) writeClientMaterialEta: (float) eta;

@end
