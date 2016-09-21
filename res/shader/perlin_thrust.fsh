#version 150
#extension GL_ARB_explicit_attrib_location : enable
#extension GL_EXT_gpu_shader4 : enable


// thrust shader

in vec3 vsPosition;
in vec3 vsNormal;
in vec2 vsTextureCoord;
in vec3 vsUp;


struct LightInfo {
    vec4 Position;
    vec3 Intensity;
};

struct MaterialInfo {
    vec3 Ka; // ambient reflectivity
    vec3 Kd; // diffuse reflectivity
    vec3 Ks; // specular reflectivity
    float Shininess;
    float Eta;
};


uniform LightInfo clientLight;
uniform MaterialInfo clientMaterial;
uniform vec3 clientEye;
uniform float clientNow;

uniform sampler2D textureMap;

layout(location = 0) out vec4 FragColor;

void main() {
    
    float heatfactor = clientMaterial.Eta;
    float heat = clamp(1 - vsTextureCoord.y, 0,1);
    
    vec4 texColor = texture(textureMap, vec2(vsTextureCoord.x + (clientNow * clientMaterial.Ks.r + clientMaterial.Shininess) * 0.04,
                                           vsTextureCoord.y * 0.04 - (clientNow  * clientMaterial.Ks.g + clientMaterial.Shininess) * (0.5 + 0.5 * heatfactor)));
  

    float osc = mod(clientNow * clientMaterial.Ks.b * 3, 6);
    float oscFraq = abs(fract(osc));
    osc = floor(osc);
    
    float osc1 = mix(texColor.r , texColor.g, oscFraq) * int(osc == 0);
    osc1 += mix(texColor.g , texColor.b, oscFraq) * int(osc == 1);
    osc1 += mix(texColor.b , texColor.a, oscFraq) * int(osc == 2);
    osc1 += mix(texColor.a , texColor.b, oscFraq) * int(osc == 3);
    osc1 += mix(texColor.b , texColor.g, oscFraq) * int(osc == 4);
    osc1 += mix(texColor.g , texColor.r, oscFraq) * int(osc == 5);
    
    osc1 = pow(osc1, 1.5 + 1.5 * heatfactor);
    vec3 col = vec3(2.5 * osc1 * clientMaterial.Ka + 10 * osc1 * pow(heat * heatfactor, 3.5) * clientMaterial.Kd);
    
    float edgeFilter = 1 - abs(dot(vsUp, vsNormal));
    edgeFilter = abs(dot(clientEye, vsNormal));


    edgeFilter *= pow(heat, .85 + 25 * (1 - heatfactor));
    edgeFilter *= clamp(col.x + col.y + + col.z, 0, 1);
    
    
    if(edgeFilter < 0.2)
        discard;
    else
        FragColor = vec4(col, edgeFilter);
    
}




