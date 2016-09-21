#version 150
#extension GL_ARB_explicit_attrib_location : enable

// phong fragment shader

in vec3 vsColor;

layout(location = 0) out vec4 FragColor;

void main() {
    FragColor = vec4(vsColor, 1.0);
}