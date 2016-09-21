#version 150
#extension GL_ARB_explicit_attrib_location : enable

// text2d vertex shader

layout (location = 0) in vec3 clientPosition;
layout (location = 1) in vec2 clientTexture;  

out vec2 vsTextureCoord;

uniform mat4 clientMVP;

void main()
{
    vsTextureCoord = clientTexture;
    gl_Position = clientMVP * vec4(clientPosition, 1.0);
}