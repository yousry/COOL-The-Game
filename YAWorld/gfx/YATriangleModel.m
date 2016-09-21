//
//  YATriangleModel.m
//  YAWorld
//
//  Created by Yousry Abdallah on 04.02.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES
#define GLCOREARB_PROTOTYPES
#import <GL/glcorearb.h>

#import "YATexture.h"
#import "YAShader.h"
#import "YALog.h"
#import "YATriangleModel.h"

@interface YATriangleModel ()
- (bool) createVBO: (YAShader*) shader;
@end

@implementation YATriangleModel

static const NSString* TAG = @"YATriangleModel";

- (id) initTriangles: (NSData*) vertexBuffer  shader: (YAShader*) shader texture: (YATexture*) texture 
{
    [YALog debug:TAG message:@"initTriangles"];
    self = [super init];
    if (self) {
        _texture = texture;
        _normal = nil;
        vbos = vertexBuffer;
        ibos = nil;
        self.shaderId = [shader name];
        [self createVBO: shader];
    }
    return self;   
}

-(bool) updateVBO: (NSData*) vertexBuffer
{
//    [YALog debug:TAG message:@"updateVBO" ];
//    [YALog isGLStateOk:TAG message:@"updateVBO / init"];
        
    glBindVertexArray(vaoId);
    glBindBuffer(GL_ARRAY_BUFFER, vboId);
    
    vbos = vertexBuffer;
    const NSUInteger vboSize = vbos.length;
//    [YALog debug:TAG message:[NSString stringWithFormat:@"VBO Size: %d", vboSize]];
    
    int vertexSize = 4 * (3 + 3 + 3); // (x y z) (nx ny nz) (u v w) 
    triangleCount = (int) (vboSize / (vertexSize * 3));
    
    glBufferData(GL_ARRAY_BUFFER, vboSize, [vbos bytes], GL_DYNAMIC_DRAW);
    
    glBindVertexArray(0);
    return [YALog isGLStateOk:TAG message:@"updateVBO"];
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

    int vertexSize = 4 * (3 + 3 + 3); // (x y z) (nx ny nz) (u v w) 
    triangleCount = (int) (vboSize / (vertexSize * 3));
    [YALog debug:TAG message:[NSString stringWithFormat:@"Triangles: %d", triangleCount]];
    
    attribVertexLocation = shader.locPosition;
    attribNormalLocation = shader.locNormal;
    attribTextureLocation =shader.locTexture;

    if(attribVertexLocation != - 1) {
        glVertexAttribPointer(attribVertexLocation, 3, GL_FLOAT, GL_FALSE, vertexSize, 0);
        glEnableVertexAttribArray(attribVertexLocation);
        [YALog debug:TAG message:@"attribVertexLocation assigned" ];
    }   
    
    if(attribNormalLocation != - 1) {
        glVertexAttribPointer(attribNormalLocation, 3, GL_FLOAT, GL_FALSE, vertexSize, (const GLvoid*)12);
        glEnableVertexAttribArray(attribNormalLocation);
        [YALog debug:TAG message:@"attrib_NormalLocation assigned" ];
    }   
    
    if(attribTextureLocation != - 1) {
        glVertexAttribPointer(attribTextureLocation, 3, GL_FLOAT, GL_FALSE, vertexSize, (const GLvoid*) 24);
        glEnableVertexAttribArray(attribTextureLocation);
        [YALog debug:TAG message:@"attribTextureLocation assigned" ];
    }  
    
    glBindVertexArray(0);
    return [YALog isGLStateOk:TAG message:@"createVBO"];
}    


- (void) draw: (YAShader *) shader SuccessiveDraw: (bool) successive
{
    [YALog isGLStateOk:TAG message:@"DRAW INIT / FAILED"];
    
    if(!successive) {
        glBindVertexArray(vaoId);
        
        [_texture bind: GL_TEXTURE0];
        GLuint loc = shader.locTextureMap;
        if(loc != -1) {
            glUniform1i(loc, 0);
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
