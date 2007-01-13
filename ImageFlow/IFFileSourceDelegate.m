//
//  IFFileSourceDelegate.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFFileSourceDelegate.h"

#import "IFEnvironment.h"
#import "IFFunType.h"
#import "IFBasicType.h"
#import "IFImageType.h"

@implementation IFFileSourceDelegate

- (NSArray*)potentialTypesWithEnvironment:(IFEnvironment*)env;
{
  static NSArray* types = nil;
  if (types == nil)
    types = [[NSArray arrayWithObject:[IFImageType imageRGBAType]] retain];
  return types;
}

- (NSString*)labelWithEnvironment:(IFEnvironment*)env;
{
  return [NSString stringWithFormat:@"load %@",[[env valueForKey:@"fileName"] lastPathComponent]];
}

- (NSString*)toolTipWithEnvironment:(IFEnvironment*)env;
{
  return [NSString stringWithFormat:@"load %@",[env valueForKey:@"fileName"]];
}

@end
