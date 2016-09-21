#version 150
#extension GL_ARB_explicit_attrib_location : enable

// cell fragment shader
in vec3 vsPosition;
in vec3 vsNormal;



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

const int levels = 5;
const float scaleFactor = 1.0f / levels; 

layout(location = 0) out vec4 FragColor;

vec3 cell()
{
    vec3 lightDirection = normalize(clientLight.Position.xyz - vsPosition.xyz);
    float cosine = max (0.0f, dot(vsNormal, lightDirection));
    vec3 diffuse = clientMaterial.Kd * floor(cosine * levels) * scaleFactor;
    return clientLight.Intensity * (clientMaterial.Ka + diffuse);
}

void main() {
    FragColor = vec4(cell(), 1.0);
}