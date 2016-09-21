#version 150
#extension GL_ARB_explicit_attrib_location : enable

// gourad spotlight fragment shader

in vec3 vsPosition;
in vec3 vsNormal;
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
    float Eta;
};

uniform LightInfo clientLight;
uniform SpotLightInfo clientSpotLight;
uniform MaterialInfo clientMaterial;
uniform vec3 clientEye;

uniform sampler2DShadow shadowMap;
uniform samplerCube clientDiffuseMap;
uniform samplerCube clientSpecularMap;

layout(location = 0) out vec4 FragColor;

vec3 adsSpotLightDS()
{
    vec3 lightDirection = normalize(clientSpotLight.position.xyz - vsPosition);
    float angle = acos ( dot(-lightDirection, clientSpotLight.direction));
    float cutoff = radians( clamp ( clientSpotLight.cutoff, 0.0f, 90.0f ));
    
    if (angle < cutoff) {
        float spotFactor = pow( dot( -lightDirection, clientSpotLight.direction ), clientSpotLight.exponent);
        vec3 v = normalize(vec3(-vsPosition));
        vec3 h = normalize(v + lightDirection);
        
        return spotFactor * clientSpotLight.intensity * (
                                                         clientMaterial.Kd * max( dot(lightDirection, vsNormal), 0.0f) +
                                                         clientMaterial.Ks * pow( max( dot(h,vsNormal), 0.0f ), clientMaterial.Shininess ));
    } else {
        return vec3(0,0,0);
    }
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
    float shadow = CalcShadowFactor(vsShadowProjection);
    
    vec4 diffuseIrradiance = texture(clientDiffuseMap, vsNormal) * 0.5;
    vec4 specularIrradiance = texture(clientSpecularMap, clientEye) * 0.25;

    vec3 ambient = clientMaterial.Ka;
    vec3 diffAndSpec = adsSpotLightDS();

    FragColor = vec4(diffAndSpec  * shadow + diffuseIrradiance.xyz + ambient * clientMaterial.Eta + specularIrradiance.xyz, 1.0);
}





