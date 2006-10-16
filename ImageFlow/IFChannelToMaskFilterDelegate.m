//
//  IFChannelToMaskFilterDelegate.m
//  ImageFlow
//
//  Created by Michel Schinz on 16.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFChannelToMaskFilterDelegate.h"
#import "IFEnvironment.h"

@implementation IFChannelToMaskFilterDelegate

- (NSString*)labelWithEnvironment:(IFEnvironment*)env;
{
  return [NSString stringWithFormat:@"%@ to mask", [env valueForKey:@"channel"]];
}

- (NSAffineTransform*)transformForParentAtIndex:(int)index withEnvironment:(IFEnvironment*)env;
{
  return [NSAffineTransform transform];
}

@end
