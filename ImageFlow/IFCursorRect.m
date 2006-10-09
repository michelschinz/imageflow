//
//  IFCursorRect.m
//  ImageFlow
//
//  Created by Michel Schinz on 31.08.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFCursorRect.h"


@implementation IFCursorRect

+ (id)cursor:(NSCursor*)theCursor rect:(NSRect)theRect;
{
  return [[[self alloc] initWithCursor:theCursor rect:theRect] autorelease];
}

- (id)initWithCursor:(NSCursor*)theCursor rect:(NSRect)theRect;
{
  if (![super init])
    return nil;
  cursor = [theCursor retain];
  rect = theRect;
  return self;
}

- (NSCursor*)cursor;
{
  return cursor;
}

- (NSRect)rect;
{
  return rect;
}

@end
