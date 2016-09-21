#version 150
#extension GL_ARB_explicit_attrib_location : enable

#define M_PI_2 6.28318f


// gourad fragment shader
in vec3 vsPosition;
in vec3 vsNormal;
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
uniform float clientNow;


uniform sampler2D textureMap;
uniform float clientNormalMapFactor;

layout(location = 0) out vec4 FragColor;

void main() {
    vec4 texColor = texture(textureMap, vsTextureCoord);
    float swing = mod(clientNow, M_PI_2);
    vec2 flow = vec2(cos(swing + clientNormalMapFactor), sin(swing)) * 2.5;
    float irata = mod(vsTextureCoord.x * flow.x + vsTextureCoord.y  * flow.y + clientNormalMapFactor, 1);
    FragColor =  vec4( vec3(1 - irata * clientNormalMapFactor, irata, 1 - irata * clientNormalMapFactor) * texColor.a, texColor.a );
}




