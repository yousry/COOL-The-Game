#!BPY

"""
NAME: 'scene_info'
Blender: 260a
Group: 'Export'
Tooltip: '3D Model Binary utility classes'  
"""
import os
from math import degrees

class Object_Meta_Data:
    def __init__(self, name, rotation, translation, scalation):
        self.name = name
        self.rotation = (degrees(rotation[0]), degrees(rotation[1]) , degrees(rotation[2]))
        self.translation = translation
        self.scalation = scalation
        
    def __str__(self):

        nameNoDot = self.name.replace('.','_')
        nameNoCopy = os.path.splitext(self.name)[0]
        idName = nameNoDot + "Id"
        impName = nameNoDot + "Imp"
        result =  '\n'
        result += 'int '+idName+' = [world createImpersonator: @"'+ nameNoCopy +'"];\n'
        result += 'YAImpersonator* '+ impName +' = [world getImpersonator:'+idName+'];\n'
        result += '    [['+ impName +' rotation] setVector: [[YAVector3f alloc] initVals: '+ str(self.rotation[0] * -1.0 -90.0) +'f : '+ str(self.rotation[2]) +'f : '+ str(self.rotation[1]) +'f]];\n'
        result += '    [['+ impName +' translation] setVector: [[YAVector3f alloc] initVals: '+ str(self.translation[0]) +'f : '+ str(self.translation[2]) +'f : '+ str(self.translation[1]) +'f]];\n'
        result += '    [['+ impName +' size] setVector: [[YAVector3f alloc] initVals: '+ str(self.scalation[0]) +'f :'+ str(self.scalation[1]) +'f :'+ str(self.scalation[2]) +'f]];\n'       
        return result

