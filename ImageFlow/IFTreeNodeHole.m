//
//  IFTreeNodeHole.m
//  ImageFlow
//
//  Created by Michel Schinz on 08.11.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFTreeNodeHole.h"


@implementation IFTreeNodeHole

+ (id)hole;
{
  return [[[self alloc] init] autorelease];
}

- (BOOL)isHole;
{
  return YES;
}

@end
