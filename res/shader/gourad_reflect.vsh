#version 150
#extension GL_ARB_explicit_attrib_location : enable

// gourad vertex shader

layout (location = 0) in vec3 clientPosition;
layout (location = 1) in vec3 clientNormal;  

struct MaterialInfo {
    vec3 Ka; // ambient reflectivity
    vec3 Kd; // diffuse reflectivity
    vec3 Ks; // specular reflectivity
    float Shininess;
    float Reflection;
    float Refraction;
    float Eta;
};


uniform vec3 clientEye;
uniform mat4 clientModel;
uniform mat4 clientMVP;
uniform MaterialInfo clientMaterial;

out vec3 vsPosition;
out vec3 vsNormal;
out vec3 vsReflectRay;
out vec3 vsRefractRay;


void main()
{
    vsNormal =  normalize((clientModel * vec4(clientNormal, 1.0)).xyz);
    vsPosition =  (clientModel * vec4(clientPosition, 1.0)).xyz;
    
    vsReflectRay = reflect(-clientEye, vsNormal );
    vsRefractRay = refract(-clientEye, vsNormal, clientMaterial.Eta);
    
    gl_Position = clientMVP * vec4(clientPosition, 1.0);
}