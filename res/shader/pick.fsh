#version 150
#extension GL_EXT_gpu_shader4 : enable
#extension GL_ARB_explicit_attrib_location : enable

// layout(location = 0) out vec3 FragColor;
layout(location = 0) out uvec3 FragColor;

uniform uint gObjectIndex; 
uniform uint gDrawIndex; 

void main() {
// FragColor = vec3(gObjectIndex, gDrawIndex, gl_PrimitiveID + 1);
    FragColor = uvec3(gObjectIndex, gDrawIndex, gl_PrimitiveID + 1);
}