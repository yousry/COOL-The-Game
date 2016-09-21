//
//  YAIngredientSetup.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 03.09.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#import "YAIngredient.h"
#import "YARenderLoop.h"
#import "YAIngredientSetup.h"

@implementation YAIngredientSetup

+ (void) ingame: (YARenderLoop*) world
{
    
    YAIngredient* (^replaceIngredient)(NSString*) = ^(NSString* name) {
        [world removeIngredient:name];
        return [world createIngredient:name];
    };
    
    YAIngredient* ingredient = replaceIngredient(@"GameButton");
    [ingredient setModelWithShader:@"GameButton" shader:@"gourad"];
    
    ingredient = replaceIngredient(@"Rope");
    [ingredient setModelWithShader:@"Rope" shader:@"gourad"];
    
    ingredient = replaceIngredient(@"GameButtonSocket");
    [ingredient setModelWithShader:@"GameButtonSocket" shader:@"gourad_spotlight"];
    
    ingredient = replaceIngredient(@"cursorInner");
    [ingredient setModelWithShader:@"cursorInner" shader:@"gourad"];
    
    ingredient = replaceIngredient(@"cursorOuter");
    [ingredient setModelWithShader:@"cursorOuter" shader:@"gourad"];
    
    ingredient = replaceIngredient(@"csArrow");
    [ingredient setModelWithShader:@"csArrow" shader:@"gourad"];
    
    ingredient = replaceIngredient(@"Star");
    [ingredient setModelWithShader:@"Star" shader:@"gourad"];
    
    ingredient = replaceIngredient(@"Stick");
    [ingredient setModelWithShader:@"Stick" shader:@"gourad"];
    
    ingredient = replaceIngredient(@"Cylinder");
    [ingredient setModelWithShader:@"Cylinder" shader:@"gourad"];

    ingredient = replaceIngredient(@"Plane");
    [ingredient setModelWithShader:@"Plane" shader:@"stripesGourard"];
    
    ingredient = replaceIngredient(@"tileSocket"); // replaceIngredient(@"tileSocket");
    [ingredient setModelWithShader:@"tileSocket" shader:@"gourad_spotlight"];
    
    ingredient = replaceIngredient(@"SpaceShip");
    [ingredient setModelWithShader:@"SpaceShip" shader:@"ads_texture_spotlight"];
    
    ingredient = replaceIngredient(@"PlayboardGame");
    [ingredient setModelWithShader:@"PlayboardGame" shader:@"gourad_spotlight"];
    
    ingredient = replaceIngredient(@"PlayboardTitle");
    [ingredient setModelWithShader:@"PlayboardTitle" shader:@"ads_texture_normal_spotlight"];
    
    ingredient = replaceIngredient(@"normalCube");
    [ingredient setModelWithShader:@"normalCube" shader:@"ads_texture_normal_spotlight"];

    ingredient = replaceIngredient(@"StoreIcon");
    [ingredient setModelWithShader:@"StoreIcon" shader:@"ads_texture"];

    
    ingredient = replaceIngredient(@"DeskHole");
    [ingredient setAutoMipMap:true];
    [ingredient setModelWithShader:@"DeskHole" shader:@"ads_texture_normal"];

    NSArray* models = [[NSArray alloc] initWithObjects:
                       @"Desk", @"FarmhouseTile", @"SmithoreTile", @"SolarplantTile", @"CrystaliteTile", @"Store", @"Barrack"
                       ,nil ];
    
    for(id model in models) {
        ingredient = [world createIngredient:model];
        [ingredient setModelWithShader:model shader:@"ads_texture_spotlight"];
    }
    
    models = [[NSArray alloc] initWithObjects:
              @"BallColorA", @"BallColorB", @"BallColorC", @"BallColorD", @"BallColorE", @"BallColorF", @"BallColorG", @"BallColorH", @"cloud_normal", @"cloud_lightning" , nil ];
    
    for(id model in models) {
        ingredient = [world createIngredient:model];
        [ingredient setModelWithShader:model shader:@"billboard"];
    }
    
    ingredient = replaceIngredient(@"DebugLamp");
    [ingredient setModelWithShader:@"DebugLamp" shader:@"ads_texture"];
    
    ingredient = replaceIngredient(@"playerColorRing");
    [ingredient setModelWithShader:@"playerColorRing" shader:@"billboard_3d"];
    
    
    ingredient = replaceIngredient(@"Sun");
    [ingredient setModelWithShader:@"Sun" shader:@"ads_texture_normal"];
    
    ingredient = replaceIngredient(@"SunCover");
    [ingredient setModelWithShader:@"SunCover" shader:@"ads_texture"];
    
    ingredient = replaceIngredient(@"Moon");
    [ingredient setModelWithShader:@"Moon" shader:@"ads_texture_normal"];

    ingredient = replaceIngredient(@"Meteorid");
    [ingredient setModelWithShader:@"Meteorid" shader:@"ads_texture_normal"];
    
    ingredient = replaceIngredient(@"EagleEngine");
    [ingredient setModelWithShader:@"EagleEngine" shader:@"ads_texture_normal_spotlight"];
    
    
    models = [[NSArray alloc] initWithObjects:
              @"EagleBody", @"EagleCockpit",  @"EagleEngineShield", @"EaglePod", @"EagleUpperLegL", @"EagleUpperLegR", @"Parachute", nil ];
    
    for(id model in models) {
        ingredient = [world createIngredient:model];
        [ingredient setModelWithShader:model shader:@"ads_texture_spotlight"];
    }
    
    models = [[NSArray alloc] initWithObjects:
              @"EagleCradle", @"EagleFuleTank", @"EagleLeg", @"EagleStartEngine",nil ];
    
    for(id model in models) {
        ingredient = [world createIngredient:model];
        [ingredient setModelWithShader:model shader:@"gourad_spotlight"];
    }
    
    
    models = [[NSArray alloc] initWithObjects:
              @"shopBulletinBoard",  @"shopCargoArea", @"shopGateway",
              @"shopPole", @"shopPoleJoint",  @"shopRamp", @"shopTable", nil ];
    
    for(id model in models) {
        ingredient = [world createIngredient:model];
        [ingredient setModelWithShader:model shader:@"gourad_spotlight"];
    }
    
    models = [[NSArray alloc] initWithObjects:
              @"shopAssayMag", @"shopEaglePod", @"shopLandMag", @"shopPaperCrystalite",
              @"shopPaperEnergy",  @"shopPaperFood", @"shopPaperSmithore", @"shopPubMag"
              , @"shopPlaceSign" , nil ];
    
    for(id model in models) {
        ingredient = [world createIngredient:model];
        [ingredient setModelWithShader:model shader:@"ads_texture_spotlight"];
    }
    
    ingredient = replaceIngredient(@"shopSocket");
    [ingredient setModelWithShader:@"shopSocket" shader:@"ads_texture_normal_spotlight"];
    
    ingredient = replaceIngredient(@"thrust");
    [ingredient setModelWithShader:@"thrust" shader:@"perlin_thrust"];
    
    ingredient = replaceIngredient(@"fire");
    [ingredient setModelWithShader:@"fire" shader:@"perlin_thrust"];

    
    ingredient = replaceIngredient(@"CoffeeCup");
    [ingredient setModelWithShader:@"CoffeeCupAlt" shader:@"ads_texture"];
    
    ingredient = replaceIngredient(@"table");
    [ingredient setModelWithShader:@"table" shader:@"ads_texture"];
    
    ingredient = replaceIngredient(@"Wall");
    [ingredient setAutoMipMap:true];
    [ingredient setModelWithShader:@"Wall" shader:@"ads_texture"];

    ingredient = replaceIngredient(@"Bookshelf");
    [ingredient setAutoMipMap:true];
    [ingredient setModelWithShader:@"Bookshelf" shader:@"ads_texture"];
    

    models = [[NSArray alloc] initWithObjects:@"booksLevelA", @"booksLevelB", @"booksLevelC", @"MagA", @"MagB", @"PosterSharks", @"PosterSuperMan", nil ];
    for(id model in models) {
        ingredient = [world createIngredient:model];
        [ingredient setModelWithShader:model shader:@"ads_texture"];
    }

    ingredient = replaceIngredient(@"Ledge");
    [ingredient setModelWithShader:@"Ledge" shader:@"gourad"];
    
    ingredient = replaceIngredient(@"Dromedar");
    [ingredient setModelWithShader:@"DROMEDAR" shader:@"ads_texture_bones"];
    [world addShapeShifter:@"DROMEDAR_O"];

    ingredient = replaceIngredient(@"Thargoid");
    [ingredient setModelWithShader:@"Thargoid" shader:@"ads_texture_bones"];
    [world addShapeShifter:@"Thargoid"];

    models = [[NSArray alloc] initWithObjects:@"shadowCup", @"shadowDesk", @"shadowPlayBoard", @"shadowTable", nil ];
    for(id model in models) {
        ingredient = [world createIngredient:model];
        [ingredient setModelWithShader:model shader:@"billboard_3d"];
    }
}


@end
