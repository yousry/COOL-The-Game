#version 150
#extension GL_ARB_explicit_attrib_location : enable

// pick vertex shader

layout (location = 0) in vec3 clientPosition;

out vec3 vsPosition;

uniform mat4 clientMVP;

void main()
{
    gl_Position = clientMVP * vec4(clientPosition, 1.0);
}