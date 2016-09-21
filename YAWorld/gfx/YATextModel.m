//
//  YATextModel.m
//  MarbleChampionship
//
//  Created by Yousry Abdallah on 06.12.11.
//  Copyright 2011 yousry.de. All rights reserved.
//

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES
#define GLCOREARB_PROTOTYPES
#import <GL/glcorearb.h>

#import "YATexture.h"
#import "YAShader.h"
#import "YALog.h"
#import "YATextModel.h"

@interface YATextModel()
- (bool) createVBO: (YAShader*) shader;
@end

@implementation YATextModel

static const NSString* TAG = @"YATextModel";

- (id)initTrianglesWithShader: (YATexture*) texture 
                 vertexBuffer:(NSData*) vertexBuffer 
                       shader: (YAShader*) shader
{
    [YALog debug:TAG message:@"initTrianglesWithShader" ];
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

- (bool) createVBO: (YAShader*) shader
{
    [YALog debug:TAG message:@"createVBO" ];
    [YALog isGLStateOk:TAG message:@"createVBO / init"];
    
    glGenVertexArrays(1, &vaoId);
    glBindVertexArray(vaoId);
    
    if(vaoId == 0) {
        // NSLog(@"COULD NOT CREATE VAO!!");
        glfwTerminate();
        exit(0);
    }

    glGenBuffers(1, &vboId);
    glBindBuffer(GL_ARRAY_BUFFER, vboId);

    const NSUInteger vboSize = vbos.length;
    [YALog debug:TAG message:[NSString stringWithFormat:@"VBO Size: %ld", vboSize]];
    
    
    glBufferData(GL_ARRAY_BUFFER, vboSize, [vbos bytes], GL_STATIC_DRAW);
    
    triangleCount = (int) (vboSize / (4 * 5 * 3));
    [YALog debug:TAG message:[NSString stringWithFormat:@"Triangles: %d", triangleCount]];

    attribVertexLocation = shader.locPosition;
    attribTextureLocation =  shader.locTexture;

    int vertexSize = 4 * 5; // floatsize in byte * (3 coords + 2 uv)
    
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

    if(vaoId == 0) {
        NSLog(@"Warning vao is 0");
    }

    glDrawArrays(GL_TRIANGLES, 0, triangleCount * 3);
    [YALog isGLStateOk:TAG message:@"DRAW / FAILED"];
}



@end
