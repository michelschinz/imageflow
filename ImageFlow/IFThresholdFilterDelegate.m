//
//  IFThresholdFilterDelegate.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFThresholdFilterDelegate.h"

#import "IFEnvironment.h"

@implementation IFThresholdFilterDelegate

- (NSString*)labelWithEnvironment:(IFEnvironment*)env;
{
  return [NSString stringWithFormat:@"threshold %.2f", [(NSNumber*)[env valueForKey:@"threshold"] floatValue]];
}

@end
