//
//  IFLayerSubsetComposites.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFLayerSubsetComposites.h"

#import "IFCompositeLayer.h"

@implementation IFLayerSubsetComposites

+ (id)compositeSubsetOf:(IFLayerSet*)theSet;
{
  return [[(IFLayerSubset*)[self alloc] initWithSet:theSet] autorelease];
}

- (BOOL)shouldContain:(IFLayer*)layerCandidate;
{
  return [layerCandidate isKindOfClass:[IFCompositeLayer class]];
}

@end
