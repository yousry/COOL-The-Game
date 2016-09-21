#version 150
#extension GL_ARB_explicit_attrib_location : enable

#define waves 1

layout (location = 0) in vec3 clientPosition;

struct MaterialInfo {
    vec3 Ka; // ambient reflectivity
    vec3 Kd; // diffuse reflectivity
    vec3 Ks; // specular reflectivity
    float Shininess; // used for visibility
    float Reflection; // used for laser pointer xPos
    float Refraction; // used for laser pointer yPos
    float Eta;
};

uniform MaterialInfo clientMaterial;
uniform float clientNormalMapFactor;

uniform mat4 clientModel;
uniform mat4 clientMVP;
uniform mat4 clientShadowMVP;

uniform sampler2D normalMap;

#ifdef waves
uniform float clientNow;
#endif

out vec3 vsPosition;
out vec3 vsNormal;

out vec4 vsTextureMix;

out vec4 vsShadowProjection;

out float vsHeight;

out vec2 vsUVPos;
out vec3 clPos;

void main()
{
    vsUVPos = vec2(0,0);
    
    float disassember = clientPosition.z;
    vsUVPos.x = floor(disassember / 1000);
    disassember -= vsUVPos.x * 1000;
    vsUVPos.y = floor(disassember);
    vsUVPos *= clientMaterial.Eta;
    
    // the height of the grid position is stored in the heightmap (alias: normal)
    vec2 vHeight = vec2(0.5 * clientPosition.x + 0.5, 0.5 * clientPosition.y + 0.5);
    vec4 heightmapColor = texture(normalMap, vHeight);
    
    //the vertex consists of the 2d grid position + heightmap height
    clPos = vec3(clientPosition.x, 0.0f, clientPosition.y);
    
    // r channel is positive g channel is negative to the height
    clPos.y = (heightmapColor.r - heightmapColor.g) * clientNormalMapFactor;
    
    // calculate the normal
    vec4 hgTC = textureOffset(normalMap, vHeight,ivec2(0,-1));
    vec4 hgBC = textureOffset(normalMap, vHeight,ivec2(0,+1));
    vec4 hgLC = textureOffset(normalMap, vHeight,ivec2(-1,0));
    vec4 hgRC = textureOffset(normalMap, vHeight,ivec2(+1,0));
    
    float dzx = ((hgLC.r - hgLC.g) - (hgRC.r - hgRC.g)) * clientNormalMapFactor;
    float dzz = ((hgTC.r - hgTC.g) - (hgBC.r - hgBC.g)) * clientNormalMapFactor;
    vec3 clientNormal = vec3(dzx,0.05,dzz);
    clientNormal = normalize(clientNormal);
    
    vsTextureMix = vec4(float(clPos.y < 0),
                        float(clPos.y >= 0 && clPos.y <= 0.14f),
                        float(clPos.y > 0.14f && clPos.y <= 0.21),
                        float(clPos.y > 0.21f));
    
    vsNormal =  normalize((clientModel * vec4(clientNormal, 1.0)).xyz);
    
    vsPosition =  (clientModel * vec4(clPos, 1.0)).xyz;
    vsHeight = clPos.y;
    
#ifdef waves
    // Water simulation
    if(clPos.y < 0.0f) {
        const vec2 windDir = vec2 (0.2,0.8f);
        const float roughness = 1.0f;
        const float waveHeight = -0.01f;
        float fTime = clientNow * 0.2;
        
        float height = sin( 32.0 * (clPos.x + (windDir.x * fTime)));
        height += 1.0;
        height = pow( max(0.0, height), roughness);
        
        float height2 = sin( 16.0 * (clPos.z + (windDir.y * fTime)));
        height2 += 1.0;
        height2 = pow( max(0.0, height2), roughness);
        
        clPos.y = waveHeight * ((height + height2) / 2.0);
        
        vec3 binormal = normalize(vec3( cos(32.0 * (clPos.x + (windDir.x * fTime))), 1.0, 0.0));
        vec3 tangent  = normalize(vec3( 0.0, 1.0, 1 * cos(16.0 * (clPos.z + (windDir.y * fTime)))));
        vsNormal = cross(binormal, tangent);
        vsNormal += vec3(1.0,1.0,1.0);
    }
#endif
    
    vsShadowProjection =  clientShadowMVP * vec4(clPos, 1.0);
    gl_Position = clientMVP * vec4(clPos, 1.0);
}