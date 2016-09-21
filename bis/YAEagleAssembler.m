//
//  YAEagleAssembler.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 18.09.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//


#import "YAMaterial.h"
#import "YAImpersonator.h"
#import "YAVector3f.h"
#import "YARenderLoop.h"
#import "YAImpGroup.h"

#import "YAEagleAssembler.h"

@implementation YAEagleAssembler

+(void) buildEagle: (YARenderLoop*)world Group: (YAImpGroup*) group
{
    
    
    int EagleBodyId = [world createImpersonator: @"EagleBody"];
    YAImpersonator* EagleBodyImp = [world getImpersonator:EagleBodyId];
    [[EagleBodyImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EagleBodyImp translation] setVector: [[YAVector3f alloc] initVals: 0.0007933215238153934f : 0.06792360544204712f : -0.15644624829292297f]];
    [[EagleBodyImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleBody_001Id = [world createImpersonator: @"EagleBody"];
    YAImpersonator* EagleBody_001Imp = [world getImpersonator:EagleBody_001Id];
    [[EagleBody_001Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EagleBody_001Imp translation] setVector: [[YAVector3f alloc] initVals: 0.0007933215238153934f : 0.06792360544204712f : 0.15660196542739868f]];
    [[EagleBody_001Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleCockpitId = [world createImpersonator: @"EagleCockpit"];
    YAImpersonator* EagleCockpitImp = [world getImpersonator:EagleCockpitId];
    [[EagleCockpitImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EagleCockpitImp translation] setVector: [[YAVector3f alloc] initVals: -5.70579431951046e-05f : 0.07033151388168335f : -0.24832740426063538f]];
    [[EagleCockpitImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleCradleId = [world createImpersonator: @"EagleCradle"];
    YAImpersonator* EagleCradleImp = [world getImpersonator:EagleCradleId];
    [[EagleCradleImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EagleCradleImp translation] setVector: [[YAVector3f alloc] initVals: 0.001809454057365656f : 0.10872501134872437f : -0.1339939534664154f]];
    [[EagleCradleImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleEngineId = [world createImpersonator: @"EagleEngine"];
    YAImpersonator* EagleEngineImp = [world getImpersonator:EagleEngineId];
    [[EagleEngineImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EagleEngineImp translation] setVector: [[YAVector3f alloc] initVals: -0.04153060540556908f : 0.07029050588607788f : 0.2922113835811615f]];
    [[EagleEngineImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleEngine_001Id = [world createImpersonator: @"EagleEngine"];
    YAImpersonator* EagleEngine_001Imp = [world getImpersonator:EagleEngine_001Id];
    [[EagleEngine_001Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EagleEngine_001Imp translation] setVector: [[YAVector3f alloc] initVals: 0.04359877482056618f : 0.07029050588607788f : 0.2922113835811615f]];
    [[EagleEngine_001Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleEngine_002Id = [world createImpersonator: @"EagleEngine"];
    YAImpersonator* EagleEngine_002Imp = [world getImpersonator:EagleEngine_002Id];
    [[EagleEngine_002Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EagleEngine_002Imp translation] setVector: [[YAVector3f alloc] initVals: 3.6625657230615616e-05f : 0.09469848871231079f : 0.2922113835811615f]];
    [[EagleEngine_002Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleEngine_003Id = [world createImpersonator: @"EagleEngine"];
    YAImpersonator* EagleEngine_003Imp = [world getImpersonator:EagleEngine_003Id];
    [[EagleEngine_003Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EagleEngine_003Imp translation] setVector: [[YAVector3f alloc] initVals: 3.6625657230615616e-05f : 0.04562002792954445f : 0.2922113835811615f]];
    [[EagleEngine_003Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleEngineShieldId = [world createImpersonator: @"EagleEngineShield"];
    YAImpersonator* EagleEngineShieldImp = [world getImpersonator:EagleEngineShieldId];
    [[EagleEngineShieldImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EagleEngineShieldImp translation] setVector: [[YAVector3f alloc] initVals: -5.342205986380577e-05f : 0.06983739137649536f : 0.25435373187065125f]];
    [[EagleEngineShieldImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleFuleTankId = [world createImpersonator: @"EagleFuleTank"];
    YAImpersonator* EagleFuleTankImp = [world getImpersonator:EagleFuleTankId];
    [[EagleFuleTankImp rotation] setVector: [[YAVector3f alloc] initVals: -90.00000006658502f : -1.0146935304714285e-06f : -0.0f]];
    [[EagleFuleTankImp translation] setVector: [[YAVector3f alloc] initVals: 0.024866696447134018f : 0.09489172697067261f : 0.2282523810863495f]];
    [[EagleFuleTankImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleFuleTank_001Id = [world createImpersonator: @"EagleFuleTank"];
    YAImpersonator* EagleFuleTank_001Imp = [world getImpersonator:EagleFuleTank_001Id];
    [[EagleFuleTank_001Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.00000006658502f : -1.0146935304714285e-06f : -0.0f]];
    [[EagleFuleTank_001Imp translation] setVector: [[YAVector3f alloc] initVals: -0.024389561265707016f : 0.09489172697067261f : 0.2282523810863495f]];
    [[EagleFuleTank_001Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleFuleTank_002Id = [world createImpersonator: @"EagleFuleTank"];
    YAImpersonator* EagleFuleTank_002Imp = [world getImpersonator:EagleFuleTank_002Id];
    [[EagleFuleTank_002Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.00000006658502f : -1.0146935304714285e-06f : -0.0f]];
    [[EagleFuleTank_002Imp translation] setVector: [[YAVector3f alloc] initVals: 0.024866696447134018f : 0.046032194048166275f : 0.2282523810863495f]];
    [[EagleFuleTank_002Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleFuleTank_003Id = [world createImpersonator: @"EagleFuleTank"];
    YAImpersonator* EagleFuleTank_003Imp = [world getImpersonator:EagleFuleTank_003Id];
    [[EagleFuleTank_003Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.00000006658502f : -1.0146935304714285e-06f : -0.0f]];
    [[EagleFuleTank_003Imp translation] setVector: [[YAVector3f alloc] initVals: -0.024346664547920227f : 0.04589817300438881f : 0.2282523810863495f]];
    [[EagleFuleTank_003Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleLegId = [world createImpersonator: @"EagleLeg"];
    YAImpersonator* EagleLegImp = [world getImpersonator:EagleLegId];
    [[EagleLegImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EagleLegImp translation] setVector: [[YAVector3f alloc] initVals: 0.08084478974342346f : 0.003795810043811798f : -0.15419349074363708f]];
    [[EagleLegImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleLeg_001Id = [world createImpersonator: @"EagleLeg"];
    YAImpersonator* EagleLeg_001Imp = [world getImpersonator:EagleLeg_001Id];
    [[EagleLeg_001Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EagleLeg_001Imp translation] setVector: [[YAVector3f alloc] initVals: -0.08066496253013611f : 0.003795810043811798f : -0.15419349074363708f]];
    [[EagleLeg_001Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleLeg_002Id = [world createImpersonator: @"EagleLeg"];
    YAImpersonator* EagleLeg_002Imp = [world getImpersonator:EagleLeg_002Id];
    [[EagleLeg_002Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EagleLeg_002Imp translation] setVector: [[YAVector3f alloc] initVals: 0.08086517453193665f : 0.003795810043811798f : 0.15304270386695862f]];
    [[EagleLeg_002Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleLeg_003Id = [world createImpersonator: @"EagleLeg"];
    YAImpersonator* EagleLeg_003Imp = [world getImpersonator:EagleLeg_003Id];
    [[EagleLeg_003Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EagleLeg_003Imp translation] setVector: [[YAVector3f alloc] initVals: -0.07999348640441895f : 0.003795810043811798f : 0.15304270386695862f]];
    [[EagleLeg_003Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EaglePodId = [world createImpersonator: @"EaglePod"];
    YAImpersonator* EaglePodImp = [world getImpersonator:EaglePodId];
    [[EaglePodImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EaglePodImp translation] setVector: [[YAVector3f alloc] initVals: 0.0008520470000803471f : 0.06463819742202759f : -0.00013663619756698608f]];
    [[EaglePodImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleStartEngineId = [world createImpersonator: @"EagleStartEngine"];
    YAImpersonator* EagleStartEngineImp = [world getImpersonator:EagleStartEngineId];
    [[EagleStartEngineImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EagleStartEngineImp translation] setVector: [[YAVector3f alloc] initVals: -0.014644354581832886f : 0.02498561516404152f : -0.17364010214805603f]];
    [[EagleStartEngineImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleStartEngine_001Id = [world createImpersonator: @"EagleStartEngine"];
    YAImpersonator* EagleStartEngine_001Imp = [world getImpersonator:EagleStartEngine_001Id];
    [[EagleStartEngine_001Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EagleStartEngine_001Imp translation] setVector: [[YAVector3f alloc] initVals: 0.014952495694160461f : 0.02498561516404152f : -0.17364010214805603f]];
    [[EagleStartEngine_001Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleStartEngine_002Id = [world createImpersonator: @"EagleStartEngine"];
    YAImpersonator* EagleStartEngine_002Imp = [world getImpersonator:EagleStartEngine_002Id];
    [[EagleStartEngine_002Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EagleStartEngine_002Imp translation] setVector: [[YAVector3f alloc] initVals: 0.014952495694160461f : 0.02498561516404152f : 0.18176349997520447f]];
    [[EagleStartEngine_002Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleStartEngine_003Id = [world createImpersonator: @"EagleStartEngine"];
    YAImpersonator* EagleStartEngine_003Imp = [world getImpersonator:EagleStartEngine_003Id];
    [[EagleStartEngine_003Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EagleStartEngine_003Imp translation] setVector: [[YAVector3f alloc] initVals: -0.014644354581832886f : 0.02498561516404152f : 0.18176349997520447f]];
    [[EagleStartEngine_003Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleUpperLegLId = [world createImpersonator: @"EagleUpperLegL"];
    YAImpersonator* EagleUpperLegLImp = [world getImpersonator:EagleUpperLegLId];
    [[EagleUpperLegLImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EagleUpperLegLImp translation] setVector: [[YAVector3f alloc] initVals: 0.10171684622764587f : 0.04769820347428322f : -0.15424194931983948f]];
    [[EagleUpperLegLImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleUpperLegL_001Id = [world createImpersonator: @"EagleUpperLegL"];
    YAImpersonator* EagleUpperLegL_001Imp = [world getImpersonator:EagleUpperLegL_001Id];
    [[EagleUpperLegL_001Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EagleUpperLegL_001Imp translation] setVector: [[YAVector3f alloc] initVals: 0.10171684622764587f : 0.04769820347428322f : 0.1532064974308014f]];
    [[EagleUpperLegL_001Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleUpperLegRId = [world createImpersonator: @"EagleUpperLegR"];
    YAImpersonator* EagleUpperLegRImp = [world getImpersonator:EagleUpperLegRId];
    [[EagleUpperLegRImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EagleUpperLegRImp translation] setVector: [[YAVector3f alloc] initVals: -0.10156768560409546f : 0.04770714417099953f : -0.15397706627845764f]];
    [[EagleUpperLegRImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int EagleUpperLegR_001Id = [world createImpersonator: @"EagleUpperLegR"];
    YAImpersonator* EagleUpperLegR_001Imp = [world getImpersonator:EagleUpperLegR_001Id];
    [[EagleUpperLegR_001Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[EagleUpperLegR_001Imp translation] setVector: [[YAVector3f alloc] initVals: -0.10156768560409546f : 0.04770714417099953f : 0.1532944142818451f]];
    [[EagleUpperLegR_001Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];

    
    int thrustId = [world createImpersonator: @"thrust"];
    YAImpersonator* thrustImp = [world getImpersonator:thrustId];
    [[thrustImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[thrustImp translation] setVector: [[YAVector3f alloc] initVals: 0.00011634675320237875f : 0.09467752277851105f : 0.3208160698413849f]];
    [[thrustImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int thrust_001Id = [world createImpersonator: @"thrust"];
    YAImpersonator* thrust_001Imp = [world getImpersonator:thrust_001Id];
    [[thrust_001Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[thrust_001Imp translation] setVector: [[YAVector3f alloc] initVals: 0.00011634675320237875f : 0.04554181545972824f : 0.3208160698413849f]];
    [[thrust_001Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int thrust_002Id = [world createImpersonator: @"thrust"];
    YAImpersonator* thrust_002Imp = [world getImpersonator:thrust_002Id];
    [[thrust_002Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[thrust_002Imp translation] setVector: [[YAVector3f alloc] initVals: -0.041410621255636215f : 0.07029299437999725f : 0.3208160698413849f]];
    [[thrust_002Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int thrust_003Id = [world createImpersonator: @"thrust"];
    YAImpersonator* thrust_003Imp = [world getImpersonator:thrust_003Id];
    [[thrust_003Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[thrust_003Imp translation] setVector: [[YAVector3f alloc] initVals: 0.04371868446469307f : 0.07029299437999725f : 0.3208160698413849f]];
    [[thrust_003Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];

    
    // ------------------------------
    
    YAVector3f *ambientColor = [[YAVector3f alloc] initVals:0.3 :0.3 :0.3];
    YAVector3f *diffuseColor = [[YAVector3f alloc] initVals:0.2 :0.2 :0.2];
    YAVector3f *specularColor = [[YAVector3f alloc] initVals:0.1 :0.1 :0.1];

//    YAVector3f *ambientColorB = [[YAVector3f alloc] initVals:0.1 :0.1 :0.1];
//    YAVector3f *diffuseColorB = [[YAVector3f alloc] initVals:0.1 :0.1 :0.1];
//    YAVector3f *specularColorB = [[YAVector3f alloc] initVals:0.05 :0.05 :0.05];
    
    YAVector3f *ambientColorB = ambientColor;
    YAVector3f *diffuseColorB = diffuseColor;
    YAVector3f *specularColorB = specularColor;

    
    [[[EagleBodyImp material] phongAmbientReflectivity] setVector:ambientColor];
    [[[EagleBody_001Imp material] phongAmbientReflectivity] setVector:ambientColor];
    [[[EagleCockpitImp material] phongAmbientReflectivity] setVector:ambientColor];
    [[[EagleCradleImp material] phongAmbientReflectivity] setVector:ambientColorB];
    [[[EagleEngineImp material] phongAmbientReflectivity] setVector:ambientColor];
    [[[EagleEngine_001Imp material] phongAmbientReflectivity] setVector:ambientColor];
    [[[EagleEngine_002Imp material] phongAmbientReflectivity] setVector:ambientColor];
    [[[EagleEngine_003Imp material] phongAmbientReflectivity] setVector:ambientColor];
    [[[EagleEngineShieldImp material] phongAmbientReflectivity] setVector:ambientColor];
    [[[EagleFuleTankImp material] phongAmbientReflectivity] setVector:ambientColor];
    [[[EagleFuleTank_001Imp material] phongAmbientReflectivity] setVector:ambientColor];
    [[[EagleFuleTank_002Imp material] phongAmbientReflectivity] setVector:ambientColor];
    [[[EagleFuleTank_003Imp material] phongAmbientReflectivity] setVector:ambientColor];
    [[[EagleLegImp material] phongAmbientReflectivity] setVector:ambientColorB];
    [[[EagleLeg_001Imp material] phongAmbientReflectivity] setVector:ambientColorB];
    [[[EagleLeg_002Imp material] phongAmbientReflectivity] setVector:ambientColorB];
    [[[EagleLeg_003Imp material] phongAmbientReflectivity] setVector:ambientColorB];
    [[[EaglePodImp material] phongAmbientReflectivity] setVector:ambientColor];
    [[[EagleStartEngineImp material] phongAmbientReflectivity] setVector:ambientColor];
    [[[EagleStartEngine_001Imp material] phongAmbientReflectivity] setVector:ambientColor];
    [[[EagleStartEngine_002Imp material] phongAmbientReflectivity] setVector:ambientColor];
    [[[EagleStartEngine_003Imp material] phongAmbientReflectivity] setVector:ambientColor];
    [[[EagleUpperLegRImp material] phongAmbientReflectivity] setVector:ambientColor];
    [[[EagleUpperLegLImp material] phongAmbientReflectivity]  setVector:ambientColor];
    [[[EagleUpperLegR_001Imp material] phongAmbientReflectivity] setVector:ambientColor];
    [[[EagleUpperLegL_001Imp material] phongAmbientReflectivity]  setVector:ambientColor];

    
    [[[EagleBodyImp material] phongDiffuseReflectivity] setVector:diffuseColor];
    [[[EagleBody_001Imp material] phongDiffuseReflectivity] setVector:diffuseColor];
    [[[EagleCockpitImp material] phongDiffuseReflectivity] setVector:diffuseColor];
    [[[EagleCradleImp material] phongDiffuseReflectivity] setVector:diffuseColorB];
    [[[EagleEngineImp material] phongDiffuseReflectivity] setVector:diffuseColor];
    [[[EagleEngine_001Imp material] phongDiffuseReflectivity] setVector:diffuseColor];
    [[[EagleEngine_002Imp material] phongDiffuseReflectivity] setVector:diffuseColor];
    [[[EagleEngine_003Imp material] phongDiffuseReflectivity] setVector:diffuseColor];
    [[[EagleEngineShieldImp material] phongDiffuseReflectivity] setVector:diffuseColor];
    [[[EagleFuleTankImp material] phongDiffuseReflectivity] setVector:diffuseColor];
    [[[EagleFuleTank_001Imp material] phongDiffuseReflectivity] setVector:diffuseColor];
    [[[EagleFuleTank_002Imp material] phongDiffuseReflectivity] setVector:diffuseColor];
    [[[EagleFuleTank_003Imp material] phongDiffuseReflectivity] setVector:diffuseColor];
    [[[EagleLegImp material] phongDiffuseReflectivity] setVector:diffuseColorB];
    [[[EagleLeg_001Imp material] phongDiffuseReflectivity] setVector:diffuseColorB];
    [[[EagleLeg_002Imp material] phongDiffuseReflectivity] setVector:diffuseColorB];
    [[[EagleLeg_003Imp material] phongDiffuseReflectivity] setVector:diffuseColorB];
    [[[EaglePodImp material] phongDiffuseReflectivity] setVector:diffuseColor];
    [[[EagleStartEngineImp material] phongDiffuseReflectivity] setVector:diffuseColor];
    [[[EagleStartEngine_001Imp material] phongDiffuseReflectivity] setVector:diffuseColor];
    [[[EagleStartEngine_002Imp material] phongDiffuseReflectivity] setVector:diffuseColor];
    [[[EagleStartEngine_003Imp material] phongDiffuseReflectivity] setVector:diffuseColor];
    [[[EagleUpperLegRImp material] phongDiffuseReflectivity] setVector:diffuseColor];
    [[[EagleUpperLegLImp material] phongDiffuseReflectivity]  setVector:diffuseColor];
    [[[EagleUpperLegR_001Imp material] phongDiffuseReflectivity] setVector:diffuseColor];
    [[[EagleUpperLegL_001Imp material] phongDiffuseReflectivity]  setVector:diffuseColor];

    [[[EagleBodyImp material] phongSpecularReflectivity] setVector:specularColor];
    [[[EagleBody_001Imp material] phongSpecularReflectivity] setVector:specularColor];
    [[[EagleCockpitImp material] phongSpecularReflectivity] setVector:specularColor];
    [[[EagleCradleImp material] phongSpecularReflectivity] setVector:specularColorB];
    [[[EagleEngineImp material] phongSpecularReflectivity] setVector:specularColor];
    [[[EagleEngine_001Imp material] phongSpecularReflectivity] setVector:specularColor];
    [[[EagleEngine_002Imp material] phongSpecularReflectivity] setVector:specularColor];
    [[[EagleEngine_003Imp material] phongSpecularReflectivity] setVector:specularColor];
    [[[EagleEngineShieldImp material] phongSpecularReflectivity] setVector:specularColor];
    [[[EagleFuleTankImp material] phongSpecularReflectivity] setVector:specularColor];
    [[[EagleFuleTank_001Imp material] phongSpecularReflectivity] setVector:specularColor];
    [[[EagleFuleTank_002Imp material] phongSpecularReflectivity] setVector:specularColor];
    [[[EagleFuleTank_003Imp material] phongSpecularReflectivity] setVector:specularColor];
    [[[EagleLegImp material] phongSpecularReflectivity] setVector:specularColorB];
    [[[EagleLeg_001Imp material] phongSpecularReflectivity] setVector:specularColorB];
    [[[EagleLeg_002Imp material] phongSpecularReflectivity] setVector:specularColorB];
    [[[EagleLeg_003Imp material] phongSpecularReflectivity] setVector:specularColorB];
    [[[EaglePodImp material] phongSpecularReflectivity] setVector:specularColor];
    [[[EagleStartEngineImp material] phongSpecularReflectivity] setVector:specularColor];
    [[[EagleStartEngine_001Imp material] phongSpecularReflectivity] setVector:specularColor];
    [[[EagleStartEngine_002Imp material] phongSpecularReflectivity] setVector:specularColor];
    [[[EagleStartEngine_003Imp material] phongSpecularReflectivity] setVector:specularColor];
    [[[EagleUpperLegRImp material] phongSpecularReflectivity] setVector:specularColor];
    [[[EagleUpperLegLImp material] phongSpecularReflectivity]  setVector:specularColor];
    [[[EagleUpperLegR_001Imp material] phongSpecularReflectivity] setVector:specularColor];
    [[[EagleUpperLegL_001Imp material] phongSpecularReflectivity]  setVector:specularColor];
    
    
    [[[thrustImp material] phongAmbientReflectivity] setValues:1 :0 :0];
    [[[thrustImp material] phongDiffuseReflectivity] setValues:1 :1 :0];
    [[[thrustImp material] phongSpecularReflectivity] setValues:1 :1 :1];
    [[thrustImp material] setEta:1.0];
    [[thrustImp material] setPhongShininess:0];
    [thrustImp setShadowCaster:false];


    [[[thrust_001Imp material] phongAmbientReflectivity] setValues:1 :0 :0];
    [[[thrust_001Imp material] phongDiffuseReflectivity] setValues:1 :1 :0];
    [[[thrust_001Imp material] phongSpecularReflectivity] setValues:1 :1 :1];
    [[thrust_001Imp material] setEta:1.0];
    [[thrust_001Imp material] setPhongShininess:0.25];
    [thrust_001Imp setShadowCaster:false];



    [[[thrust_002Imp material] phongAmbientReflectivity] setValues:1 :0 :0];
    [[[thrust_002Imp material] phongDiffuseReflectivity] setValues:1 :1 :0];
    [[[thrust_002Imp material] phongSpecularReflectivity] setValues:1 :1 :1];
    [[thrust_002Imp material] setEta:1.0];
    [[thrust_002Imp material] setPhongShininess:0.50];
    [thrust_002Imp setShadowCaster:false];


    [[[thrust_003Imp material] phongAmbientReflectivity] setValues:1 :0 :0];
    [[[thrust_003Imp material] phongDiffuseReflectivity] setValues:1 :1 :0];
    [[[thrust_003Imp material] phongSpecularReflectivity] setValues:1 :1 :1];
    [[thrust_003Imp material] setEta:1.0];
    [[thrust_003Imp material] setPhongShininess:2];
    [thrust_003Imp setShadowCaster:false];
    
    
    [EagleBodyImp setShadowCaster:true];
    [EagleBody_001Imp setShadowCaster:true];
    [EagleCockpitImp setShadowCaster:true];
    [EagleCradleImp setShadowCaster:false];
    [EagleEngineImp setShadowCaster:false];
    [EagleEngine_001Imp setShadowCaster:false];
    [EagleEngine_002Imp setShadowCaster:false];
    [EagleEngine_003Imp setShadowCaster:false];
    [EagleEngineShieldImp setShadowCaster:false];
    [EagleFuleTankImp setShadowCaster:false];
    [EagleFuleTank_001Imp setShadowCaster:false];
    [EagleFuleTank_002Imp setShadowCaster:false];
    [EagleFuleTank_003Imp setShadowCaster:false];
    [EagleLegImp setShadowCaster:false];
    [EagleLeg_001Imp setShadowCaster:false];
    [EagleLeg_002Imp setShadowCaster:false];
    [EagleLeg_003Imp setShadowCaster:false];
    [EaglePodImp setShadowCaster:true];
    [EagleStartEngineImp setShadowCaster:false];
    [EagleStartEngine_001Imp setShadowCaster:false];
    [EagleStartEngine_002Imp setShadowCaster:false];
    [EagleStartEngine_003Imp setShadowCaster:false];

    
    [EagleEngineImp setBackfaceCulling:false];
    [EagleEngine_001Imp setBackfaceCulling:false];
    [EagleEngine_002Imp setBackfaceCulling:false];
    [EagleEngine_003Imp setBackfaceCulling:false];
    
    [EagleStartEngineImp setBackfaceCulling:false];
    [EagleStartEngine_001Imp setBackfaceCulling:false];
    [EagleStartEngine_002Imp setBackfaceCulling:false];
    [EagleStartEngine_003Imp setBackfaceCulling:false];
    
    EagleCradleImp.material.eta = 1.0;
    EagleFuleTankImp.material.eta = 1.0f;
    EagleFuleTank_001Imp.material.eta = 1.0f;
    EagleFuleTank_002Imp.material.eta = 1.0f;
    EagleFuleTank_003Imp.material.eta = 1.0f;

    EagleLegImp.material.eta = 1.0;
    EagleLeg_001Imp.material.eta = 1.0;
    EagleLeg_002Imp.material.eta = 1.0;
    EagleLeg_003Imp.material.eta = 1.0;

    EagleStartEngineImp.material.eta = 1.0;
    EagleStartEngine_001Imp.material.eta = 1.0;
    EagleStartEngine_002Imp.material.eta = 1.0;
    EagleStartEngine_003Imp.material.eta = 1.0;

    [group addImp:EagleBodyImp];
    [group addImp:EagleBody_001Imp];
    [group addImp:EagleCockpitImp];
    [group addImp:EagleCradleImp];
    [group addImp:EagleEngineImp];
    [group addImp:EagleEngine_001Imp];
    [group addImp:EagleEngine_002Imp];
    [group addImp:EagleEngine_003Imp];
    [group addImp:EagleEngineShieldImp];
    [group addImp:EagleFuleTankImp];
    [group addImp:EagleFuleTank_001Imp];
    [group addImp:EagleFuleTank_002Imp];
    [group addImp:EagleFuleTank_003Imp];
    [group addImp:EagleLegImp];
    [group addImp:EagleLeg_001Imp];
    [group addImp:EagleLeg_002Imp];
    [group addImp:EagleLeg_003Imp];
    [group addImp:EaglePodImp];
    [group addImp:EagleStartEngineImp];
    [group addImp:EagleStartEngine_001Imp];
    [group addImp:EagleStartEngine_002Imp];
    [group addImp:EagleStartEngine_003Imp];
    [group addImp:EagleUpperLegRImp];
    [group addImp:EagleUpperLegLImp];
    [group addImp:EagleUpperLegR_001Imp];
    [group addImp:EagleUpperLegL_001Imp];

    [group addImp:thrustImp];
    [group addImp:thrust_001Imp];
    [group addImp:thrust_002Imp];
    [group addImp:thrust_003Imp];

    [group addModifier:@"withoutPod" Impersonator:EaglePodId Modifier:@"visible" Value:[NSNumber numberWithBool:false]];
    [group addModifier:@"withPod" Impersonator:EaglePodId Modifier:@"visible" Value:[NSNumber numberWithBool:true]];
    [group setState:@"withoutPod"];
    
    [group setUseQuaternionRotation:true];

    EagleLegImp.material.eta = 0.2;
    EagleLeg_001Imp.material.eta = 0.2;
    EagleLeg_002Imp.material.eta = 0.2;
    EagleLeg_003Imp.material.eta = 0.2;
    EagleCradleImp.material.eta = 0.2;

}
@end
