//
//  YAProbability.h
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 06.03.13.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YAProbability : NSObject

+ (float) linearProb: (float) sample;
+ (float) sinPowProb: (float) sample;
+ (float) sinSqrtProb: (float) sample;
+ (bool) dice: (float) probability;
// maps an element from an arbitrary range too 0..1
+ (float) mapToProbRange: (float) element From: (float) start To: (float) end;
+ (bool) isInRange: (float) element From: (float) start To: (float) end;

// events are tuples (id, probability). Return choosen event

// Select one random element from an array of elements
+ (id) randomSelect: (NSArray*) events;

// like randomSelect but the sample is given as parameter
+ (id) sampleSelect: (NSArray*) events Sample: (float) sample;

// change the probability of one event in the event array
+ (float) changeEventProbability: (float) change Index: (int) index In: (NSArray*) elements;

// return random float between 0..1
+ (float) random;

// select random element from array
+ (id) randomSelectArray: (NSArray *) array;

//BEWARE: 0.. (tally -1)
+ (int) selectOneOutOf: (int) tally;

@end
