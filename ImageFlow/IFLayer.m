//
//  IFLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 10.07.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFLayer.h"

@implementation IFLayer

- (id)initWithLayoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
{
  if (![super init])
    return nil;
  layoutParameters = [theLayoutParameters retain];
  self.anchorPoint = CGPointZero;
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(layoutParameters);
  [super dealloc];
}

@end
