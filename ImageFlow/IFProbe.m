//
//  IFProbe.m
//  ImageFlow
//
//  Created by Michel Schinz on 17.08.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFProbe.h"

@implementation IFProbe

+ (id)probeWithMark:(IFTreeMark*)theMark;
{
  return [[[self alloc] initWithMark:theMark] autorelease];
}

- (id)initWithMark:(IFTreeMark*)theMark;
{
  if (![super init]) return nil;
  mark = [theMark retain];
  return self;
}

- (void) dealloc {
  OBJC_RELEASE(mark);
  [super dealloc];
}

- (IFTreeMark*)mark;
{
  return mark;
}

- (void)setMark:(IFTreeMark*)newMark;
{
  if (newMark == mark) return;
  
  [mark release];
  mark = [newMark retain];
}

@end
