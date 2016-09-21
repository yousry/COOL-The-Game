#version 150
#extension GL_ARB_explicit_attrib_location : enable

// gourad fragment shader
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

uniform samplerCube clientDiffuseMap;
uniform samplerCube clientSpecularMap;


layout(location = 0) out vec4 FragColor;

vec3 adsFrag() 
{
    vec3 ambient = clientLight.Intensity * clientMaterial.Ka;
    float isDirect = max(sign(clientLight.Position.w), 0);
    vec3 lightDirection = normalize(clientLight.Position.xyz - vsPosition * isDirect);
    float diffuseFactor = max(dot(vsNormal, lightDirection), 0);
    vec3 diffuse = diffuseFactor * clientMaterial.Kd * clientLight.Intensity;
    vec3 vertexToEye = normalize(clientEye - vsPosition);
    vec3 lightReflect = normalize( reflect(lightDirection, vsNormal)); 
    float specularFactor = dot(vertexToEye, lightReflect); 
    specularFactor = pow(specularFactor, clientMaterial.Shininess);
    vec3 specular = max(specularFactor , 0.0f) * min(diffuseFactor, 1) * clientMaterial.Ks * clientLight.Intensity;
    
    return ambient + diffuse + specular; 
}

void main() {
    
    vec4 diffuseIrradiance = texture(clientDiffuseMap, vsNormal) * 1;
    diffuseIrradiance.w = 1;
    vec4 specularIrradiance = texture(clientSpecularMap, clientEye) * 0.25;
    specularIrradiance.w = 1;
    
    FragColor = vec4(adsFrag(), 1.0) + diffuseIrradiance + specularIrradiance;
}