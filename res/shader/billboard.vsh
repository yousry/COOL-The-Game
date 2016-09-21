#version 150
#extension GL_ARB_explicit_attrib_location : enable

// gourad vertex shader

layout (location = 0) in vec3 clientPosition;
layout (location = 1) in vec2 clientTexture;

out vec2 vsTextureCoord;

uniform float clientRatio;
uniform mat4 clientMVP;

void main()
{
    vsTextureCoord = vec2(-clientTexture.y, clientTexture.x);
    
    
    // undo the rotation
    vec3 undoRot =   (clientPosition.x * clientRatio) * vec3(clientMVP[0][1], clientMVP[1][1], clientMVP[2][1])
                   + clientPosition.y * vec3(clientMVP[0][0], clientMVP[1][0], clientMVP[2][0]);
    
    gl_Position = clientMVP * vec4(normalize(undoRot), 1);
}
