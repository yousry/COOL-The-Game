#version 150
#extension GL_ARB_explicit_attrib_location : enable

// gourad fragment shader

in vec3 gsPosition;
in vec3 gsNormal;
in vec2 gsTextureCoord;

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

void adsFrag(out vec3 ambAndDiff, out vec3 spec) 
{
    vec3 ambient = clientLight.Intensity * clientMaterial.Ka;
    float isDirect = max(sign(clientLight.Position.w), 0);
    vec3 lightDirection = normalize(clientLight.Position.xyz - gsPosition * isDirect);
    float diffuseFactor = max(dot(gsNormal, lightDirection), 0);
    vec3 diffuse = diffuseFactor * clientMaterial.Kd * clientLight.Intensity;
    vec3 vertexToEye = normalize(clientEye - gsPosition);
    vec3 lightReflect = normalize( reflect(lightDirection, gsNormal)); 
    float specularFactor = dot(vertexToEye, lightReflect); 
    specularFactor = pow(specularFactor, clientMaterial.Shininess);
    vec3 specular = max(specularFactor , 0.0f) * min(diffuseFactor, 1) * clientMaterial.Ks * clientLight.Intensity;
    
    
    ambAndDiff = ambient + diffuse;
    spec = specular; 
}

void main() {
    vec4 texColor = texture(textureMap, gsTextureCoord);
    vec3 ambAndDiff, spec;
    adsFrag(ambAndDiff, spec);
    FragColor = vec4(ambAndDiff, 1.0f) * texColor + vec4(spec, 1.0f);
}




