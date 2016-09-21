//
//  YAComoditiesAuction.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 20.03.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YAAuction.h"


typedef enum {
    COMMODITY_SMITHORE,
    COMMODITY_ENERGY,
    COMMODITY_FOOD,
    COMMODITY_CRYSTALITE
} tCommodity;


@interface YACommoditiesAuction : YAAuction {
    NSDictionary* _info;
}

@property (strong, readwrite) NSString* comodity;
@property (assign, readonly) bool isFinished;

- (id) initInfo: (NSDictionary*) info;
- (void) auctionFor: (tCommodity) material;

- (float) cleanBoard: (bool) clean;

@end
