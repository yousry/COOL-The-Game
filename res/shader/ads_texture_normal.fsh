#version 150
#extension GL_ARB_explicit_attrib_location : enable

// gourad fragment shader
in vec3 vsPosition;
in vec3 vsNormal;
in vec2 vsTextureCoord;
in vec3 vsTangent;

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
uniform sampler2D normalMap;

layout(location = 0) out vec4 FragColor;


void adsFrag(in vec3 texNormal, out vec3 ambAndDiff, out vec3 spec) 
{
    vec3 ambient = clientLight.Intensity * clientMaterial.Ka;
    float isDirect = max(sign(clientLight.Position.w), 0);
    vec3 lightDirection = normalize(clientLight.Position.xyz - vsPosition * isDirect);
    float diffuseFactor = max(dot(texNormal, lightDirection), 0);
    vec3 diffuse = diffuseFactor * clientMaterial.Kd * clientLight.Intensity;
    vec3 vertexToEye = normalize(clientEye - vsPosition);
    vec3 lightReflect = normalize( reflect(lightDirection, texNormal)); 
    float specularFactor = dot(vertexToEye, lightReflect); 
    specularFactor = pow(specularFactor, clientMaterial.Shininess);
    vec3 specular = max(specularFactor , 0.0f) * min(diffuseFactor, 1) * clientMaterial.Ks * clientLight.Intensity;
    
    ambAndDiff = ambient + diffuse;
    spec = specular; 
}

vec3 getTexNormal()
{
    vec3 normal = normalize(vsNormal);
    vec3 tangent = normalize(vsTangent);
    
    tangent = normalize(tangent - dot(tangent, normal) * normal);
    vec3 bitangent = cross(tangent, normal);
    
    vec3 borrowedNormal = texture(normalMap, vsTextureCoord).xyz;
    borrowedNormal = 2 * borrowedNormal - vec3(1.0, 1.0, 1.0);
    
    vec3 resultingNormal;
    
    mat3 TBN = mat3(tangent, bitangent, normal);
    resultingNormal = TBN * borrowedNormal;
    resultingNormal = normalize(resultingNormal);
    
    return resultingNormal;
}


void main() {
    vec4 texColor = texture(textureMap, vsTextureCoord);

    vec4 texNormalMap = texture(normalMap, vsTextureCoord);
    vec3 ambAndDiff, spec;
    vec3 texNormal = getTexNormal();
    adsFrag(texNormal, ambAndDiff, spec);
    FragColor = vec4(ambAndDiff, 1.0f) * texColor + vec4(spec, 1.0f);
}




