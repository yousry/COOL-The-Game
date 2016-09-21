#version 150
#extension GL_ARB_explicit_attrib_location : enable

layout (location = 0) in vec2 clientPosition;

uniform float clientNormalMapFactor;

uniform mat4 clientModel;
uniform mat4 clientMVP;

uniform sampler2D normalMap;

out vec3 vsPosition;
out vec3 vsNormal;


void main()
{
    vec2 vHeight = vec2(0.5 * clientPosition.x + 0.5, 0.5 * clientPosition.y + 0.5);
    vec4 heightmapColor = texture(normalMap, vHeight);
    vec3 clPos = vec3(clientPosition.x, 0.0f, clientPosition.y);
    clPos.y = (heightmapColor.r - heightmapColor.g) * clientNormalMapFactor;
    gl_Position = clientMVP * vec4(clPos, 1.0);
}