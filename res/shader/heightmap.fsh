#version 150
#extension GL_ARB_explicit_attrib_location : enable

#define M_PI 3.14159f


// gourad fragment shader
in vec3 vsPosition;
in vec3 vsNormal;
in vec4 vsTextureMix;
in float vsHeight;
in vec2 vsUVPos;
in vec3 clPos;


//centroid in float vsShadow;
uniform sampler2DShadow shadowMap;
in vec4 vsShadowProjection;

struct LightInfo {
    vec4 Position;
    vec3 Intensity;
};

struct MaterialInfo {
    vec3 Ka; // ambient reflectivity
    vec3 Kd; // diffuse reflectivity
    vec3 Ks; // specular reflectivity
    float Shininess; 
    float Reflection; // used for laser pointer xPos
    float Refraction; // used for laser pointer yPos
    float Eta;
};

uniform float matSpecularPower; // depricated: used here for laser pointer visibility

uniform LightInfo clientLight;
uniform MaterialInfo clientMaterial;
uniform vec3 clientEye;

uniform sampler2DArray textureMap;
uniform samplerCube clientDiffuseMap;
uniform samplerCube clientSpecularMap;

uniform float clientNow;

layout(location = 0) out vec4 FragColor;

void adsFrag(out vec3 ambient, out vec3 diffuse, out vec3 spec)
{
    ambient = clientLight.Intensity * clientMaterial.Ka;
    float isDirect = max(sign(clientLight.Position.w), 0);
    vec3 lightDirection = normalize(clientLight.Position.xyz - vsPosition * isDirect);
    float diffuseFactor = max(dot(vsNormal, lightDirection), 0);
    diffuse = diffuseFactor * clientMaterial.Kd * clientLight.Intensity;
    vec3 vertexToEye = normalize(clientEye - vsPosition);
    vec3 lightReflect = normalize( reflect(lightDirection, vsNormal));
    float specularFactor = dot(vertexToEye, lightReflect);
    specularFactor = pow(specularFactor, clientMaterial.Shininess);
    spec = max(specularFactor , 0.0f) * min(diffuseFactor, 1) * clientMaterial.Ks * clientLight.Intensity;
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
    
    vec3 ambient, diffuse, spec;
    adsFrag(ambient, diffuse, spec);
    
    float swing = mod(clientNow, 2 * M_PI);
    vec2 flow = vec2(0, sin(swing) * 0.2);
    
    
    vec4 colorA = texture(textureMap, vec3(vsUVPos + flow ,0));
    vec4 colorB = texture(textureMap, vec3(vsUVPos,1));
    vec4 colorC = texture(textureMap, vec3(vsUVPos,2));
    vec4 colorD = texture(textureMap, vec3(vsUVPos,3));
    
    vec4 color = vsTextureMix.x * colorA +
    vsTextureMix.y * colorB +
    vsTextureMix.z * colorC +
    vsTextureMix.w * colorD;
    
    vec4 diffuseIrradiance = texture(clientDiffuseMap, vsNormal) * 1;
    vec4 specularIrradiance = texture(clientSpecularMap, clientEye) * 0.25;
    
    float shadow = CalcShadowFactor(vsShadowProjection);
    float fakedAO = clamp(0.7 + vsHeight * 10,0.0f,1.0f);
    
    vec4 distance = vec4(1);
    distance.g = distance.b =
    max(
        clamp(
              (pow(clPos.x - clientMaterial.Reflection,2) + pow(clPos.z - clientMaterial.Refraction,2)) * 32 // simplified distance function
              , 0, 1),
        matSpecularPower // visibility switch 1 = invisible
        ); // higher multiplicator decreases the radius
    
    
    FragColor = vec4(
                     ((ambient + diffuse * shadow + diffuseIrradiance.xyz) * color.xyz +
                      (spec  * shadow + specularIrradiance.xyz)) *
                     fakedAO
                     ,1) * distance;
}
