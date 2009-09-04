//
//  IFNodeCompositeLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 16.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFNodeCompositeLayer.h"
#import "IFNodeLayer.h"
#import "IFGhostNodeLayer.h"
#import "IFLayoutParameters.h"

@implementation IFNodeCompositeLayer

+ (id)layerForNode:(IFTreeNode*)theNode ofTree:(IFTree*)theTree layoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
{
  return [[[self alloc] initWithNode:theNode ofTree:theTree layoutParameters:theLayoutParameters canvasBounds:theCanvasBoundsVar] autorelease];
}

- (id)initWithNode:(IFTreeNode*)theNode ofTree:(IFTree*)theTree layoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
{
  if (![super init])
    return nil;

  self.zPosition = 1.0;
  
  // Displayed image indicator
  displayedImageLayer = [CALayer layer];
  displayedImageLayer.anchorPoint = CGPointZero;
  displayedImageLayer.backgroundColor = [IFLayoutParameters displayedImageUnlockedBackgroundColor];
  displayedImageLayer.hidden = YES;
  [self addSublayer:displayedImageLayer];
  
  // Base layer
  baseLayer = theNode.isGhost
  ? [IFGhostNodeLayer layerForNode:theNode ofTree:theTree layoutParameters:theLayoutParameters canvasBounds:theCanvasBoundsVar]
  : [IFNodeLayer layerForNode:theNode ofTree:theTree layoutParameters:theLayoutParameters canvasBounds:theCanvasBoundsVar];
  [self addSublayer:baseLayer];
  
  // Cursor
  cursorLayer = [CALayer layer];
  cursorLayer.anchorPoint = CGPointZero;
  cursorLayer.cornerRadius = baseLayer.cornerRadius;
  cursorLayer.borderColor = [IFLayoutParameters cursorColor];
  cursorLayer.hidden = YES;
  [self addSublayer:cursorLayer];
  
  // Drag&drop highlight
  highlightLayer = [CALayer layer];
  highlightLayer.anchorPoint = CGPointZero;
  highlightLayer.cornerRadius = baseLayer.cornerRadius;
  highlightLayer.hidden = YES;
  highlightLayer.backgroundColor = [IFLayoutParameters highlightBackgroundColor];
  highlightLayer.borderColor = [IFLayoutParameters highlightBorderColor];
  highlightLayer.borderWidth = [IFLayoutParameters selectionWidth];
  [self addSublayer:highlightLayer];
  
  return self;
}

- (BOOL)isNode;
{
  return YES;
}

@synthesize displayedImageLayer, baseLayer, cursorLayer, highlightLayer;

- (void)setCursorIndicator:(IFLayerCursorIndicator)newIndicator;
{
  switch (newIndicator) {
    case IFLayerCursorIndicatorNone:
      cursorLayer.hidden = YES;
      break;
    case IFLayerCursorIndicatorCursor:
      cursorLayer.hidden = NO;
      cursorLayer.borderWidth = [IFLayoutParameters cursorWidth];
      break;
    case IFLayerCursorIndicatorSelection:
      cursorLayer.hidden = NO;
      cursorLayer.borderWidth = [IFLayoutParameters selectionWidth];
      break;
  }
}

- (IFLayerCursorIndicator)cursorIndicator;
{
  if (cursorLayer.hidden)
    return IFLayerCursorIndicatorNone;
  else if (cursorLayer.borderWidth == [IFLayoutParameters cursorWidth])
    return IFLayerCursorIndicatorCursor;
  else
    return IFLayerCursorIndicatorSelection;
}

- (void)layoutSublayers;
{
  CGRect baseFrame = self.baseLayer.frame;
  self.displayedImageLayer.frame = CGRectInset(baseFrame, -25, 0);
  self.cursorLayer.frame = baseFrame;
  [super layoutSublayers];
}

@end
