#version 150
#extension GL_ARB_explicit_attrib_location : enable

// skymap vertex shader
in vec3 vsTextureCoord;

uniform samplerCube clientSkyMap;

layout(location = 0) out vec4 FragColor;

void main()
{
   vec4 texColor = texture(clientSkyMap, vsTextureCoord);
    FragColor = texColor;
}