#version 150
#extension GL_ARB_explicit_attrib_location : enable

// gourad fragment shader
in vec2 vsTextureCoord;

struct LightInfo {
    vec4 Position;
    vec3 Intensity;
};

struct MaterialInfo {
    vec3 Ka; // ambient reflectivity
    vec3 Kd; // diffuse reflectivity
    vec3 Ks; // specular reflectivity
    float Shininess;
};

uniform LightInfo clientLight;
uniform MaterialInfo clientMaterial;
uniform vec3 clientEye;

uniform sampler2D textureMap;

layout(location = 0) out vec4 FragColor;

void main() {
    vec4 texColor = texture(textureMap, vsTextureCoord);
    
    if(texColor.a < 0.2)
        discard;
    
    FragColor = vec4(texColor.xyz, texColor.a * 0.9);
}




