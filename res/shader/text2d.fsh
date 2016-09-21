#version 150
#extension GL_ARB_explicit_attrib_location : enable

// text2d fragment shader
in vec2 vsTextureCoord;

struct MaterialInfo {
    vec3 Ka; // ambient reflectivity
    vec3 Kd; // diffuse reflectivity
    vec3 Ks; // specular reflectivity
    float Shininess;
    float Eta;
};

uniform MaterialInfo clientMaterial;
uniform sampler2D textureMap;

layout(location = 0) out vec4 FragColor;

void main() {

    float depth = texture(textureMap, vsTextureCoord).a; 
    
    if (depth < clientMaterial.Eta)
        discard;
    
    FragColor = vec4(clientMaterial.Ka * depth, depth);
  


}