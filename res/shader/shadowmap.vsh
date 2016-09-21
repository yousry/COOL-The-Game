#version 150
#extension GL_ARB_explicit_attrib_location : enable

// shadow vertex shader

layout (location = 0) in vec3 clientPosition;

uniform mat4 clientMVP;

void main()
{
    gl_Position = clientMVP * vec4(clientPosition, 1.0);
}