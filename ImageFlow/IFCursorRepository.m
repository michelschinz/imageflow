//
//  IFCursorRepository.m
//  ImageFlow
//
//  Created by Michel Schinz on 15.09.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFCursorRepository.h"


@implementation IFCursorRepository

static IFCursorRepository* sharedRepository = nil;

+ (id)sharedRepository;
{
  if (sharedRepository == nil)
    sharedRepository = [IFCursorRepository new];
  return sharedRepository;
}

- (void)dealloc;
{
  [moveCursor release];
  moveCursor = nil;
  [super dealloc];
}

- (NSCursor*)moveCursor;
{
  if (moveCursor == nil) {
    NSImage* moveCursorImage = [NSImage imageNamed:@"cursor_move"];
    moveCursor = [[NSCursor alloc] initWithImage:moveCursorImage hotSpot:NSMakePoint(7,7)];
  }
  return moveCursor;
}

@end
