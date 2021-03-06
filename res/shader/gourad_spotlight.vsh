#version 150
#extension GL_ARB_explicit_attrib_location : enable

// gourad spotlight vertex shader

layout (location = 0) in vec3 clientPosition;
layout (location = 1) in vec3 clientNormal;  
layout (location = 2) in vec2 clientTexture;  

uniform mat4 clientModel;
uniform mat4 clientMVP;
uniform mat4 clientShadowMVP;

out vec3 vsPosition;
out vec4 vsShadowProjection;
out vec3 vsNormal;

out vec2 vsTextureCoord;

void main()
{
    vsNormal = normalize((clientModel * vec4(clientNormal, 0.0)).xyz);
    vsPosition =  (clientModel * vec4(clientPosition, 1.0)).xyz;
    vsShadowProjection    =  clientShadowMVP * vec4(clientPosition, 1.0);
    gl_Position = clientMVP * vec4(clientPosition, 1.0);
}