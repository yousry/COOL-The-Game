#version 150
#extension GL_ARB_explicit_attrib_location : enable

// gourad fragment shader
in vec3 vsPosition;
in vec3 vsNormal;

struct LightInfo {
    vec4 Position;
    vec3 Intensity;
};

struct FogInfo {
    float maxDist;
    float minDist;
    vec3 color;
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
uniform FogInfo clientFog;


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
    float dist = distance(vsPosition, clientEye);
    float fogFactor = (clientFog.maxDist - dist) / (clientFog.maxDist - clientFog.minDist);
    fogFactor = clamp(fogFactor, 0.0f, 1.0f);
    vec3 shadeColor = adsFrag();
    vec3 color = mix(clientFog.color, shadeColor, fogFactor);
    FragColor = vec4(color, 1.0f);
}