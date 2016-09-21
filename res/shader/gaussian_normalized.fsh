#version 150
#extension GL_ARB_explicit_attrib_location : enable

// gourad fragment shader
in vec3 vsPosition;
in vec3 vsNormal;
in vec2 vsTextureCoord;

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




void blinn(out vec3 ambient, out vec3 diffuse, out vec3 specular)
{
    
    float isDirect = max(sign(clientLight.Position.w), 0);
    vec3 lightDirection = normalize(clientLight.Position.xyz - vsPosition * isDirect);
    float diffuseFactor = max(dot(vsNormal, lightDirection), 0);
    vec3 vertexToEye = normalize(clientEye - vsPosition);
//  vec3 lightReflect = normalize( reflect(lightDirection, vsNormal)  );
    vec3 lightReflect = normalize(lightDirection + vsNormal);
    float specularFactor = dot(vertexToEye, lightReflect);
    specularFactor = pow(specularFactor, clientMaterial.Shininess);
    ambient = clientLight.Intensity * clientMaterial.Ka;
    diffuse = diffuseFactor * clientMaterial.Kd * clientLight.Intensity;
    specular = max(specularFactor , 0.0f) * min(diffuseFactor, 1) * clientMaterial.Ks * clientLight.Intensity * 0.5;
}


float CalcAttenuation(in vec3 cameraSpacePosition, out vec3 lightDirection)
{
	vec3 lightDifference =  clientLight.Position.xyz - cameraSpacePosition;
	float lightDistanceSqr = dot(lightDifference, lightDifference);
	lightDirection = lightDifference * inversesqrt(lightDistanceSqr);

    float lightAttenuation = 10;
    
	return (1 / ( 1.0 + lightAttenuation * sqrt(lightDistanceSqr)));
    
}

void main() {
    vec4 texColor = texture(texture, vsTextureCoord);
    vec3 ambient, diffuse, specular;
    blinn(ambient, diffuse, specular);
    
	vec3 lightDir = vec3(0.0);
	float atten = CalcAttenuation(clientEye, lightDir);
	vec4 attenIntensity = atten * vec4(clientLight.Intensity, 1);
    
	vec3 surfaceNormal = normalize(vsNormal);
	float cosAngIncidence = dot(surfaceNormal, lightDir);
	cosAngIncidence = clamp(cosAngIncidence, 0, 1);
	
	vec3 viewDirection = normalize(-clientEye);
	
	vec3 halfAngle = normalize(lightDir + viewDirection);
	float angleNormalHalf = acos(dot(halfAngle, surfaceNormal));
	float exponent = angleNormalHalf / clientMaterial.Shininess;
	exponent = -(exponent * exponent);
	float gaussianTerm = exp(exponent);
    
	gaussianTerm = cosAngIncidence != 0.0 ? gaussianTerm : 0.0;
    
    FragColor = (
                 ( vec4(ambient, 1.0f) +
                 (vec4(diffuse, 1) * attenIntensity * cosAngIncidence)
                 ) * texColor +
                 (vec4(specular, 1) * attenIntensity * gaussianTerm)
                 );
}




