#version 150
#extension GL_ARB_explicit_attrib_location : enable

// gourad fragment shader
in vec3 vsPosition;
in vec3 vsNormal;
in vec2 vsTextureCoord;
in vec3 vsTangent;
in vec4 vsShadowProjection;

struct LightInfo {
    vec4 Position;
    vec3 Intensity;
};

struct SpotLightInfo {
    vec4 position;
    vec3 intensity;
    vec3 direction;
    float exponent;
    float cutoff;
};

struct MaterialInfo {
    vec3 Ka; // ambient reflectivity
    vec3 Kd; // diffuse reflectivity
    vec3 Ks; // specular reflectivity
    float Shininess;
};

uniform LightInfo clientLight;
uniform SpotLightInfo clientSpotLight;
uniform MaterialInfo clientMaterial;
uniform vec3 clientEye;

uniform sampler2D textureMap;
uniform sampler2D normalMap;
uniform sampler2DShadow shadowMap;



layout(location = 0) out vec4 FragColor;

void adsFrag(in vec3 texNormal, out vec3 ambient, out vec3 diffuse, out vec3 specular)
{
    ambient = clientLight.Intensity * clientMaterial.Ka;
    
    float isDirect = max(sign(clientLight.Position.w), 0);
    vec3 lightDirection = normalize(clientLight.Position.xyz - vsPosition * isDirect);
    
    float diffuseFactor = max(dot(texNormal, lightDirection), 0);
    diffuse = diffuseFactor * clientMaterial.Kd * clientLight.Intensity;
    
    vec3 vertexToEye = normalize(clientEye - vsPosition);
    vec3 lightReflect = normalize( reflect(lightDirection, texNormal));
    float specularFactor = dot(vertexToEye, lightReflect);
    
    specularFactor = pow(specularFactor, clientMaterial.Shininess);
    specular = max(specularFactor , 0.0f) * min(diffuseFactor, 1) * clientMaterial.Ks * clientLight.Intensity;
}

void adsFragSL(in vec3 texNormal, out vec3 ambient, out vec3 diffuse, out vec3 specular)
{
    ambient = clientSpotLight.intensity * clientMaterial.Ka;
    
    float isDirect = max(sign(clientSpotLight.position.w), 0);
    vec3 lightDirection = normalize(clientSpotLight.position.xyz - vsPosition * isDirect);
    
    float diffuseFactor = max(dot(texNormal, lightDirection), 0);
    diffuse = diffuseFactor * clientMaterial.Kd * clientSpotLight.intensity;
    
    vec3 vertexToEye = normalize(clientEye - vsPosition);
    vec3 lightReflect = normalize( reflect(lightDirection, texNormal));
    float specularFactor = dot(vertexToEye, lightReflect);
    
    specularFactor = pow(specularFactor, clientMaterial.Shininess);
    specular = max(specularFactor , 0.0f) * min(diffuseFactor, 1) * clientMaterial.Ks * clientSpotLight.intensity;
    
    float angle = acos ( dot(-lightDirection, clientSpotLight.direction));
    float cutoff = radians( clamp ( clientSpotLight.cutoff, 0.0f, 90.0f ));
    
    if (angle < cutoff) {
        float spotFactor = pow( dot( -lightDirection, clientSpotLight.direction ), clientSpotLight.exponent);
        specular *= spotFactor * clientSpotLight.intensity;
        diffuse *= spotFactor * clientSpotLight.intensity;
    } else {
        specular = vec3(0,0,0);
        diffuse = vec3(0,0,0);
    }
}

vec3 getTexNormal()
{
    vec3 normal = normalize(vsNormal);
    vec3 tangent = normalize(vsTangent);
    
    tangent = normalize(tangent - dot(tangent, normal) * normal);
    vec3 bitangent = cross(tangent, normal);
    
    vec3 borrowedNormal = texture(normalMap, vsTextureCoord).xyz;
    borrowedNormal = 2.0 * borrowedNormal - vec3(1.0, 1.0, 1.0);
    
    vec3 resultingNormal;
    
    mat3 TBN = mat3(tangent, bitangent, normal);
    resultingNormal = TBN * borrowedNormal;
    resultingNormal = normalize(resultingNormal);
    
    return resultingNormal;
}

float CalcShadowFactor(vec4 LightSpacePos)
{
    float depth = textureProjOffset(shadowMap, LightSpacePos, ivec2(-1,-1));
    depth  += textureProjOffset(shadowMap, LightSpacePos, ivec2(-1,1));
    depth  += textureProjOffset(shadowMap, LightSpacePos, ivec2(1,1));
    depth  += textureProjOffset(shadowMap, LightSpacePos, ivec2(1,-1));
    depth *= 0.25;
    return  depth;
}

void main() {
    vec4 texColor = texture(textureMap, vsTextureCoord);
    vec4 texNormalMap = texture(normalMap, vsTextureCoord);
    float shadow = CalcShadowFactor(vsShadowProjection);
    
    vec3 texNormal = getTexNormal();
    
    vec3 dAmbient, dDiffuse ,dSpecular;
    adsFrag(texNormal, dAmbient ,dDiffuse, dSpecular);
    
    vec3 mAmbient, mDiffuse, mSpecular;
    adsFragSL(texNormal, mAmbient, mDiffuse, mSpecular);
    
    FragColor = vec4(texColor.rgb * ((mAmbient + dAmbient) + (mDiffuse * shadow + dDiffuse) )  + (mSpecular + dSpecular) * shadow, texColor.a);
}




