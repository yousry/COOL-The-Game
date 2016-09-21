//
//  YAModel.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 17.09.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES
#define GLCOREARB_PROTOTYPES
#import <GL/glcorearb.h>

#import "YAMatrix4f.h"
#import "YAVector3f.h"
#import "YADynamicGLAccess.h"
#import "YAShader.h"
#import "YATexture.h"
#import "YA3DFileFormat.h"
#import "YALog.h"
#import "YAModel.h"

@interface YAModel() 

@end

@implementation YAModel

static const NSString* TAG = @"YAModel";

- (id)initVCNIWithShader: (NSData*) vertexBuffer indexBuffer: (NSData*) indexBuffer shader: (YAShader*) shader
{
    [YALog debug:TAG message:@"initVCNIWithShader" ];
    self = [super init];
    if (self) {
        _texture = nil;
        vbos = vertexBuffer;
        ibos = indexBuffer;
        _shaderId = [shader name];
        modelShader = shader;
        [self setupVertexArray:false];
    }
    return self;
    
}


- (id)initVTNBIWithShader: (YATexture*) texture 
                   normal: (YATexture*) normal 
             vertexBuffer:(NSData*) vertexBuffer 
              indexBuffer: (NSData*) indexBuffer 
                   shader: (YAShader*) shader;
{
    [YALog debug:TAG message:@"initVTNBIWithShader" ];
    self = [super init];
    if (self) {
        _texture = texture;
        _normal = normal;
        vbos = vertexBuffer;
        ibos = indexBuffer;
        _shaderId = [shader name];
        modelShader = shader;
        [self setupVertexArray:true];
    }
    return self;   
}


- (id)initVTNIWithShader: (YATexture*) texture 
            vertexBuffer:(NSData*) vertexBuffer 
             indexBuffer: (NSData*) indexBuffer 
                  shader: (YAShader*) shader
{
    [YALog debug:TAG message:@"initVTNIWithShader" ];
    self = [super init];
    if (self) {
        _texture = texture;
        _normal = nil;
        vbos = vertexBuffer;
        ibos = indexBuffer;
        _shaderId = [shader name];
        modelShader = shader;
        [self setupVertexArray:false];
    }
    return self;   
}

- (void)destroy 
{
    if(uboBuffer != NULL)
        free(uboBuffer);

    [self destroyVBO];
}

- (void) dealloc
{
    [self destroy];
}

- (void) setupUBO
{
    [YALog debug:TAG message:@"Setup UBO" ];

    uboName = glGetUniformBlockIndex(modelShader.programId , "clientUniforms");

    if(uboName == GL_INVALID_INDEX) {
        // NSLog(@"UBO Name not found");
        return;
    }

    glGetActiveUniformBlockiv(modelShader.programId, uboName, GL_UNIFORM_BLOCK_DATA_SIZE, &uboSize);

    uboBuffer = NULL;

    if(uboSize <= 0)
        return;

    uboBuffer = malloc(uboSize);

    const char* names[] = {
        "clientEye", "clientModel", "clientMVP",
        "clientMaterial.Ka", "clientMaterial.Kd", "clientMaterial.Ks", 
        "clientMaterial.Shininess", 
        "clientMaterial.Reflection", "clientMaterial.Refraction", 
        "clientMaterial.Eta"
                          };

    glGetUniformIndices(modelShader.programId, UBO_SIZE, names, ubuElsIndices);
    glGetActiveUniformsiv(modelShader.programId, UBO_SIZE, ubuElsIndices, GL_UNIFORM_OFFSET, ubuElsOffset);
    glGetActiveUniformsiv(modelShader.programId, UBO_SIZE, ubuElsIndices, GL_UNIFORM_SIZE, ubuElsSize);
    glGetActiveUniformsiv(modelShader.programId, UBO_SIZE, ubuElsIndices, GL_UNIFORM_TYPE, ubuElsType);


    for(int i = 0; i < UBO_SIZE; i++)
        // NSLog(@"--> %s:[%d] offset: %d Type: %d Size: %d", 
            // names[i], ubuElsIndices[i], ubuElsOffset[i], ubuElsType[i], ubuElsSize[i]);


    glGenBuffers(1, &uboId);
    glBindBuffer(GL_UNIFORM_BUFFER, uboId);
    glBufferData(GL_UNIFORM_BUFFER, uboSize, uboBuffer, GL_DYNAMIC_DRAW);
    glBindBufferBase(GL_UNIFORM_BUFFER, uboName, uboId);

    // NSLog(@" ----- UBO:      %d", uboName);
    // NSLog(@" ----- UBO ID    %d", uboId);
    // NSLog(@" ----- UBO SIZE: %d", uboSize);


    [YALog isGLStateOk:TAG message:@"setupUBO"];

}

- (bool) setupVertexArray: (bool) useTangents
{
    [YALog debug:TAG message:@"createVBOWithShader" ];
    [YALog isGLStateOk:TAG message:@"createVBO / init"];
    
    glGenVertexArrays(1, &vaoId);
    glBindVertexArray(vaoId);
    [YALog isGLStateOk:TAG message:@"createVBO / could not create vao"];

    // [self setupUBO];
    
    glGenBuffers(1, &vboId);
    glBindBuffer(GL_ARRAY_BUFFER, vboId);
    [YALog isGLStateOk:TAG message:@"createVBO / could not create vbo"];
    
    const NSUInteger vboSize = vbos.length;
    const NSUInteger iboSize = ibos.length;
    
    [YALog debug:TAG message:[NSString stringWithFormat:@"VBO Size: %ld", vboSize]];
    [YALog debug:TAG message:[NSString stringWithFormat:@"IBO Size: %ld", iboSize]];
    
    glBufferData(GL_ARRAY_BUFFER, vboSize, [vbos bytes], GL_STATIC_DRAW);
    [YALog isGLStateOk:TAG message:@"VBO create vertices"];
    
    glGenBuffers(1, &iboId);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, iboId);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, iboSize, [ibos bytes], GL_STATIC_DRAW);
    
    triangleCount = (int) (iboSize / 4 / 3);
    [YALog debug:TAG message:[NSString stringWithFormat:@"Triangles: %d", triangleCount]];
    
    attribVertexLocation = glGetAttribLocation([modelShader programId], "clientPosition");
    attribColorLocation = glGetAttribLocation([modelShader programId], "clientColor");
    attribTextureLocation = glGetAttribLocation([modelShader programId], "clientTexture");
    attribNormalLocation = glGetAttribLocation([modelShader programId], "clientNormal");
    attribTangentLocation = glGetAttribLocation([modelShader programId], "clientTangent");
    
    if (_texture != nil) {
        int vertexSize = 8 * 4;

        if(useTangents)
            vertexSize += 3 * 4;
        
        if(attribVertexLocation != - 1) {
            glVertexAttribPointer(attribVertexLocation, 3, GL_FLOAT, GL_FALSE, vertexSize, 0);
            glEnableVertexAttribArray(attribVertexLocation);
            [YALog debug:TAG message:@"attribVertexLocation assigned" ];
        }   
        
        if(attribTextureLocation != - 1) {
            glVertexAttribPointer(attribTextureLocation, 2, GL_FLOAT, GL_FALSE, vertexSize, (const GLvoid*) 12);
            glEnableVertexAttribArray(attribTextureLocation);
            [YALog debug:TAG message:@"attribTextureLocation assigned" ];
        }   
        
        if(attribNormalLocation != - 1) {
            glVertexAttribPointer(attribNormalLocation, 3, GL_FLOAT, GL_FALSE, vertexSize, (const GLvoid*) 20);
            glEnableVertexAttribArray(attribNormalLocation);
            [YALog debug:TAG message:@"attrib_NormalLocation assigned" ];
        }   
        
        if(useTangents && attribTangentLocation != - 1) {
            glVertexAttribPointer(attribTangentLocation, 3, GL_FLOAT, GL_FALSE, vertexSize, (const GLvoid*) 32);
            glEnableVertexAttribArray(attribTangentLocation);
            [YALog debug:TAG message:@"attrib_TangentLocation assigned" ];
        }   

    } else {
        const int vertexSize = 9 * 4;
        
        if(attribVertexLocation != - 1) {
            glVertexAttribPointer(attribVertexLocation, 3, GL_FLOAT, GL_FALSE, vertexSize, 0);
            glEnableVertexAttribArray(attribVertexLocation);
            [YALog debug:TAG message:@"attribVertexLocation assigned" ];
        }   
        
        if(attribColorLocation != - 1) {    
            glVertexAttribPointer(attribColorLocation, 3, GL_FLOAT, GL_FALSE, vertexSize, (const GLvoid*)12);
            glEnableVertexAttribArray(attribColorLocation);
            [YALog debug:TAG message:@"attribColorLocation assigned" ];
        }   
        
        if(attribNormalLocation != - 1) {    
            glVertexAttribPointer(attribNormalLocation, 3, GL_FLOAT, GL_FALSE, vertexSize, (const GLvoid*)24);
            glEnableVertexAttribArray(attribNormalLocation);
            [YALog debug:TAG message:@"attribNormalLocation assigned" ];
        }   
        
    }
    
    glBindVertexArray(0);
    return [YALog isGLStateOk:TAG message:@"VBO not created"]; 
}

- (bool) destroyVBO
{
    [YALog isGLStateOk:TAG message:@"destroyVBO / init FAILED"];
    
    glBindVertexArray(vaoId);
    
    if(attribVertexLocation != -1)
        glDisableVertexAttribArray(attribVertexLocation);
    if(attribTextureLocation != -1)
        glDisableVertexAttribArray(attribTextureLocation);
    if(attribNormalLocation != -1)
        glDisableVertexAttribArray(attribNormalLocation);
    if(attribTangentLocation != -1)
        glDisableVertexAttribArray(attribTangentLocation);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glDeleteBuffers(1, &vboId);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glDeleteBuffers(1, &iboId);
    
    glBindBuffer(GL_UNIFORM_BUFFER, 0);
    glDeleteBuffers(1, &uboId);

    glBindVertexArray(0);
    glDeleteVertexArrays(1, &vaoId);
    
    return [YALog isGLStateOk:TAG message:@"VBO could not be destroyed."];
    
}

- (void) draw: (YAShader *) shader SuccessiveDraw: (bool) successive
{
    [YALog isGLStateOk:TAG message:@"DRAW INIT / FAILED"];
    
    if(!successive) {
        glBindVertexArray(vaoId);
        [YALog isGLStateOk:TAG message:@"createVBO / could not create vao"];
        
        [_texture bind: GL_TEXTURE0];
        GLuint loc = shader.locTextureMap;
        if(loc != -1) {
            glUniform1i(loc, 0);
        }
        
        [_normal bind: GL_TEXTURE1];
        loc = shader.locNormalMap;
        if(loc != -1) {
            glUniform1i(loc, 1);
        }
    }
    
//    glDisable(GL_CULL_FACE);
//    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    
    glDrawElements(GL_TRIANGLES, triangleCount * 3, GL_UNSIGNED_INT, 0);
    
//    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
//    glEnable(GL_CULL_FACE);
    
    [YALog isGLStateOk:TAG message:@"DRAW / FAILED"];
}


#pragma mark -

- (void) writeClientEye: (YAVector3f*) clientEye
{
    if(uboBuffer == NULL)
        return;

    GLfloat data[] = {clientEye.x,clientEye.y,clientEye.z};
    glBufferSubData(GL_UNIFORM_BUFFER, ubuElsOffset[0], sizeof(GLfloat) * 3, data);
}

- (void) writeClientModel: (YAMatrix4f*) clientModel
{   
    if(uboBuffer == NULL)
        return;

    glBufferSubData(GL_UNIFORM_BUFFER, ubuElsOffset[1], sizeof(GLfloat) * 16, &clientModel->m[0][0]);
}

- (void) writeClientMVP: (YAMatrix4f*) clientMVP
{
    if(uboBuffer == NULL)
        return;    
    glBufferSubData(GL_UNIFORM_BUFFER, ubuElsOffset[2], sizeof(GLfloat) * 16, &clientMVP->m[0][0]);
}

- (void) writeClientMaterialKa: (YAVector3f*) ka
{
    if(uboBuffer == NULL)
        return;

    GLfloat data[] = {ka.x,ka.y,ka.z};
    glBufferSubData(GL_UNIFORM_BUFFER, ubuElsOffset[3], sizeof(GLfloat) * 3, data);
}
- (void) writeClientMaterialKd: (YAVector3f*) kd
{
    if(uboBuffer == NULL)
        return;

    GLfloat data[] = {kd.x,kd.y,kd.z};
    glBufferSubData(GL_UNIFORM_BUFFER, ubuElsOffset[4], sizeof(GLfloat) * 3, data);    
}
- (void) writeClientMaterialKs: (YAVector3f*) ks
{
    if(uboBuffer == NULL)
        return;

    GLfloat data[] = {ks.x,ks.y,ks.z};
    glBufferSubData(GL_UNIFORM_BUFFER, ubuElsOffset[5], sizeof(GLfloat) * 3, data);    
}

- (void) writeClientMaterialShininess: (float) shininess
{
    if(uboBuffer == NULL)
        return;   

    glBufferSubData(GL_UNIFORM_BUFFER, ubuElsOffset[6], sizeof(GLfloat) , &shininess);     
}
- (void) writeClientMaterialReflection: (float) reflection
{
    if(uboBuffer == NULL)
        return;    

    glBufferSubData(GL_UNIFORM_BUFFER, ubuElsOffset[7], sizeof(GLfloat) , &reflection);     
}
- (void) writeClientMaterialRefraction: (float) refraction
{
    if(uboBuffer == NULL)
        return;    

    glBufferSubData(GL_UNIFORM_BUFFER, ubuElsOffset[8], sizeof(GLfloat) , &refraction);     

}
- (void) writeClientMaterialEta: (float) eta
{
    if(uboBuffer == NULL)
        return;    

    glBufferSubData(GL_UNIFORM_BUFFER, ubuElsOffset[9], sizeof(GLfloat) , &eta);     
}

@end
