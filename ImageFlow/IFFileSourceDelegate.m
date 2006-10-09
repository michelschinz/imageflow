//
//  IFFileSourceDelegate.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFFileSourceDelegate.h"

#import "IFEnvironment.h"

@implementation IFFileSourceDelegate

- (NSString*)labelWithEnvironment:(IFEnvironment*)env;
{
  return [NSString stringWithFormat:@"load %@",[[env valueForKey:@"fileName"] lastPathComponent]];
}

- (NSString*)toolTipWithEnvironment:(IFEnvironment*)env;
{
  return [NSString stringWithFormat:@"load %@",[env valueForKey:@"fileName"]];
}

@end
