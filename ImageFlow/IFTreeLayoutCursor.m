//
//  IFTreeLayoutCursor.m
//  ImageFlow
//
//  Created by Michel Schinz on 16.08.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFTreeLayoutCursor.h"
#import "IFTreeView.h"

@implementation IFTreeLayoutCursor

const float CURSOR_WIDTH = 3.0;

+ (id)layoutCursorWithBase:(IFTreeLayoutSingle*)theBase;
{
  return [[[self alloc] initWithBase:theBase] autorelease];
}

- (id)initWithBase:(IFTreeLayoutSingle*)theBase;
{
  if (![super initWithBase:theBase])
    return nil;
  cursorPath = [[base outlinePath] copy];
  [cursorPath setLineWidth:CURSOR_WIDTH];
  [self setBounds:NSInsetRect([cursorPath bounds],-CURSOR_WIDTH,-CURSOR_WIDTH)];
  return self;
}

- (void) dealloc;
{
  [cursorPath release];
  cursorPath = nil;
  [super dealloc];
}

- (void)drawForLocalRect:(NSRect)rect;
{
  [[containingView cursorColor] set];
  [cursorPath stroke];
}

@end
