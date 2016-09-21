#version 150
#extension GL_ARB_explicit_attrib_location : enable

// gourad vertex shader

layout (location = 0) in vec3 clientPosition;
layout (location = 1) in vec3 clientNormal;
layout (location = 2) in vec2 clientTexture;  

//out vec3 vsPosition;
//out vec3 vsNormal;
//out vec2 vsTextureCoord;

out vec3 gsPosition;
out vec3 gsNormal;
out vec2 gsTextureCoord;


uniform mat4 clientModel;
uniform samplerBuffer clientShapeShifter;
uniform mat4 clientMVP;

vec3 rotateQuat( vec4 q, vec3 v ){ 
	return v + 2.0 * cross(q.xyz, cross(q.xyz ,v) + q.w*v); 
} 


void main()
{
    vec3 workPosition = vec3(0,0,0);
    vec3 workNormal = vec3(0,0,0);

    int vsId = gl_VertexID;
    int descriptionPosition = int(texelFetch(clientShapeShifter, vsId * 2 ).r);
    int descriptionLength   = int(texelFetch(clientShapeShifter, vsId * 2 + 1 ).r);

    vec3 loc = vec3(0,0,0);
    vec3 target = vec3(0,0,0);
    vec4 quat = vec4(0, 0, 0, 0); 

    
    for(int i = 0; i < descriptionLength; i++ ) {

        int jointAdress = int(texelFetch(clientShapeShifter, descriptionPosition + (i * 2)).r); 
        float jointBlend = texelFetch(clientShapeShifter, descriptionPosition + (i * 2) + 1).r; 
        
        loc.x = texelFetch(clientShapeShifter, jointAdress).r;
        loc.y = texelFetch(clientShapeShifter, jointAdress + 1).r;
        loc.z = texelFetch(clientShapeShifter, jointAdress + 2).r;
        
        quat.x = texelFetch(clientShapeShifter, jointAdress + 3).r;
        quat.y = texelFetch(clientShapeShifter, jointAdress + 4).r;
        quat.z = texelFetch(clientShapeShifter, jointAdress + 5).r;
        quat.w = texelFetch(clientShapeShifter, jointAdress + 6).r;
        
        target.x = texelFetch(clientShapeShifter, jointAdress + 7).r;
        target.y = texelFetch(clientShapeShifter, jointAdress + 8).r;
        target.z = texelFetch(clientShapeShifter, jointAdress + 9).r;

        vec3 operatePos = clientPosition - loc;
        operatePos = rotateQuat(quat,operatePos);
        operatePos = (operatePos + target ) * jointBlend; 
        
        workPosition += operatePos; 
        workNormal += rotateQuat(quat,clientNormal) * jointBlend;
    }    

    gsTextureCoord = clientTexture;
    gsNormal = normalize((clientModel * vec4(workNormal, 0.0)).xyz);
    gsPosition = (clientModel * vec4(workPosition, 1.0)).xyz;
    
    
//    vsTextureCoord = clientTexture;
//    vsNormal = normalize((clientModel * vec4(workNormal, 0.0)).xyz);
//    vsPosition = (clientModel * vec4(workPosition, 1.0)).xyz;
    gl_Position = clientMVP * vec4(workPosition, 1.0);
}
