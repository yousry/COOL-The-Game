//
//  YAYAShopAssembler.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 27.09.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YASceneUtils.h"
#import "YAMaterial.h"
#import "YAImpersonator+Physic.h"
#import "YAVector3f.h"
#import "YARenderLoop.h"
#import "YAImpGroup.h"

#import "YAShopAssembler.h"

@implementation YAShopAssembler

+(void) buildShop: (YARenderLoop*)world SceneUtils:(YASceneUtils*) utils Group: (YAImpGroup*) group
{
    int shopAssayMagId = [world createImpersonator: @"shopAssayMag"];
    YAImpersonator* shopAssayMagImp = [world getImpersonator:shopAssayMagId];
    [[shopAssayMagImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopAssayMagImp translation] setVector: [[YAVector3f alloc] initVals: -0.21393895149230957f : 0.05070662498474121f : -0.15241006016731262f]];
    [[shopAssayMagImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    int shopBulletinBoardId = [world createImpersonator: @"shopBulletinBoard"];
    YAImpersonator* shopBulletinBoardImp = [world getImpersonator:shopBulletinBoardId];
    [[shopBulletinBoardImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopBulletinBoardImp translation] setVector: [[YAVector3f alloc] initVals: -0.2163066565990448f : 0.0514179952442646f : 0.11989763379096985f]];
    [[shopBulletinBoardImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    [shopBulletinBoardImp setCollisionName:@"Crystalite"];
    
    
    int shopBulletinBoard_001Id = [world createImpersonator: @"shopBulletinBoard"];
    YAImpersonator* shopBulletinBoard_001Imp = [world getImpersonator:shopBulletinBoard_001Id];
    [[shopBulletinBoard_001Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopBulletinBoard_001Imp translation] setVector: [[YAVector3f alloc] initVals: -0.13136810064315796f : 0.0514179952442646f : 0.11989763379096985f]];
    [[shopBulletinBoard_001Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    [shopBulletinBoard_001Imp setCollisionName:@"Smithore"];

    
    int shopBulletinBoard_002Id = [world createImpersonator: @"shopBulletinBoard"];
    YAImpersonator* shopBulletinBoard_002Imp = [world getImpersonator:shopBulletinBoard_002Id];
    [[shopBulletinBoard_002Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopBulletinBoard_002Imp translation] setVector: [[YAVector3f alloc] initVals: -0.046328864991664886f : 0.0514179952442646f : 0.11989763379096985f]];
    [[shopBulletinBoard_002Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    [shopBulletinBoard_002Imp setCollisionName:@"Energy"];
    
    
    int shopBulletinBoard_003Id = [world createImpersonator: @"shopBulletinBoard"];
    YAImpersonator* shopBulletinBoard_003Imp = [world getImpersonator:shopBulletinBoard_003Id];
    [[shopBulletinBoard_003Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopBulletinBoard_003Imp translation] setVector: [[YAVector3f alloc] initVals: 0.039144739508628845f : 0.0514179952442646f : 0.11989763379096985f]];
    [[shopBulletinBoard_003Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    [shopBulletinBoard_003Imp setCollisionName:@"Farm"];
    
    int shopCargoAreaId = [world createImpersonator: @"shopCargoArea"];
    YAImpersonator* shopCargoAreaImp = [world getImpersonator:shopCargoAreaId];
    [[shopCargoAreaImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopCargoAreaImp translation] setVector: [[YAVector3f alloc] initVals: 0.23013554513454437f : 0.03042624332010746f : -0.002894788281992078f]];
    [[shopCargoAreaImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopEaglePodId = [world createImpersonator: @"shopEaglePod"];
    YAImpersonator* shopEaglePodImp = [world getImpersonator:shopEaglePodId];
    [[shopEaglePodImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopEaglePodImp translation] setVector: [[YAVector3f alloc] initVals: 0.22977857291698456f : 0.03042338788509369f : 0.0f]];
    [[shopEaglePodImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    int shopGatewayId = [world createImpersonator: @"shopGateway"];
    YAImpersonator* shopGatewayImp = [world getImpersonator:shopGatewayId];
    [[shopGatewayImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 179.999991348578f : -0.0f]];
    [[shopGatewayImp translation] setVector: [[YAVector3f alloc] initVals: -0.10549534857273102f : 0.03135940432548523f : 0.001957230269908905f]];
    [[shopGatewayImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopLandMagId = [world createImpersonator: @"shopLandMag"];
    YAImpersonator* shopLandMagImp = [world getImpersonator:shopLandMagId];
    [[shopLandMagImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopLandMagImp translation] setVector: [[YAVector3f alloc] initVals: -0.1286381185054779f : 0.05011000111699104f : -0.15241006016731262f]];
    [[shopLandMagImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPaperCrystaliteId = [world createImpersonator: @"shopPaperCrystalite"];
    YAImpersonator* shopPaperCrystaliteImp = [world getImpersonator:shopPaperCrystaliteId];
    [[shopPaperCrystaliteImp rotation] setVector: [[YAVector3f alloc] initVals: -119.99999741973147f : -1.704453556208414e-15f : -6.3611093629270335e-15f]];
    [[shopPaperCrystaliteImp translation] setVector: [[YAVector3f alloc] initVals: -0.21621941030025482f : 0.05161210894584656f : 0.11902572214603424f]];
    [[shopPaperCrystaliteImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPaperEnergyId = [world createImpersonator: @"shopPaperEnergy"];
    YAImpersonator* shopPaperEnergyImp = [world getImpersonator:shopPaperEnergyId];
    [[shopPaperEnergyImp rotation] setVector: [[YAVector3f alloc] initVals: -119.99999741973147f : -1.704453556208414e-15f : -6.3611093629270335e-15f]];
    [[shopPaperEnergyImp translation] setVector: [[YAVector3f alloc] initVals: -0.046272847801446915f : 0.052260030061006546f : 0.11940820515155792f]];
    [[shopPaperEnergyImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPaperFoodId = [world createImpersonator: @"shopPaperFood"];
    YAImpersonator* shopPaperFoodImp = [world getImpersonator:shopPaperFoodId];
    [[shopPaperFoodImp rotation] setVector: [[YAVector3f alloc] initVals: -119.99999741973147f : -1.704453556208414e-15f : -6.3611093629270335e-15f]];
    [[shopPaperFoodImp translation] setVector: [[YAVector3f alloc] initVals: 0.03955332189798355f : 0.052078962326049805f : 0.11966440081596375f]];
    [[shopPaperFoodImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPaperSmithoreId = [world createImpersonator: @"shopPaperSmithore"];
    YAImpersonator* shopPaperSmithoreImp = [world getImpersonator:shopPaperSmithoreId];
    [[shopPaperSmithoreImp rotation] setVector: [[YAVector3f alloc] initVals: -119.99999741973147f : -1.704453556208414e-15f : -6.3611093629270335e-15f]];
    [[shopPaperSmithoreImp translation] setVector: [[YAVector3f alloc] initVals: -0.13100475072860718f : 0.05215052515268326f : 0.11931261420249939f]];
    [[shopPaperSmithoreImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPlaceSignId = [world createImpersonator: @"shopPlaceSign"];
    YAImpersonator* shopPlaceSignImp = [world getImpersonator:shopPlaceSignId];
    [[shopPlaceSignImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPlaceSignImp translation] setVector: [[YAVector3f alloc] initVals: -0.09984226524829865f : 0.10157470405101776f : 0.3397468328475952f]];
    [[shopPlaceSignImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleId = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPoleImp = [world getImpersonator:shopPoleId];
    [[shopPoleImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPoleImp translation] setVector: [[YAVector3f alloc] initVals: -0.3357354998588562f : 0.05096618831157684f : -0.2869843542575836f]];
    [[shopPoleImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_001Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_001Imp = [world getImpersonator:shopPole_001Id];
    [[shopPole_001Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPole_001Imp translation] setVector: [[YAVector3f alloc] initVals: -0.28455737233161926f : 0.05096618831157684f : -0.2869843542575836f]];
    [[shopPole_001Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_002Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_002Imp = [world getImpersonator:shopPole_002Id];
    [[shopPole_002Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPole_002Imp translation] setVector: [[YAVector3f alloc] initVals: -0.1821070909500122f : 0.05096618831157684f : -0.2869843542575836f]];
    [[shopPole_002Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_003Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_003Imp = [world getImpersonator:shopPole_003Id];
    [[shopPole_003Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPole_003Imp translation] setVector: [[YAVector3f alloc] initVals: -0.23328521847724915f : 0.05096618831157684f : -0.2869843542575836f]];
    [[shopPole_003Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_004Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_004Imp = [world getImpersonator:shopPole_004Id];
    [[shopPole_004Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPole_004Imp translation] setVector: [[YAVector3f alloc] initVals: -0.07981766015291214f : 0.05096618831157684f : -0.2869843542575836f]];
    [[shopPole_004Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_005Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_005Imp = [world getImpersonator:shopPole_005Id];
    [[shopPole_005Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPole_005Imp translation] setVector: [[YAVector3f alloc] initVals: -0.0286395326256752f : 0.05096618831157684f : -0.2869843542575836f]];
    [[shopPole_005Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_006Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_006Imp = [world getImpersonator:shopPole_006Id];
    [[shopPole_006Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPole_006Imp translation] setVector: [[YAVector3f alloc] initVals: -0.13108980655670166f : 0.05096618831157684f : -0.2869843542575836f]];
    [[shopPole_006Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_007Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_007Imp = [world getImpersonator:shopPole_007Id];
    [[shopPole_007Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPole_007Imp translation] setVector: [[YAVector3f alloc] initVals: 0.07367315143346786f : 0.05096618831157684f : -0.2869843542575836f]];
    [[shopPole_007Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_008Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_008Imp = [world getImpersonator:shopPole_008Id];
    [[shopPole_008Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPole_008Imp translation] setVector: [[YAVector3f alloc] initVals: 0.022495023906230927f : 0.05096618831157684f : -0.2869843542575836f]];
    [[shopPole_008Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_009Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_009Imp = [world getImpersonator:shopPole_009Id];
    [[shopPole_009Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPole_009Imp translation] setVector: [[YAVector3f alloc] initVals: 0.02257329225540161f : 0.05096618831157684f : 0.27598443627357483f]];
    [[shopPole_009Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_010Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_010Imp = [world getImpersonator:shopPole_010Id];
    [[shopPole_010Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPole_010Imp translation] setVector: [[YAVector3f alloc] initVals: 0.07375141978263855f : 0.05096618831157684f : 0.27598443627357483f]];
    [[shopPole_010Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_011Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_011Imp = [world getImpersonator:shopPole_011Id];
    [[shopPole_011Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPole_011Imp translation] setVector: [[YAVector3f alloc] initVals: -0.13101154565811157f : 0.05096618831157684f : 0.27598443627357483f]];
    [[shopPole_011Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_012Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_012Imp = [world getImpersonator:shopPole_012Id];
    [[shopPole_012Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPole_012Imp translation] setVector: [[YAVector3f alloc] initVals: -0.028561264276504517f : 0.05096618831157684f : 0.27598443627357483f]];
    [[shopPole_012Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_013Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_013Imp = [world getImpersonator:shopPole_013Id];
    [[shopPole_013Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPole_013Imp translation] setVector: [[YAVector3f alloc] initVals: -0.07973939180374146f : 0.05096618831157684f : 0.27598443627357483f]];
    [[shopPole_013Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_014Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_014Imp = [world getImpersonator:shopPole_014Id];
    [[shopPole_014Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPole_014Imp translation] setVector: [[YAVector3f alloc] initVals: -0.23320695757865906f : 0.05096618831157684f : 0.27598443627357483f]];
    [[shopPole_014Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_015Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_015Imp = [world getImpersonator:shopPole_015Id];
    [[shopPole_015Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPole_015Imp translation] setVector: [[YAVector3f alloc] initVals: -0.18202883005142212f : 0.05096618831157684f : 0.27598443627357483f]];
    [[shopPole_015Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_016Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_016Imp = [world getImpersonator:shopPole_016Id];
    [[shopPole_016Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPole_016Imp translation] setVector: [[YAVector3f alloc] initVals: -0.2844791114330292f : 0.05096618831157684f : 0.27598443627357483f]];
    [[shopPole_016Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_017Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_017Imp = [world getImpersonator:shopPole_017Id];
    [[shopPole_017Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPole_017Imp translation] setVector: [[YAVector3f alloc] initVals: -0.3356572389602661f : 0.05096618831157684f : 0.27598443627357483f]];
    [[shopPole_017Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_019Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_019Imp = [world getImpersonator:shopPole_019Id];
    [[shopPole_019Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 89.999995674289f : -0.0f]];
    [[shopPole_019Imp translation] setVector: [[YAVector3f alloc] initVals: -0.33613523840904236f : 0.05096618831157684f : 0.12232477962970734f]];
    [[shopPole_019Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_020Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_020Imp = [world getImpersonator:shopPole_020Id];
    [[shopPole_020Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 89.999995674289f : -0.0f]];
    [[shopPole_020Imp translation] setVector: [[YAVector3f alloc] initVals: -0.33613523840904236f : 0.05096618831157684f : 0.17350290715694427f]];
    [[shopPole_020Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_021Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_021Imp = [world getImpersonator:shopPole_021Id];
    [[shopPole_021Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 89.999995674289f : -0.0f]];
    [[shopPole_021Imp translation] setVector: [[YAVector3f alloc] initVals: -0.33613526821136475f : 0.05096618831157684f : -0.03126006945967674f]];
    [[shopPole_021Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_022Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_022Imp = [world getImpersonator:shopPole_022Id];
    [[shopPole_022Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 89.999995674289f : -0.0f]];
    [[shopPole_022Imp translation] setVector: [[YAVector3f alloc] initVals: -0.33613526821136475f : 0.05096618831157684f : 0.07119022309780121f]];
    [[shopPole_022Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_023Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_023Imp = [world getImpersonator:shopPole_023Id];
    [[shopPole_023Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 89.999995674289f : -0.0f]];
    [[shopPole_023Imp translation] setVector: [[YAVector3f alloc] initVals: -0.33613526821136475f : 0.05096618831157684f : 0.02001209184527397f]];
    [[shopPole_023Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_024Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_024Imp = [world getImpersonator:shopPole_024Id];
    [[shopPole_024Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 89.999995674289f : -0.0f]];
    [[shopPole_024Imp translation] setVector: [[YAVector3f alloc] initVals: -0.33613529801368713f : 0.05096618831157684f : -0.13345545530319214f]];
    [[shopPole_024Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_025Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_025Imp = [world getImpersonator:shopPole_025Id];
    [[shopPole_025Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 89.999995674289f : -0.0f]];
    [[shopPole_025Imp translation] setVector: [[YAVector3f alloc] initVals: -0.33613526821136475f : 0.05096618831157684f : -0.0822773426771164f]];
    [[shopPole_025Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_026Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_026Imp = [world getImpersonator:shopPole_026Id];
    [[shopPole_026Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 89.999995674289f : -0.0f]];
    [[shopPole_026Imp translation] setVector: [[YAVector3f alloc] initVals: -0.33613529801368713f : 0.05096618831157684f : -0.18472760915756226f]];
    [[shopPole_026Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_027Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_027Imp = [world getImpersonator:shopPole_027Id];
    [[shopPole_027Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 89.999995674289f : -0.0f]];
    [[shopPole_027Imp translation] setVector: [[YAVector3f alloc] initVals: -0.33613529801368713f : 0.05096618831157684f : -0.2359057366847992f]];
    [[shopPole_027Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPole_028Id = [world createImpersonator: @"shopPole"];
    YAImpersonator* shopPole_028Imp = [world getImpersonator:shopPole_028Id];
    [[shopPole_028Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 89.999995674289f : -0.0f]];
    [[shopPole_028Imp translation] setVector: [[YAVector3f alloc] initVals: -0.33613523840904236f : 0.05096618831157684f : 0.22495287656784058f]];
    [[shopPole_028Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJointId = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJointImp = [world getImpersonator:shopPoleJointId];
    [[shopPoleJointImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPoleJointImp translation] setVector: [[YAVector3f alloc] initVals: -0.31025856733322144f : 0.05521746724843979f : -0.2869843542575836f]];
    [[shopPoleJointImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_001Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_001Imp = [world getImpersonator:shopPoleJoint_001Id];
    [[shopPoleJoint_001Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPoleJoint_001Imp translation] setVector: [[YAVector3f alloc] initVals: -0.2590804398059845f : 0.05521746724843979f : -0.2869843542575836f]];
    [[shopPoleJoint_001Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_002Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_002Imp = [world getImpersonator:shopPoleJoint_002Id];
    [[shopPoleJoint_002Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPoleJoint_002Imp translation] setVector: [[YAVector3f alloc] initVals: -0.15663015842437744f : 0.05521746724843979f : -0.2869843542575836f]];
    [[shopPoleJoint_002Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_003Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_003Imp = [world getImpersonator:shopPoleJoint_003Id];
    [[shopPoleJoint_003Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPoleJoint_003Imp translation] setVector: [[YAVector3f alloc] initVals: -0.20780828595161438f : 0.05521746724843979f : -0.2869843542575836f]];
    [[shopPoleJoint_003Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_004Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_004Imp = [world getImpersonator:shopPoleJoint_004Id];
    [[shopPoleJoint_004Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPoleJoint_004Imp translation] setVector: [[YAVector3f alloc] initVals: -0.054340727627277374f : 0.05521746724843979f : -0.2869843542575836f]];
    [[shopPoleJoint_004Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_005Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_005Imp = [world getImpersonator:shopPoleJoint_005Id];
    [[shopPoleJoint_005Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPoleJoint_005Imp translation] setVector: [[YAVector3f alloc] initVals: -0.003162600100040436f : 0.05521746724843979f : -0.2869843542575836f]];
    [[shopPoleJoint_005Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_006Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_006Imp = [world getImpersonator:shopPoleJoint_006Id];
    [[shopPoleJoint_006Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPoleJoint_006Imp translation] setVector: [[YAVector3f alloc] initVals: -0.10561288148164749f : 0.05521746724843979f : -0.2869843542575836f]];
    [[shopPoleJoint_006Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_007Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_007Imp = [world getImpersonator:shopPoleJoint_007Id];
    [[shopPoleJoint_007Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPoleJoint_007Imp translation] setVector: [[YAVector3f alloc] initVals: 0.04797195643186569f : 0.05521746724843979f : -0.2869843542575836f]];
    [[shopPoleJoint_007Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_008Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_008Imp = [world getImpersonator:shopPoleJoint_008Id];
    [[shopPoleJoint_008Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPoleJoint_008Imp translation] setVector: [[YAVector3f alloc] initVals: 0.04805022478103638f : 0.05521746724843979f : 0.27598443627357483f]];
    [[shopPoleJoint_008Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_009Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_009Imp = [world getImpersonator:shopPoleJoint_009Id];
    [[shopPoleJoint_009Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPoleJoint_009Imp translation] setVector: [[YAVector3f alloc] initVals: -0.1055346131324768f : 0.05521746724843979f : 0.27598443627357483f]];
    [[shopPoleJoint_009Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_010Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_010Imp = [world getImpersonator:shopPoleJoint_010Id];
    [[shopPoleJoint_010Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPoleJoint_010Imp translation] setVector: [[YAVector3f alloc] initVals: -0.003084331750869751f : 0.05521746724843979f : 0.27598443627357483f]];
    [[shopPoleJoint_010Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_011Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_011Imp = [world getImpersonator:shopPoleJoint_011Id];
    [[shopPoleJoint_011Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPoleJoint_011Imp translation] setVector: [[YAVector3f alloc] initVals: -0.05426245927810669f : 0.05521746724843979f : 0.27598443627357483f]];
    [[shopPoleJoint_011Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_012Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_012Imp = [world getImpersonator:shopPoleJoint_012Id];
    [[shopPoleJoint_012Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPoleJoint_012Imp translation] setVector: [[YAVector3f alloc] initVals: -0.2077300250530243f : 0.05521746724843979f : 0.27598443627357483f]];
    [[shopPoleJoint_012Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_013Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_013Imp = [world getImpersonator:shopPoleJoint_013Id];
    [[shopPoleJoint_013Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPoleJoint_013Imp translation] setVector: [[YAVector3f alloc] initVals: -0.15655189752578735f : 0.05521746724843979f : 0.27598443627357483f]];
    [[shopPoleJoint_013Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_014Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_014Imp = [world getImpersonator:shopPoleJoint_014Id];
    [[shopPoleJoint_014Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPoleJoint_014Imp translation] setVector: [[YAVector3f alloc] initVals: -0.2590021789073944f : 0.05521746724843979f : 0.27598443627357483f]];
    [[shopPoleJoint_014Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_015Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_015Imp = [world getImpersonator:shopPoleJoint_015Id];
    [[shopPoleJoint_015Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPoleJoint_015Imp translation] setVector: [[YAVector3f alloc] initVals: -0.31018030643463135f : 0.05521746724843979f : 0.27598443627357483f]];
    [[shopPoleJoint_015Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_016Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_016Imp = [world getImpersonator:shopPoleJoint_016Id];
    [[shopPoleJoint_016Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 89.999995674289f : -0.0f]];
    [[shopPoleJoint_016Imp translation] setVector: [[YAVector3f alloc] initVals: -0.33613523840904236f : 0.05521746724843979f : 0.1478017121553421f]];
    [[shopPoleJoint_016Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_017Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_017Imp = [world getImpersonator:shopPoleJoint_017Id];
    [[shopPoleJoint_017Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 89.999995674289f : -0.0f]];
    [[shopPoleJoint_017Imp translation] setVector: [[YAVector3f alloc] initVals: -0.33613526821136475f : 0.05521746724843979f : -0.005783136934041977f]];
    [[shopPoleJoint_017Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_018Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_018Imp = [world getImpersonator:shopPoleJoint_018Id];
    [[shopPoleJoint_018Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 89.999995674289f : -0.0f]];
    [[shopPoleJoint_018Imp translation] setVector: [[YAVector3f alloc] initVals: -0.33613526821136475f : 0.05521746724843979f : 0.09666715562343597f]];
    [[shopPoleJoint_018Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_019Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_019Imp = [world getImpersonator:shopPoleJoint_019Id];
    [[shopPoleJoint_019Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 89.999995674289f : -0.0f]];
    [[shopPoleJoint_019Imp translation] setVector: [[YAVector3f alloc] initVals: -0.33613526821136475f : 0.05521746724843979f : 0.04548902437090874f]];
    [[shopPoleJoint_019Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_020Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_020Imp = [world getImpersonator:shopPoleJoint_020Id];
    [[shopPoleJoint_020Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 89.999995674289f : -0.0f]];
    [[shopPoleJoint_020Imp translation] setVector: [[YAVector3f alloc] initVals: -0.33613529801368713f : 0.05521746724843979f : -0.10797852277755737f]];
    [[shopPoleJoint_020Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_021Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_021Imp = [world getImpersonator:shopPoleJoint_021Id];
    [[shopPoleJoint_021Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 89.999995674289f : -0.0f]];
    [[shopPoleJoint_021Imp translation] setVector: [[YAVector3f alloc] initVals: -0.33613526821136475f : 0.05521746724843979f : -0.05680040642619133f]];
    [[shopPoleJoint_021Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_022Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_022Imp = [world getImpersonator:shopPoleJoint_022Id];
    [[shopPoleJoint_022Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 89.999995674289f : -0.0f]];
    [[shopPoleJoint_022Imp translation] setVector: [[YAVector3f alloc] initVals: -0.33613529801368713f : 0.05521746724843979f : -0.1592506766319275f]];
    [[shopPoleJoint_022Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_023Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_023Imp = [world getImpersonator:shopPoleJoint_023Id];
    [[shopPoleJoint_023Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 89.999995674289f : -0.0f]];
    [[shopPoleJoint_023Imp translation] setVector: [[YAVector3f alloc] initVals: -0.33613529801368713f : 0.05521746724843979f : -0.21042880415916443f]];
    [[shopPoleJoint_023Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_024Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_024Imp = [world getImpersonator:shopPoleJoint_024Id];
    [[shopPoleJoint_024Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 89.999995674289f : -0.0f]];
    [[shopPoleJoint_024Imp translation] setVector: [[YAVector3f alloc] initVals: -0.33613529801368713f : 0.05521746724843979f : -0.26146987080574036f]];
    [[shopPoleJoint_024Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_025Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_025Imp = [world getImpersonator:shopPoleJoint_025Id];
    [[shopPoleJoint_025Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 89.999995674289f : -0.0f]];
    [[shopPoleJoint_025Imp translation] setVector: [[YAVector3f alloc] initVals: -0.33613523840904236f : 0.05521746724843979f : 0.1992516815662384f]];
    [[shopPoleJoint_025Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPoleJoint_026Id = [world createImpersonator: @"shopPoleJoint"];
    YAImpersonator* shopPoleJoint_026Imp = [world getImpersonator:shopPoleJoint_026Id];
    [[shopPoleJoint_026Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 89.999995674289f : -0.0f]];
    [[shopPoleJoint_026Imp translation] setVector: [[YAVector3f alloc] initVals: -0.33613523840904236f : 0.05521746724843979f : 0.2504490315914154f]];
    [[shopPoleJoint_026Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopPubMagId = [world createImpersonator: @"shopPubMag"];
    YAImpersonator* shopPubMagImp = [world getImpersonator:shopPubMagId];
    [[shopPubMagImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopPubMagImp translation] setVector: [[YAVector3f alloc] initVals: -0.044060349464416504f : 0.05071000009775162f : -0.15241006016731262f]];
    [[shopPubMagImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopRampId = [world createImpersonator: @"shopRamp"];
    YAImpersonator* shopRampImp = [world getImpersonator:shopRampId];
    [[shopRampImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopRampImp translation] setVector: [[YAVector3f alloc] initVals: 0.16837412118911743f : 0.03612758591771126f : -5.440986328153485e-09f]];
    [[shopRampImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopSocketId = [world createImpersonator: @"shopSocket"];
    YAImpersonator* shopSocketImp = [world getImpersonator:shopSocketId];
    [[shopSocketImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : -0.0f]];
    [[shopSocketImp translation] setVector: [[YAVector3f alloc] initVals: -0.001228931243531406f : 0.015213126316666603f : -0.00034213977050967515f]];
    [[shopSocketImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    
    
    int shopTableId = [world createImpersonator: @"shopTable"];
    YAImpersonator* shopTableImp = [world getImpersonator:shopTableId];
    [[shopTableImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : -89.999995674289f : -0.0f]];
    [[shopTableImp translation] setVector: [[YAVector3f alloc] initVals: -0.21389678120613098f : 0.049243051558732986f : -0.15177151560783386f]];
    [[shopTableImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    [shopTableImp setCollisionName:@"Assay"];
    
    
    int shopTable_001Id = [world createImpersonator: @"shopTable"];
    YAImpersonator* shopTable_001Imp = [world getImpersonator:shopTable_001Id];
    [[shopTable_001Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : -89.999995674289f : -0.0f]];
    [[shopTable_001Imp translation] setVector: [[YAVector3f alloc] initVals: -0.12892620265483856f : 0.049243051558732986f : -0.15177151560783386f]];
    [[shopTable_001Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    [shopTable_001Imp setCollisionName:@"Land"];

    
    
    int shopTable_002Id = [world createImpersonator: @"shopTable"];
    YAImpersonator* shopTable_002Imp = [world getImpersonator:shopTable_002Id];
    [[shopTable_002Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : -89.999995674289f : -0.0f]];
    [[shopTable_002Imp translation] setVector: [[YAVector3f alloc] initVals: -0.04383491724729538f : 0.049243051558732986f : -0.15177151560783386f]];
    [[shopTable_002Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    [shopTable_002Imp setCollisionName:@"Pub"];
    
    
    int shopTable_003Id = [world createImpersonator: @"shopTable"];
    YAImpersonator* shopTable_003Imp = [world getImpersonator:shopTable_003Id];
    [[shopTable_003Imp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : -89.999995674289f : -0.0f]];
    [[shopTable_003Imp translation] setVector: [[YAVector3f alloc] initVals: 0.03957435488700867f : 0.049243051558732986f : -0.15177151560783386f]];
    [[shopTable_003Imp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
    [shopTable_003Imp setCollisionName:@"Camel"];
    
    // ------------------------------
    
    NSArray *imps = [[NSArray alloc] initWithObjects:
                     shopAssayMagImp,
                     shopBulletinBoardImp,
                     shopBulletinBoard_001Imp,
                     shopBulletinBoard_002Imp,
                     shopBulletinBoard_003Imp,
                     shopCargoAreaImp,
                     shopEaglePodImp,
                     shopGatewayImp,
                     shopLandMagImp,
                     shopPaperCrystaliteImp,
                     shopPaperEnergyImp,
                     shopPaperFoodImp,
                     shopPaperSmithoreImp,
                     shopPlaceSignImp,
                     shopPoleImp,
                     shopPole_001Imp,
                     shopPole_002Imp,
                     shopPole_003Imp,
                     shopPole_004Imp,
                     shopPole_005Imp,
                     shopPole_006Imp,
                     shopPole_007Imp,
                     shopPole_008Imp,
                     shopPole_009Imp,
                     shopPole_010Imp,
                     shopPole_011Imp,
                     shopPole_012Imp,
                     shopPole_013Imp,
                     shopPole_014Imp,
                     shopPole_015Imp,
                     shopPole_016Imp,
                     shopPole_017Imp,
                     shopPole_019Imp,
                     shopPole_020Imp,
                     shopPole_021Imp,
                     shopPole_022Imp,
                     shopPole_023Imp,
                     shopPole_024Imp,
                     shopPole_025Imp,
                     shopPole_026Imp,
                     shopPole_027Imp,
                     shopPole_028Imp,
                     shopPoleJointImp,
                     shopPoleJoint_001Imp,
                     shopPoleJoint_002Imp,
                     shopPoleJoint_003Imp,
                     shopPoleJoint_004Imp,
                     shopPoleJoint_005Imp,
                     shopPoleJoint_006Imp,
                     shopPoleJoint_007Imp,
                     shopPoleJoint_008Imp,
                     shopPoleJoint_009Imp,
                     shopPoleJoint_010Imp,
                     shopPoleJoint_011Imp,
                     shopPoleJoint_012Imp,
                     shopPoleJoint_013Imp,
                     shopPoleJoint_014Imp,
                     shopPoleJoint_015Imp,
                     shopPoleJoint_016Imp,
                     shopPoleJoint_017Imp,
                     shopPoleJoint_018Imp,
                     shopPoleJoint_019Imp,
                     shopPoleJoint_020Imp,
                     shopPoleJoint_021Imp,
                     shopPoleJoint_022Imp,
                     shopPoleJoint_023Imp,
                     shopPoleJoint_024Imp,
                     shopPoleJoint_025Imp,
                     shopPoleJoint_026Imp,
                     shopPubMagImp,
                     shopSocketImp,
                     shopTableImp,
                     shopTable_001Imp,
                     shopTable_002Imp,
                     shopTable_003Imp,
                     shopRampImp,
                     nil ];
    
    
    YAVector3f *ambientColor = [[YAVector3f alloc] initVals:0.3 :0.3 :0.3];
    YAVector3f *diffuseColor = [[YAVector3f alloc] initVals:0.2 :0.2 :0.2];
    YAVector3f *specularColor = [[YAVector3f alloc] initVals:0.1 :0.1 :0.1];
    
    
    for(YAImpersonator* imp in imps) {
        [[[imp material] phongAmbientReflectivity] setVector:ambientColor];
        [[[imp material] phongDiffuseReflectivity] setVector:diffuseColor];
        [[[imp material] phongSpecularReflectivity] setVector:specularColor];
        imp.material.eta = 1.0;
        [imp setShadowCaster:false];
        [group addImp:imp];
    }
    
    NSArray* greenImps = [[NSArray alloc] initWithObjects:
                          shopPoleImp,
                          shopPole_001Imp,
                          shopPole_002Imp,
                          shopPole_003Imp,
                          shopPole_004Imp,
                          shopPole_005Imp,
                          shopPole_006Imp,
                          shopPole_007Imp,
                          shopPole_008Imp,
                          shopPole_009Imp,
                          shopPole_010Imp,
                          shopPole_011Imp,
                          shopPole_012Imp,
                          shopPole_013Imp,
                          shopPole_014Imp,
                          shopPole_015Imp,
                          shopPole_016Imp,
                          shopPole_017Imp,
                          shopPole_019Imp,
                          shopPole_020Imp,
                          shopPole_021Imp,
                          shopPole_022Imp,
                          shopPole_023Imp,
                          shopPole_024Imp,
                          shopPole_025Imp,
                          shopPole_026Imp,
                          shopPole_027Imp,
                          shopPole_028Imp,
                          shopPoleJointImp,
                          shopPoleJoint_001Imp,
                          shopPoleJoint_002Imp,
                          shopPoleJoint_003Imp,
                          shopPoleJoint_004Imp,
                          shopPoleJoint_005Imp,
                          shopPoleJoint_006Imp,
                          shopPoleJoint_007Imp,
                          shopPoleJoint_008Imp,
                          shopPoleJoint_009Imp,
                          shopPoleJoint_010Imp,
                          shopPoleJoint_011Imp,
                          shopPoleJoint_012Imp,
                          shopPoleJoint_013Imp,
                          shopPoleJoint_014Imp,
                          shopPoleJoint_015Imp,
                          shopPoleJoint_016Imp,
                          shopPoleJoint_017Imp,
                          shopPoleJoint_018Imp,
                          shopPoleJoint_019Imp,
                          shopPoleJoint_020Imp,
                          shopPoleJoint_021Imp,
                          shopPoleJoint_022Imp,
                          shopPoleJoint_023Imp,
                          shopPoleJoint_024Imp,
                          shopPoleJoint_025Imp,
                          shopPoleJoint_026Imp, nil];
    
    
    
    for(YAImpersonator* imp in greenImps) {
        [[[imp material] phongAmbientReflectivity] setValues:0 :0.4 :0.015];
        [[[imp material] phongDiffuseReflectivity] setValues:0 :0.3 :0.03];
        [[[imp material] phongSpecularReflectivity] setValues:0 :0.2 :0.01];
        imp.material.eta = 1.0;
    }

    [[[shopCargoAreaImp material] phongAmbientReflectivity] setValues:0 :0.2488 :1];
    [[[shopCargoAreaImp material] phongDiffuseReflectivity] setValues:0 :0.2488 :1];
    [[[shopCargoAreaImp material] phongSpecularReflectivity] setValues:0 :0.2488 :1];
    shopCargoAreaImp.material.eta = 1;

    [[[shopGatewayImp material] phongAmbientReflectivity] setValues:0.8 :0.156 :0.227];
    [[[shopGatewayImp material] phongDiffuseReflectivity] setValues:0.8 :0.156 :0.227];
    [[[shopGatewayImp material] phongSpecularReflectivity] setValues:0.8 :0.156 :0.227];
    shopGatewayImp.material.eta = 1.0;
    
    [[[shopGatewayImp material] phongAmbientReflectivity] setValues:0.8 :0.156 :0.227];
    [[[shopGatewayImp material] phongDiffuseReflectivity] setValues:0.8 :0.156 :0.227];
    [[[shopGatewayImp material] phongSpecularReflectivity] setValues:0.8 :0.156 :0.227];
    shopGatewayImp.material.eta = 0.2;


    NSArray* blueImps = [[NSArray alloc] initWithObjects:
                         shopTableImp,
                         shopTable_001Imp,
                         shopTable_002Imp,
                         shopTable_003Imp,
                         shopBulletinBoardImp,
                         shopBulletinBoard_001Imp,
                         shopBulletinBoard_002Imp,
                         shopBulletinBoard_003Imp
                         , nil];
    
    for(YAImpersonator* imp in blueImps) {
        [[[imp material] phongAmbientReflectivity] setValues:0.139 :0.8 :0.8];
        [[[imp material] phongDiffuseReflectivity] setValues:0.139 :0.8 :0.8];
        [[[imp material] phongSpecularReflectivity] setValues:0.139 :0.8 :0.8];
        imp.material.eta = 1.0;
    }

    [[[shopSocketImp material] phongAmbientReflectivity] setValues:0.491175 :0.491175 :0.491175];
    [[[shopSocketImp material] phongDiffuseReflectivity] setValues:0.509172 :0.509172 :0.509172];
    [[[shopSocketImp material] phongSpecularReflectivity] setValues:0.8 :0.8 :0.8];
    [[shopSocketImp material] setPhongShininess:15];
     shopSocketImp.material.eta = 1.0;

    shopRampImp.material.eta = 0.2;

    [group addModifier:@"withoutPod" Impersonator:shopEaglePodId Modifier:@"visible" Value:[NSNumber numberWithBool:false]];
    [group addModifier:@"withoutPod" Impersonator:shopRampId Modifier:@"visible" Value:[NSNumber numberWithBool:false]];

    [group addModifier:@"withPod" Impersonator:shopEaglePodId Modifier:@"visible" Value:[NSNumber numberWithBool:true]];
    [group addModifier:@"withPod" Impersonator:shopRampId Modifier:@"visible" Value:[NSNumber numberWithBool:true]];

    [group setState:@"withPod"];
}

@end
