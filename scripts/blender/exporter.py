#!BPY

"""
NAME: '3D Model Binary Exporter'
Blender: 263
Group: 'Export'
Tooltip: '3D Model Binary Exporter'
"""
import os
from array import array
import bpy

import sys
sys.path.append('/home/yousry/Dokumente/source/helloGL/scripts/blender')
from transformer import VboTransformer, VboTransformerColor, MaterialTransformer, normalize, PRC
from scene_info import Object_Meta_Data
from math import sqrt
from math import pi
from mathutils import *

OUTPUT_DIRECTORY = '/home/yousry/Dokumente/source/helloGL/blender/'
FILENAME_SUFFIX = '.Y3D'
FILENAME_SHAPESHIFTER_SUFFIX = '.YSR'
FILENAME_KEYFRAMES_SUFFIX = '.YKS'
FILENAME_CONVEXHULL_SUFFIX = '.YCH'
FILENAME_WORLD_SETUP = 'world.m'
VERSION = 4

# TODO: 2.63 Replace faces with tessfaces

def calcTangent(face, faceuvs, vertices):

    v0 = vertices[face.vertices[0]].co
    v1 = vertices[face.vertices[1]].co
    v2 = vertices[face.vertices[2]].co

    v0uv = faceuvs[0]
    v1uv = faceuvs[1]
    v2uv = faceuvs[2]
    
    edge1 = v1 - v0
    edge2 = v2 - v0

    deltaU1 = v1uv[0] - v0uv[0]
    deltaV1 = v1uv[1] - v0uv[1]
    deltaU2 = v2uv[0] - v0uv[0]
    deltaV2 = v2uv[1] - v0uv[1]
    
    f = 1.0 / max(deltaU1 * deltaV2 - deltaU2 * deltaV1, 0.00001);   
    
    x = f * (deltaV2 * edge1.x - deltaV1 * edge2.x);
    y = f * (deltaV2 * edge1.y - deltaV1 * edge2.y);
    z = f * (deltaV2 * edge1.z - deltaV1 * edge2.z);

    r = Vector((x, y, z))
    return normalize(r)


def exportTextures(matSlot):
    print("Export Material: " + matSlot.name)
    mats = []
    texSlots = [matSlot.material.texture_slots[texSlotName] for texSlotName in matSlot.material.texture_slots.keys() if matSlot.material.texture_slots[texSlotName].texture.type == 'IMAGE']
    for texSlot in texSlots:
        influence = "normal" if texSlot.use_map_normal else "color"
        texture = texSlot.texture
        if getattr(texture.image, "source", "") == "FILE":
            mats.append(MaterialTransformer(influence, bpy.path.basename(texture.image.filepath)))
    return mats        

def buildDataBlockColor(vbis, vbos, o):
    print("buildDataBlockColor")
    o.data.calc_tessface()
    faces = o.data.tessfaces
    vertices = o.data.vertices
    facesMaterials = o.data.materials    
    
    print("Number of faces:", len(faces))
    for vbiIndex, face in enumerate(faces):
        faceColor = facesMaterials[face.material_index].diffuse_color
        vbi = (face.vertices[2], face.vertices[1], face.vertices[0])
        vbis.append(vbi)
        for verticeIndex in face.vertices:
            vertice = vertices[verticeIndex].co
            groups = vertices[verticeIndex].groups
            normal = vertices[verticeIndex].normal if face.use_smooth else face.normal
            if verticeIndex not in vbos:
                vbot = VboTransformerColor(vertice , faceColor, normal, vbiIndex, groups)
                vbos[verticeIndex] = vbot
            else:
                vbot = vbos[verticeIndex]
                vbot.setUpdate(faceColor, normal, vbiIndex, groups)


def buildDataBlockUV(vbis, vbos, o, doTangent):
    print("buildDataBlockUV")
    o.data.calc_tessface()
    faces = o.data.tessfaces
    vertices = o.data.vertices
    facesuvs = o.data.tessface_uv_textures.active.data
    
    for vbiIndex, face in enumerate(faces):
        faceuvs = facesuvs[vbiIndex].uv
        vbi = (face.vertices[2], face.vertices[1], face.vertices[0])
        vbis.append(vbi)
        tangent = calcTangent(face, faceuvs, vertices) if doTangent == True else Vector((0,1,0))

        for j, faceuv in enumerate(faceuvs):
            verticeIndex = face.vertices[j]
            vertice = vertices[verticeIndex].co
            groups = vertices[verticeIndex].groups
            normal = vertices[verticeIndex].normal if face.use_smooth else face.normal
            if face.use_smooth:
                tangent = normalize(vertice + tangent)
            if verticeIndex not in vbos:
                vbot = VboTransformer(vertice , faceuv, normal, vbiIndex, tangent, groups)
                vbos[verticeIndex] = vbot
            else:
                vbot = vbos[verticeIndex]
                vbot.setUpdate(faceuv, normal, vbiIndex, tangent, groups)
    


def createExport(expObj):
    'Create an Export of an object with a mesh'

    print("Start Processing: " + expObj.name)

    filename = OUTPUT_DIRECTORY + expObj.name + FILENAME_SUFFIX
    of = open(filename,'wb');
    header = array('b', [ord(e) for e in 'YA3D'])
    header.tofile(of)

    separator = array('b', [0])
    separator.tofile(of)

    versionHeader = array('b', [ord(e) for e in 'VERSION:'])
    versionHeader.tofile(of)
    
    version = array('I', [VERSION])
    version.tofile(of)
    
    textureName = None
    normalName = None

    materialTransformers = []    
    expMatSlots = expObj.material_slots
    for expMS in expMatSlots:
        materialTransformers.extend(exportTextures(expMS))
    
    isTexture = False;
    isNormal = False;
    
    for mt in materialTransformers:
        mt.ya3dEntry().tofile(of)
        separator.tofile(of)
        
        if mt.influence == "color":
            isTexture = True;
        elif mt.influence == "normal":
            isNormal = True;
      
    vbis = [] # array
    vbos = {} # dictionary  
      
    if isTexture == False and isNormal == False:
        formatString = 'FORMAT:vcnI' 
        buildDataBlockColor(vbis, vbos, expObj)
    elif isTexture == False and isNormal == True:
        formatString = 'FORMAT:vtnbI'
        buildDataBlockUV(vbis, vbos, expObj, True)
    elif isTexture == True and isNormal == False:
        formatString = 'FORMAT:vtnI'
        buildDataBlockUV(vbis, vbos, expObj, False)
    else:
        formatString = 'FORMAT:vtnbI'
        buildDataBlockUV(vbis, vbos, expObj, True)
    
            
    format = array('b', [ord(e) for e in formatString] ) 
    format.tofile(of)
    separator.tofile(of)     

###### cleanup vbos
    nextIndex = len(expObj.data.vertices)
    print("Cleanup: ", nextIndex)
    vbosClean = {} # dictionary
    for vboI in vbos:
        subVboFlats = vbos[vboI].flatten()
        for i, subVboFlat in enumerate(subVboFlats):
            if i == 0:
                vbosClean[vboI] = subVboFlat
            else:
                vbosClean[nextIndex] = subVboFlat
                noteVbis = subVboFlat.getRefVbis()
                for noteVbi in noteVbis:
                    oldVbi = vbis[noteVbi]
                    newVbiA = nextIndex if oldVbi[0] == vboI else oldVbi[0]
                    newVbiB = nextIndex if oldVbi[1] == vboI else oldVbi[1] 
                    newVbiC = nextIndex if oldVbi[2] == vboI else oldVbi[2]
                    vbis[noteVbi] = (newVbiA, newVbiB, newVbiC)
                nextIndex += 1
    

    dataHeader = array('b', [ord(e) for e in 'DATA:'])
    dataHeader.tofile(of)
    
    elemLen = 8
    if isTexture  == False and isNormal == False:
        elemLen += 1
    
    if isNormal == True:
        elemLen += 3

    vertSize = array('I', [len(vbosClean) * elemLen])
    vertSize.tofile(of)

    for vboClean in vbosClean:
        vertData = array('f', vbosClean[vboClean].toFloats()) if isNormal == False else array('f', vbosClean[vboClean].toFloatsNormal()) 
        vertData.tofile(of)        

    dataHeader.tofile(of)
    indSize = array('I', [len(vbis) * 3])
    indSize.tofile(of)

    for vbi in vbis:
        vbiData = array('I', [vbi[0], vbi[1], vbi[2]])
        vbiData.tofile(of)    
    
    of.close()

# create vertex groups and bones
    createShapeShifterData(expObj, vbosClean)
##  createKeyframeMesh(expObj)


##    for i, vboClean in enumerate(vbosClean):
##        groups = vbosClean[vboClean].groups
##        if len(groups) > 0:
##            for group in groups:
##                groupId = group.group
##                weight = group.weight
##                print( str(i) +": " + str(groupId) + " " + str(weight))



    print("File: " + filename + " created.")
    return Object_Meta_Data(expObj.name, expObj.rotation_euler, expObj.location, expObj.scale)

# create keyframe list
def createKeyframeList(expObj):
    print("Reading Keyframes")
    filename = OUTPUT_DIRECTORY + obj.name + FILENAME_KEYFRAMES_SUFFIX
    FILE = open(filename, "w")
    scene = bpy.context.scene
    once = []
    # TODO: find amature for obj
    armature = bpy.data.objects['Armature']
    action = armature.animation_data.action
    if action:
        print("Keyframes found")
        for fcurve in action.fcurves:
            title = fcurve.data_path.title()
            if title in once:
                print("skip")
            else:
                once.append(title) 
                FILE.write("// " + title + "\n")
                for kp in fcurve.keyframe_points:
                    FILE.write("// Frame: " + str(kp.co[0]) + "\n")
                    scene.frame_set(kp.co[0])
                    dp = fcurve.data_path
                    keyData = armature.path_resolve(dp)
                    FILE.write("[quat addObject: " + mapQuat(keyData) + "];\n")
    FILE.close()             
    

def createKeyframeMesh(expObj):
    print("Reading Keyframes")
    filename = OUTPUT_DIRECTORY + expObj.name + FILENAME_KEYFRAMES_SUFFIX
    FILE = open(filename, "w")
    scene = bpy.context.scene
    once = []
    action = expObj.animation_data.action
    if action:
        print("Keyframes found")
        for fcurve in action.fcurves:
            title = fcurve.data_path.title()
            if title in once:
                print("skip")
            else:
                once.append(title) 
                FILE.write("// " + title + "\n")
                for kp in fcurve.keyframe_points:
                    scene.frame_set(kp.co[0])
                    dp = fcurve.data_path
                    keyData = expObj.path_resolve(dp)

                    xRot = (keyData[0] * 180.0 / pi) * -1.0 -90
                    yRot = keyData[2] * 180.0 / pi
                    zRot = keyData[1] * 180.0 / pi  
                    FILE.write("[ipo addIpo:[[YAVector3f alloc] initVals:" + str(xRot) + "f :" + str(yRot) +"f : "+ str(zRot) +"f] timeFrame: " + str(kp.co[0] / 60)  + "f ];\n")
    FILE.close()             


def mapQuat(quat):
    return ("[[YAQuaternion alloc] initVals:" + '{0:f}'.format(quat.x) +" :" + '{0:f}'.format(-quat.z) +" :" + '{0:f}'.format(quat.y) +" :" + '{0:f}'.format(quat.w) +"]")

def createConvexHull(obj):
    filename = OUTPUT_DIRECTORY + obj.name + FILENAME_CONVEXHULL_SUFFIX
    FILE = open(filename, "w")
    FILE.write("{\n")
    FILE.write("  \"Y3D\": \""+ obj.name + "\",\n")
    FILE.write("  \"Vertices\": [")

    vertices = obj.data.vertices
    for i,vertice in enumerate(vertices):
        if i == 0:
            FILE.write("\n     ");
        elif i % 2 == 0:     
            FILE.write("\n   , ");
        else :
            FILE.write(", ");   

        vec = vertice.co
        FILE.write("{\"Vertice\":[% f, % f, % f]}" % (vec.x, -vec.y, vec.z))

    FILE.write("\n  ]\n}\n")
    FILE.close()
    print("File: " + filename + " created.")



    
# create ShapeSHifter Data in JSON Format    
def createShapeShifterData(obj, vbos):
    filename = OUTPUT_DIRECTORY + obj.name + FILENAME_SHAPESHIFTER_SUFFIX
    FILE = open(filename, "w")
    FILE.write("{\n")    
    FILE.write("  \"Y3D\": \""+ obj.name + "\",\n")
    FILE.write("  \"Shapers\": [\n")

    
    armatures = [modifier for modifier in obj.modifiers if modifier.type == "ARMATURE"]  
    if armatures:
        print("Armatures found, create shapeshifter") 
        # TODO: support multiple aramtures
        armature = armatures[0].object
        bones = armature.pose.bones

        for i,bone in enumerate(bones):
        
            if i != 0:
                FILE.write(",\n")

            parent = bone.parent
            location = bone.head * obj.matrix_world.inverted()
            if parent:
                parent_key = bones.keys().index(parent.name)
                #print("parent id:", parent_key )
            quaternion = bone.rotation_quaternion 
            object_matrix = bone.matrix * armature.data.bones[i].matrix_local.inverted()  
 
            FILE.write("    {\n")
            FILE.write("      \"Name\": \""+ bone.name + "\",\n")
            FILE.write("      \"Id\": %d,\n" % i)
            
            if parent:
                FILE.write("      \"Parent\": %d,\n" % parent_key)
            else:
                FILE.write("      \"Parent\": null,\n")
            
            FILE.write("      \"Joint\": [% f, % f, % f ],\n" %  (round(location.x, PRC), round(-location.y, PRC), round(location.z, PRC)))
            FILE.write("      \"Quaternion\": [% f, % f, % f, % f],\n" % (round(quaternion.x, PRC), round(-quaternion.z, PRC), round(quaternion.y, PRC), round(quaternion.w, PRC)))
            FILE.write("      \"Bone\": [% f, % f, % f, % f,\n" % (round(object_matrix[0][0], PRC),round(object_matrix[0][1], PRC),round(object_matrix[0][2], PRC),round(object_matrix[0][3], PRC)  )  ) 
            FILE.write("               % f, % f, % f, % f,\n" % (round(object_matrix[1][0], PRC),round(object_matrix[1][1], PRC),round(object_matrix[1][2], PRC),round(object_matrix[1][3], PRC)  )  ) 
            FILE.write("               % f, % f, % f, % f,\n" % (round(object_matrix[2][0], PRC),round(object_matrix[2][1], PRC),round(object_matrix[2][2], PRC),round(object_matrix[2][3], PRC)  )  ) 
            FILE.write("               % f, % f, % f, % f\n" % (round(object_matrix[3][0], PRC),round(object_matrix[3][1], PRC),round(object_matrix[3][2], PRC),round(object_matrix[3][3], PRC)  )  ) 
            FILE.write("      ]\n") 

    
            FILE.write("    }")
            
    FILE.write("\n  ],\n")
    
    FILE.write("  \"Influences\": [")
    
    for i, vbo in enumerate(vbos):

        
        groups = vbos[vbo].groups
        if len(groups) > 0:
            if i > 0:
                FILE.write(", ")
            if i % 2 == 0:   
                FILE.write("\n    ")
            FILE.write("{ \"Vertice\": %d, \"Bones\": [" % i)
            groupWeight = sum(g.weight for g in groups)
            for j, group in enumerate(groups):
                groupId = group.group
                weight = group.weight
                if j > 0:
                    FILE.write(",")
                FILE.write("{\"Bone\": %d, \"Blend\": %f}" % (groupId, weight/groupWeight))
            FILE.write("] }")


    FILE.write("\n  ]\n")
    FILE.write("}\n")        
    FILE.close()
    print("File: " + filename + " created.")

print('--- Start ---')

metadatas = []

# Iterate over all objects in the blender scene
# If an object is a Mesh then it is exported.
for obj in bpy.data.objects:
    if obj.type == 'MESH': 
        metadatas.append(createExport(obj))
        createConvexHull(obj)

FILE = open(OUTPUT_DIRECTORY + FILENAME_WORLD_SETUP, "w")
for metadata in metadatas:
    FILE.write("\n" + str(metadata))
FILE.close()

print ('--- END ---')
