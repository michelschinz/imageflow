//
//  IFLayerGroupExplicit.m
//  ImageFlow
//
//  Created by Michel Schinz on 08.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFLayerSetExplicit.h"


@implementation IFLayerSetExplicit

+ (id)layerSet;
{
  return [self layerSetWithLayers:[NSArray array]];
}

+ (id)layerSetWithLayers:(NSArray*)theLayers;
{
  return [[[self alloc] initWithLayers:theLayers] autorelease];
}

- (id)init;
{
  return [self initWithLayers:[NSArray array]];
}

- (id)initWithLayers:(NSArray*)theLayers;
{
  if (![super init])
    return nil;
  layers = [[NSMutableArray arrayWithArray:theLayers] retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(layers);
  [super dealloc];
}

- (CALayer*)firstLayer;
{
  return [layers count] > 0 ? [layers objectAtIndex:0] : nil;
}

- (CALayer*)lastLayer;
{
  return [layers lastObject];
}

- (CALayer*)layerAtIndex:(int)index;
{
  return [layers objectAtIndex:index];
}

- (void)addLayer:(CALayer*)layer;
{
  [layers addObject:layer];
}

- (void)addLayersFromGroup:(IFLayerSet*)group;
{
  for (CALayer* layer in group)
    [layers addObject:layer];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state objects:(id*)stackbuf count:(NSUInteger)len;
{
  return [layers countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end
