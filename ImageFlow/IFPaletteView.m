//
//  IFPaletteView.m
//  ImageFlow
//
//  Created by Michel Schinz on 08.12.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFPaletteView.h"
#import "IFTreeNodeFilter.h"
#import "IFTreeLayoutNode.h"
#import "IFTreeLayoutComposite.h"
#import "IFVariableExpression.h"
#import "IFTreeTemplateManager.h"

@interface IFPaletteView (Private)
- (IFTreeTemplate*)templateContainingNode:(IFTreeNode*)node;
- (NSArray*)normalModeTrees;
- (void)setNormalModeTrees:(NSArray*)newNormalModeTrees;
- (NSArray*)computeNormalModeTrees;

- (void)updateBounds;
- (IFTreeLayoutElement*)layoutForNode:(IFTreeNode*)node;
- (IFTreeLayoutElement*)layoutForTrees:(NSArray*)allTrees;
@end

@implementation IFPaletteView

enum IFLayoutLayer {
  IFLayoutLayerNodes
};

- (id)initWithFrame:(NSRect)frame;
{
  if (![super initWithFrame:frame layersCount:1])
    return nil;
  normalModeTrees = nil;
  [self updateBounds];
  return self;
}

- (void)dealloc;
{
  if (normalModeTrees != nil)
    OBJC_RELEASE(normalModeTrees);
  [super dealloc];
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
      return [self layoutForTrees:[self normalModeTrees]];
    default:
      NSAssert(NO, @"unexpected layer");
      return nil;
  }
}

#pragma mark Event handling

- (void)mouseDragged:(NSEvent*)event;
{
  if ([grabableViewMixin handlesMouseDragged:event])
    return;
  
  NSPoint localPoint = [self convertPoint:[event locationInWindow] fromView:nil];
  IFTreeLayoutElement* elementUnderMouse = [self layoutElementAtPoint:localPoint];
  
  IFTreeTemplate* template = [self templateContainingNode:[elementUnderMouse node]];
  NSPasteboard* pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
  [pboard declareTypes:[NSArray arrayWithObject:IFTreePboardType] owner:self];
  [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:[template tree]] forType:IFTreePboardType];

  [self dragImage:[elementUnderMouse dragImage] at:[elementUnderMouse frame].origin offset:NSZeroSize event:event pasteboard:pboard source:self slideBack:YES];    
}

@end

@implementation IFPaletteView (Private)

- (IFTreeTemplate*)templateContainingNode:(IFTreeNode*)node;
{
  for (int i = 0; i < [normalModeTrees count]; ++i) {
    IFTree* tree = [normalModeTrees objectAtIndex:i];
    if ([tree root] == node)
      return [[[IFTreeTemplateManager sharedManager] templates] objectAtIndex:i];
  }
  return nil;
}

- (NSArray*)normalModeTrees;
{
  if (normalModeTrees == nil)
    [self setNormalModeTrees:[self computeNormalModeTrees]];
  return normalModeTrees;
}

- (void)setNormalModeTrees:(NSArray*)newNormalModeTrees;
{
  if (newNormalModeTrees == normalModeTrees)
    return;
  [normalModeTrees release];
  normalModeTrees = [newNormalModeTrees retain];
}

- (NSArray*)computeNormalModeTrees;
{
  NSArray* templates = [[IFTreeTemplateManager sharedManager] templates];
  NSMutableArray* trees = [NSMutableArray arrayWithCapacity:[templates count]];
  for (int i = 0; i < [templates count]; ++i) {
    IFTree* templateTree = [[templates objectAtIndex:i] tree];
    unsigned parentsCount = [templateTree holesCount];
    IFTree* hostTree = [IFTree tree];
    IFTreeNode* ghost = [IFTreeNode ghostNodeWithInputArity:parentsCount];
    [hostTree addNode:ghost];
    for (int j = 0; j < parentsCount; ++j) {
      IFTreeNode* parent = [IFTreeNode universalSourceWithIndex:j];
      [hostTree addNode:parent];
      [hostTree addEdgeFromNode:parent toNode:ghost withIndex:j];
    }
    [hostTree copyTree:templateTree toReplaceNode:ghost];
    
    [hostTree configureNodes];
    [hostTree setPropagateNewParentExpressions:YES];
    
    [trees addObject:hostTree];
  }
  return trees;
}

- (void)updateBounds;
{
  IFTreeLayoutElement* nodesLayer = [self layoutLayerAtIndex:IFLayoutLayerNodes];
  NSSize containingFrameSize = [[self superview] frame].size;
  NSSize selfFrameSize = [nodesLayer frame].size;
  [self setFrameSize:NSMakeSize(containingFrameSize.width,fmax(selfFrameSize.height,containingFrameSize.height))];
  [self invalidateLayout];
}

- (IFTreeLayoutElement*)layoutForNode:(IFTreeNode*)node;
{
  return [IFTreeLayoutNode layoutNodeWithNode:node containingView:self];
}

- (IFTreeLayoutElement*)layoutForTrees:(NSArray*)allTrees;
{
  if ([allTrees count] == 0)
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
  for (int i = 0, count = [allTrees count]; i < count; ++i) {
    IFTreeLayoutElement* layoutElement = [self layoutForNode:[[allTrees objectAtIndex:i] root]];
    [layoutElement translateBy:NSMakePoint(x,0)];
    [currentRow addObject:layoutElement];
    maxHeight = fmax(maxHeight, NSHeight([layoutElement frame]));

    if ((i + 1) % (int)columns == 0 || i + 1 == count) {
      [[rows do] translateBy:NSMakePoint(0,maxHeight + yMargin)];
      [rows addObject:[IFTreeLayoutComposite layoutCompositeWithElements:currentRow containingView:self]];
      currentRow = [NSMutableSet set];
  
      x = gutter;
      y += maxHeight;
      maxHeight = 0.0;
    } else {
      x += columnWidth + gutter;
    }
  }
  
  return [IFTreeLayoutComposite layoutCompositeWithElements:rows containingView:self];
}

@end
