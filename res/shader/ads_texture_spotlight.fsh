#version 150
#extension GL_ARB_explicit_attrib_location : enable

// gourad fragment shader
in vec3 vsPosition;
in vec3 vsNormal;
in vec2 vsTextureCoord;
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
uniform sampler2DShadow shadowMap;

layout(location = 0) out vec4 FragColor;

void adsFrag(out vec3 ambAndDiff, out vec3 spec)
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
    
    
    ambAndDiff = ambient + diffuse;
    spec = specular;
}


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
    vec4 texColor = texture(textureMap, vsTextureCoord);
    vec3 ambient =  clientSpotLight.intensity * clientMaterial.Ka;
    vec3 diffAndSpec = adsSpotLightDS();
    
    vec3 ambAndDiff, spec;
    adsFrag(ambAndDiff, spec);
    
//    FragColor = (vec4(diffAndSpec * shadow + ambient, 1.0) + vec4(ambAndDiff , 1.0f)) * texColor + vec4(spec * shadow, 1.0f);
    
    FragColor = vec4((diffAndSpec * shadow + ambient + ambAndDiff) * texColor.xyz + spec * shadow, texColor.w) ;
    
    
}




