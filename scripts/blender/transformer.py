#!BPY

"""
NAME: 'transformer'
Blender: 260a
Group: 'Export'
Tooltip: '3D Model Binary utility classes'
"""

from array import array
from mathutils import *
from math import sqrt

# used float precision
PRC = 5

def normalize(v):
    x = v.x
    y = v.y
    z = v.z

    length = sqrt(x * x + y * y + z * z);

    if length != 0:
        x /= length;
        y /= length;
        z /= length; 
    
    return Vector((x, y, z))

def compare2F(a,b):
    return round(a[0],PRC) == round(b[0],PRC) and round(a[1], PRC) == round(b[1], PRC)

def compare3F(a,b):
    return round(a[0],PRC) == round(b[0],PRC) and round(a[1], PRC) == round(b[1], PRC) and round(a[2], PRC) == round(b[2], PRC)

def compare4F(a,b):
    return round(a[0],PRC) == round(b[0],PRC) and round(a[1], PRC) == round(b[1], PRC) and round(a[2], PRC) == round(b[2], PRC) and round(a[3], PRC) == round(b[3], PRC)

class MaterialTransformer:
    'Structure for material transformation'
    
    def __init__(self, influence, imageName):
        self.influence = influence
        self.imageName = imageName

    def ya3dEntry(self):
        headerString = "NORMAL:" if self.influence == 'normal' else "TEXTURE:"
        return array('b', [ord(e) for e in headerString + self.imageName])

class VboTransformer:
    'Structure for VBO Transformation'

    def __init__(self, vertice, uvPos, normal, vbi, tangent, groups):
        self.vertice = vertice
        self.uvPos = uvPos
        self.normal = normal
        self.vbis = [vbi]
        self.tangent = tangent
        self.groups = groups
        self.sibling = None
    
    def toFloatsNormal(self):
        return [round(self.vertice.x,PRC), round(-self.vertice.y,PRC), round(self.vertice.z,PRC), 
        self.uvPos[0], self.uvPos[1], 
        round(self.normal.x,PRC), round(-self.normal.y,PRC), round(self.normal.z,PRC), 
        round(self.tangent.x,PRC), round(-self.tangent.y,PRC), round(self.tangent.z,PRC)]
    
    def toFloats(self):
        return [round(self.vertice.x,PRC), round(-self.vertice.y,PRC),  round(self.vertice.z,PRC), 
        self.uvPos[0], self.uvPos[1], 
        round(self.normal.x,PRC), round(-self.normal.y,PRC), round(self.normal.z,PRC)]
    
    def getRefVbis(self):
        return self.vbis
    
    def setUpdate(self, uvPos, normal, vbi, tangent, groups):

        isEqual = compare2F(self.uvPos, uvPos) and compare3F(self.normal, normal) and compare3F(self.tangent, tangent)
        
        if isEqual:    
            self.vbis.append(vbi)
        else: 
            if(self.sibling == None):
                self.sibling = VboTransformer(self.vertice , uvPos, normal, vbi, tangent, groups)
            else:    
                self.sibling.setUpdate(uvPos, normal, vbi, tangent, groups)
                
    def flatten(self):
        if self.sibling == None:
            return [self]
        else:
            return [self] + self.sibling.flatten()
                

class VboTransformerColor:
    'Structure for VBO Transformation without textures'

    def __init__(self, vertice, color, normal, vbi, groups):
        self.vertice = vertice
        self.color = color
        self.normal = normal
        self.vbis = [vbi]
        self.groups = groups
        self.sibling = None

    def toFloats(self):
        return [round(self.vertice.x,PRC), -round(self.vertice.y,PRC), round(self.vertice.z,PRC), 
        self.color[0],  self.color[1], self.color[2], 
        round(self.normal.x,PRC), -round(self.normal.y,PRC), round(self.normal.z,PRC)]
    
    def getRefVbis(self):
        return self.vbis
    
    def setUpdate(self, color, normal, vbi, groups):
        isEqual = compare3F(self.color, color) and compare3F(self.normal, normal)
        if isEqual:    
            self.vbis.append(vbi)
        else: 
            if(self.sibling == None):
                self.sibling = VboTransformerColor(self.vertice , color, normal, vbi, groups)
            else:    
                self.sibling.setUpdate(color, normal, vbi, groups)
                
    def flatten(self):
        if self.sibling == None:
            return [self]
        else:
            return [self] + self.sibling.flatten()




