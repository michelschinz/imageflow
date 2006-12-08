//
//  IFPaletteView.m
//  ImageFlow
//
//  Created by Michel Schinz on 08.12.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFPaletteView.h"
#import "IFTreeLayoutNode.h"
#import "IFTreeLayoutComposite.h"
#import "IFDocumentTemplateManager.h"

@interface IFPaletteView (Private)
- (void)updateBounds;
- (IFTreeLayoutElement*)layoutForTemplate:(IFDocumentTemplate*)template;
- (IFTreeLayoutElement*)layoutForTemplates:(NSArray*)allTemplates;
@end

@implementation IFPaletteView

enum IFLayoutLayer {
  IFLayoutLayerNodes,
  IFLayoutLayer
};

- (id)initWithFrame:(NSRect)frame;
{
  if (![super initWithFrame:frame layersCount:1])
    return nil;
  [self updateBounds];
  return self;
}

- (IFTreeLayoutParameters*)layoutParameters;
{
  return layoutParameters;
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize;
{
  [self updateBounds];
  [self setNeedsDisplay:YES];
}

- (IFTreeLayoutElement*)layoutForLayer:(int)layer;
{
  switch (layer) {
    case IFLayoutLayerNodes:
      return [self layoutForTemplates:[[IFDocument documentTemplateManager] templates]];
    default:
      NSAssert(NO, @"unexpected layer");
      return nil;
  }
}

@end

@implementation IFPaletteView (Private)

- (void)updateBounds;
{
  IFTreeLayoutElement* nodesLayer = [self layoutLayerAtIndex:IFLayoutLayerNodes];
  NSSize containingFrameSize = [[self superview] frame].size;
  NSSize selfFrameSize = [nodesLayer frame].size;
  [self setFrameSize:NSMakeSize(containingFrameSize.width,fmax(selfFrameSize.height,containingFrameSize.height))];
  [self invalidateLayout];
}

- (IFTreeLayoutElement*)layoutForTemplate:(IFDocumentTemplate*)template;
{
  return [IFTreeLayoutNode layoutNodeWithNode:[template node] containingView:(id)self]; // HACK
}

- (IFTreeLayoutElement*)layoutForTemplates:(NSArray*)allTemplates;
{
  if ([allTemplates count] == 0)
    return [IFTreeLayoutComposite layoutComposite];

  float columnWidth = [layoutParameters columnWidth];
  float minGutter = [layoutParameters gutterWidth];

  float totalWidth = NSWidth([[self superview] frame]);
  float columns = (int)floor((totalWidth - minGutter) / (columnWidth + minGutter));
  float gutter = round((totalWidth - (columns * columnWidth)) / (columns + 1));
  const float yMargin = 4.0;

  NSMutableSet* rows = [NSMutableSet set];
  float x = gutter, y = 0, maxHeight = 0.0;
  NSMutableSet* currentRow = [NSMutableSet new];
  for (int i = 0, count = [allTemplates count]; i < count; ++i) {
    IFTreeLayoutElement* layoutElement = [self layoutForTemplate:[allTemplates objectAtIndex:i]];
    [layoutElement translateBy:NSMakePoint(x,0)];
    [currentRow addObject:layoutElement];
    maxHeight = fmax(maxHeight, NSHeight([layoutElement frame]));

    if ((i + 1) % (int)columns == 0 || i + 1 == count) {
      [[rows do] translateBy:NSMakePoint(0,maxHeight + yMargin)];
      [rows addObject:[IFTreeLayoutComposite layoutCompositeWithElements:currentRow containingView:(id)self]]; // HACK
      currentRow = [NSMutableSet set];
  
      x = gutter;
      y += maxHeight;
      maxHeight = 0.0;
    } else {
      x += columnWidth + gutter;
    }
  }
  
  return [IFTreeLayoutComposite layoutCompositeWithElements:rows containingView:(id)self]; // HACK
}

@end
