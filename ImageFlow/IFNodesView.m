//
//  IFNodesView.m
//  ImageFlow
//
//  Created by Michel Schinz on 08.12.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFNodesView.h"


@implementation IFNodesView

- (id)initWithFrame:(NSRect)frame;
{
  if (![super initWithFrame:frame])
    return nil;
  
  grabableViewMixin = [[IFGrabableViewMixin alloc] initWithView:self];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(grabableViewMixin);
  [super dealloc];
}

- (void)setDocument:(IFDocument*)newDocument {
  NSAssert(document == nil, @"document already set");
  document = newDocument;  // don't retain, to avoid cycles.
}

- (IFDocument*)document;
{
  return document;
}

- (IFTreeLayoutParameters*)layoutParameters;
{
  return layoutParameters;
}

@end
