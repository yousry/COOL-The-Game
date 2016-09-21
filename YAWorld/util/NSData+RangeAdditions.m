//
//  NSData+RangeAdditions.m
//  YAWorld
//
//  Created by Yousry Abdallah on 23.05.12.
//  Copyright (c) 2013 yousry.de. All rights reserved.
//

#import "fuTypes.h"
#import <Foundation/NSException.h>
#import <Foundation/NSData.h>

@implementation NSData (RangeAdditions)

-(NSRange)rangeOfData:(NSData *)aData
              options:(NSUInteger)mask
                range:(NSRange)aRange
{
 NSRange range=NSMakeRange(NSNotFound,0);
  // NSLog(@"self=%@",self);
  // NSLog(@"aData=%@",aData);
  // NSLog(@"mask=%lu",mask);
  // NSLog(@"aRange=(%lu,%lu)",aRange.location,aRange.length);
  if (aData)
    {
      int aDataLength=[aData length];
      int selfLength=[self length];
      // NSLog(@"aDataLength=%d",aDataLength);
      // NSLog(@"selfLength=%d",selfLength);
      if (aRange.location+aRange.length>selfLength)
        [NSException raise:NSInvalidArgumentException format:@"Bad Range (%d,%d) for self length %d",
                     (int)aRange.location,
                     (int)aRange.length,
                     selfLength];
      else if (aDataLength>0)
        {
          BOOL reverse=((mask&NSBackwardsSearch)==NSBackwardsSearch);
          BOOL anchored=((mask&NSAnchoredSearch)==NSAnchoredSearch);
          const void* selfBytes=[self bytes];
          const void* aDataBytes=[aData bytes];
          // NSLog(@"reverse=%d",(int)reverse);
          // NSLog(@"anchored=%d",(int)anchored);
          if (anchored)
            {
              // Can be found ?
              if (aDataLength<=aRange.length)
                {
                  if (reverse)
                    {
                      if (memcmp(selfBytes+aRange.location-aDataLength,
                                 aDataBytes,
                                 aDataLength)==0)
                        {
                          range=NSMakeRange(selfLength-aDataLength,aDataLength);
                        };
                    }
                  else
                    {
                      if (memcmp(selfBytes+aRange.location,
                                 aDataBytes,
                                 aDataLength))
                        {
                          range=NSMakeRange(0,aDataLength);
                        };
                    };
                };
            }
          else
            {
              if (reverse)
                {
                  int i=0;
                  int first=(aRange.location+aDataLength);
                  for(i=aRange.location+aRange.length-1;i>=first && range.length==0;i--)
                    {
                      if (((unsigned char*)selfBytes)[i]==((unsigned char*)aDataBytes)[aDataLength-1])
                        {
                          if (memcmp(selfBytes+i-aDataLength,aDataBytes,aDataLength)==0)
                            {
                              range=NSMakeRange(i-aDataLength,aDataLength);
                            };
                        };
                    };
                }
              else
                {
                  int i=0;
                  int last=aRange.location+aRange.length-aDataLength;

                  for(i=aRange.location;i<=last && range.length==0;i++)
                    {
                      if (((unsigned char*)selfBytes)[i]==((unsigned char*)aDataBytes)[0])
                        {
                          if (memcmp(selfBytes+i,aDataBytes,aDataLength)==0)
                            {
                              range=NSMakeRange(i,aDataLength);
                            };
                        };
                    };
                };
            };
        };
    }
  else
    [NSException raise:NSInvalidArgumentException
                 format: @"range of nil"];
  return range;}

@end