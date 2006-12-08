//
//  IFNodesView.m
//  ImageFlow
//
//  Created by Michel Schinz on 08.12.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFNodesView.h"
#import "IFTreeLayoutComposite.h"

@interface IFNodesView (Private)
- (void)enqueueLayoutNotification;
- (void)updateLayout:(NSNotification*)notification;
@end

@implementation IFNodesView

static NSString* IFNodesViewNeedsLayout = @"IFNodesViewNeedsLayout";

- (id)initWithFrame:(NSRect)frame layersCount:(int)layersCount;
{
  if (![super initWithFrame:frame])
    return nil;
  grabableViewMixin = [[IFGrabableViewMixin alloc] initWithView:self];
  upToDateLayers = 0;
  layoutLayers = [NSMutableArray new];
  for (int i = 0; i < layersCount; ++i)
    [layoutLayers addObject:[IFTreeLayoutComposite layoutComposite]];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLayout:) name:IFNodesViewNeedsLayout object:self];

  return self;
}

- (void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  OBJC_RELEASE(layoutLayers);
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

- (void)drawRect:(NSRect)rect;
{
  [[layoutParameters backgroundColor] set];
  [NSBezierPath fillRect:rect];
  
  for (int i = 0; i < [layoutLayers count]; ++i) {
    if (upToDateLayers & (1 << i))
      [[layoutLayers objectAtIndex:i] drawForRect:rect];
    else
      [self enqueueLayoutNotification];
  }
}

- (IFTreeLayoutElement*)layoutLayerAtIndex:(int)index;
{
  return [layoutLayers objectAtIndex:index];
}

- (IFTreeLayoutElement*)layoutElementAtPoint:(NSPoint)point;
{
  NSEnumerator* layerEnum = [layoutLayers reverseObjectEnumerator];
  IFTreeLayoutElement* layer;
  while (layer = [layerEnum nextObject]) {
    IFTreeLayoutElement* maybeElement = [layer layoutElementAtPoint:point];
    if (maybeElement != nil)
      return maybeElement;
  }
  return nil;
}

- (IFTreeLayoutElement*)layoutElementAtPoint:(NSPoint)point inLayerAtIndex:(int)layerIndex;
{
  return [[layoutLayers objectAtIndex:layerIndex] layoutElementAtPoint:point];
}

- (IFTreeLayoutElement*)layoutForLayer:(int)layer;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (void)invalidateLayout;
{
  upToDateLayers = 0;
  [self enqueueLayoutNotification];  
}

- (void)invalidateLayoutLayer:(int)layoutLayer;
{
  upToDateLayers &= ~(1 << layoutLayer);
  [self enqueueLayoutNotification];
}

- (void)layoutDidChange;
{
  // do nothing by default (meant to be overridden)
}

@end

@implementation IFNodesView (Private)

- (void)enqueueLayoutNotification;
{
  [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:IFNodesViewNeedsLayout object:self]
                                             postingStyle:NSPostASAP
                                             coalesceMask:NSNotificationCoalescingOnName
                                                 forModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode,NSEventTrackingRunLoopMode,nil]];
}

- (void)updateLayout:(NSNotification*)notification;
{
  for (int layer = 0, count = [layoutLayers count]; layer < count; ++layer) {
    if (upToDateLayers & (1 << layer))
      continue;
    [self setNeedsDisplayInRect:[[layoutLayers objectAtIndex:layer] frame]];
    [layoutLayers replaceObjectAtIndex:layer withObject:[self layoutForLayer:layer]];
    upToDateLayers |= (1 << layer);
    [self setNeedsDisplayInRect:[[layoutLayers objectAtIndex:layer] frame]];
  }
  [self layoutDidChange];
}

@end
