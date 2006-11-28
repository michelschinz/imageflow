//
//  IFGaussianBlurFilterDelegate.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFGaussianBlurFilterDelegate.h"

#import "IFEnvironment.h"

@implementation IFGaussianBlurFilterDelegate

- (NSString*)labelWithEnvironment:(IFEnvironment*)env;
{
  return [NSString stringWithFormat:@"blur (%.1f gaussian)", [(NSNumber*)[env valueForKey:@"radius"] floatValue]];
}

@end
