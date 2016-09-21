#version 150
#extension GL_ARB_explicit_attrib_location : enable

// gourad fragment shader
in vec3 vsPosition;
in vec3 vsNormal;
in vec3 vsTextureCoord;

in vec3 vsBlend;

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

uniform sampler2D texture;

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

void main() {
    vec3 ambAndDiff, spec;
    adsFrag(ambAndDiff, spec);
    
    vec4 color = vsBlend.x * texture(texture, vec2(vsTextureCoord.y,vsTextureCoord.z) * 0.2) +
                 vsBlend.y * texture(texture, vec2(vsTextureCoord.x,vsTextureCoord.z) * 0.2) + 
                 vsBlend.z * texture(texture, vec2(vsTextureCoord.x,vsTextureCoord.y) * 0.2);

        
    FragColor = vec4(ambAndDiff, 1.0f) * color + vec4(spec, 1.0f);
}




