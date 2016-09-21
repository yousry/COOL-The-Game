#version 150
#extension GL_ARB_explicit_attrib_location : enable

// thrust shader

layout (location = 0) in vec3 clientPosition;
layout (location = 1) in vec3 clientNormal;
layout (location = 2) in vec2 clientTexture;  

out vec3 vsPosition;
out vec3 vsNormal;
out vec2 vsTextureCoord;
out vec3 vsUp;

uniform mat4 clientModel;
uniform mat4 clientMVP;

void main()
{
    
    vsUp = normalize(vec3(clientMVP[0][0],clientMVP[1][0],clientMVP[2][0]));
    
    vsTextureCoord = clientTexture;
    vsNormal = normalize((clientModel * vec4(clientNormal, 0.0)).xyz);
    vsPosition =  (clientModel * vec4(clientPosition, 1.0)).xyz;
    gl_Position = clientMVP * vec4(clientPosition, 1.0);
}
