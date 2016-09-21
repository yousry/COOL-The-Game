//
//  YAGridModel.m
//  YAWorld
//
//  Created by Yousry Abdallah on 14.05.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES
#define GLCOREARB_PROTOTYPES
#import <GL/glcorearb.h>

#import "YATexture.h"
#import "YATextureArray.h"
#import "YAShader.h"
#import "YALog.h"

#import "YAModel.h"
#import "YAGridModel.h"

@interface YAGridModel()
@end

@implementation YAGridModel : YAModel

static const NSString* TAG = @"YAGridModel";

- (id) initTriangles: (NSData*) vertexBuffer  shader: (YAShader*) shader textures: (YATextureArray*) textureArray normal: (YATexture*) normal;
{
    [YALog debug:TAG message:@"initTriangles"];
    
    self = [super init];
    
    if (self) {
        
        _textureArray = textureArray;
        
        _normal = normal;
        vbos = vertexBuffer;
        ibos = nil;
        self.shaderId = [shader name];
        [self createVBO: shader];
    }
    return self;
}

- (bool) createVBO: (YAShader*) shader
{
    [YALog debug:TAG message:@"createVBO" ];
    [YALog isGLStateOk:TAG message:@"createVBO / init"];
    
    glGenVertexArrays(1, &vaoId);
    glBindVertexArray(vaoId);
    
    glGenBuffers(1, &vboId);
    glBindBuffer(GL_ARRAY_BUFFER, vboId);
    
    const NSUInteger vboSize = vbos.length;
    [YALog debug:TAG message:[NSString stringWithFormat:@"VBO Size: %ld", vboSize]];
    
    glBufferData(GL_ARRAY_BUFFER, vboSize, [vbos bytes], GL_DYNAMIC_DRAW);
    
    int vertexSize = 4 * 3; // (x  z)
    triangleCount = (int) (vboSize / (vertexSize * 3));
    [YALog debug:TAG message:[NSString stringWithFormat:@"Triangles: %d", triangleCount]];
    
    attribVertexLocation = glGetAttribLocation([shader programId], "clientPosition");
    attribNormalLocation = glGetAttribLocation([shader programId], "clientNormal");
    attribTextureLocation = glGetAttribLocation([shader programId], "clientTexture");
    
    if(attribVertexLocation != - 1) {
        glVertexAttribPointer(attribVertexLocation, 3, GL_FLOAT, GL_FALSE, vertexSize, 0);
        glEnableVertexAttribArray(attribVertexLocation);
        [YALog debug:TAG message:@"attribVertexLocation assigned" ];
    }   
    
    glBindVertexArray(0);
    return [YALog isGLStateOk:TAG message:@"createVBO"];
}    


- (void) draw: (YAShader *) shader SuccessiveDraw: (bool) successive
{
    if(!successive) {
        [YALog isGLStateOk:TAG message:@"DRAW INIT / FAILED"];
        glBindVertexArray(vaoId);
        
        [_textureArray bind: GL_TEXTURE0];
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
    
    glDrawArrays(GL_TRIANGLES, 0, triangleCount * 3);
    
//    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
//    glEnable(GL_CULL_FACE);
    
    [YALog isGLStateOk:TAG message:@"DRAW / FAILED"];
}

@end
