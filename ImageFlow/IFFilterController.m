//
//  IFFilterController.m
//  ImageFlow
//
//  Created by Michel Schinz on 24.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFFilterController.h"

@implementation IFFilterController

- (id)init;
{
  if (![super init])
    return nil;
  filter = nil;
  return self;
}

- (void) dealloc;
{
  [filter release];
  filter = nil;
  [super dealloc];
}

- (void)setConfiguredFilter:(IFConfiguredFilter*)newFilter;
{
  if (newFilter == filter)
    return;
  [filter release];
  filter = [newFilter retain];
}

- (IFConfiguredFilter*)configuredFilter;
{
  return filter;
}

@end
