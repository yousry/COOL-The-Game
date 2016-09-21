#version 150
#extension GL_ARB_explicit_attrib_location : enable

// phong vertex shader

layout (location = 0) in vec3 clientPosition;
layout (location = 1) in vec3 clientNormal;  

struct LightInfo {
    vec4 Position;
    vec3 La; // ambient intensity;
    vec3 Ld; // diffuse light intensity
    vec3 Ls; // specular light intensity
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
uniform mat4 clientModel;
uniform mat4 clientMVP;

out vec3 vsColor;

vec3 adsVertex(vec3 position, vec3 normal) 
{
    vec3 ambient = clientMaterial.Ka * clientLight.La;
    vec3 lightDirection = normalize(vec3(clientLight.Position) - position);
    float diffuseFactor = dot(normal, lightDirection);
    
    vec3 diffuse = vec3(0.0); 
    vec3 specular = vec3(0.0);
    
    if(diffuseFactor > 0) {
        diffuse = clientMaterial.Kd * clientLight.Ld * diffuseFactor;
        vec3 vertexToEye = normalize(clientEye - clientPosition);
        vec3 lightReflect = normalize(reflect(lightDirection, normal));
        float specularFactor = dot(vertexToEye, lightReflect); 
        specularFactor = pow(specularFactor, clientMaterial.Shininess);
        if(specularFactor > 0) 
            specular = clientMaterial.Ks * clientLight.Ls * specularFactor;
    }
    
    return ambient + diffuse + specular; 
}

void main()
{
    vec3 position = (clientModel * vec4(clientPosition, 1.0)).xyz;
    vec3 normal = normalize((clientModel * vec4(clientNormal, 1.0)).xyz);

    vsColor = adsVertex(position, normal);
    
    gl_Position = clientMVP * vec4(clientPosition, 1.0);
}