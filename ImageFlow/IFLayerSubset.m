//
//  IFLayerSubset.m
//  ImageFlow
//
//  Created by Michel Schinz on 14.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFLayerSubset.h"


@implementation IFLayerSubset

- (id)initWithSet:(IFLayerSet*)theSet;
{
  if (![super init])
    return nil;
  set = [theSet retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(set);
  [super dealloc];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state objects:(id*)stackbuf count:(NSUInteger)len;
{
  if (state->state == 0) {
    NSMutableArray* filteredSet = [NSMutableArray array];
    for (IFLayer* candidate in set) {
      if ([self shouldContain:candidate])
        [filteredSet addObject:candidate];
    }
    state->state = (long)[[filteredSet objectEnumerator] retain];
  }
  
  NSEnumerator* enumerator = (NSEnumerator*)state->state;
  IFLayer* layer;
  NSUInteger count = 0;
  while ((count < len) && (layer = [enumerator nextObject]))
      stackbuf[count++] = layer;
  if (count == 0) {
    [enumerator release];
    state->state = 0;
  }

  state->itemsPtr = stackbuf;
  state->mutationsPtr = (unsigned long*)self;
  return count;
}

- (BOOL)shouldContain:(IFLayer*)layerCandidate;
{
  [self doesNotRecognizeSelector:_cmd];
  return NO;
}

@end
