//
//  IFChannelToMaskFilterDelegate.m
//  ImageFlow
//
//  Created by Michel Schinz on 16.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFChannelToMaskFilterDelegate.h"
#import "IFEnvironment.h"
#import "IFPair.h"
@implementation IFChannelToMaskFilterDelegate

- (NSString*)labelWithEnvironment:(IFEnvironment*)env;
{
  char* channelInitials = "rgbal";
  return [NSString stringWithFormat:@"%c to mask", channelInitials[[[env valueForKey:@"channel"] intValue]]];
}

- (NSAffineTransform*)transformForParentAtIndex:(int)index withEnvironment:(IFEnvironment*)env;
{
  return [NSAffineTransform transform];
}

- (NSArray*)channels;
{
  return [NSArray arrayWithObjects:
    [IFPair pairWithFst:@"Red" snd:[NSNumber numberWithInt:0]],
    [IFPair pairWithFst:@"Green" snd:[NSNumber numberWithInt:1]],
    [IFPair pairWithFst:@"Blue" snd:[NSNumber numberWithInt:2]],
    [IFPair pairWithFst:@"Opacity" snd:[NSNumber numberWithInt:3]],
    [IFPair pairWithFst:@"Luminosity" snd:[NSNumber numberWithInt:4]],
    nil];
}

@end