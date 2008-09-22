//
//  IFLayerPredicateSubset.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFLayerPredicateSubset.h"


@implementation IFLayerPredicateSubset

+ (id)subsetOf:(IFLayerSet*)theSet predicate:(NSPredicate*)thePredicate;
{
  return [[[self alloc] initWithSet:theSet predicate:thePredicate] autorelease];
}

- (id)initWithSet:(IFLayerSet*)theSet predicate:(NSPredicate*)thePredicate;
{
  if (![super initWithSet:theSet])
    return nil;
  predicate = [thePredicate retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(predicate);
  [super dealloc];
}

- (BOOL)shouldContain:(CALayer*)layerCandidate;
{
  return [predicate evaluateWithObject:layerCandidate];
}

@end
