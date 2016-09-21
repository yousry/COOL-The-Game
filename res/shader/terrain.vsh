#version 150
#extension GL_ARB_explicit_attrib_location : enable

// gourad vertex shader

layout (location = 0) in vec3 clientPosition;
layout (location = 1) in vec3 clientNormal;
layout (location = 2) in vec3 clientTexture;  

out vec3 vsPosition;
out vec3 vsNormal;
out vec3 vsTextureCoord;

out vec3 vsBlend;

uniform mat4 clientModel;
uniform mat4 clientMVP;

void main()
{
    vsBlend = clamp(abs(normalize(clientNormal)) - 0.5f, 0.0f, 1.0f);
    vsBlend *= vsBlend;
    vsBlend *= vsBlend;
    vsBlend /= dot(vsBlend, vec3(1.0, 1.0, 1.0));

    vsTextureCoord = clientTexture - vec3(clientNormal.x < 0, clientNormal.y >= 0, clientNormal.z < 0);
    vsNormal = normalize((clientModel * vec4(clientNormal, 0.0)).xyz);
    
    vsPosition =  (clientModel * vec4(clientPosition, 1.0)).xyz;
    gl_Position = clientMVP * vec4(clientPosition, 1.0);
}
