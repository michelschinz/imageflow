//
//  IFColorControlsFilterDelegate.m
//  ImageFlow
//
//  Created by Olivier Crameri on 19.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "IFColorControlsFilterDelegate.h"

#import "IFEnvironment.h"

@implementation IFColorControlsFilterDelegate

- (NSString*)labelWithEnvironment:(IFEnvironment*)env;
{
  return [NSString stringWithFormat:@"Control colors"];
}

@end
