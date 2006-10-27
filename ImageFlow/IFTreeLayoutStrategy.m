//
//  IFTreeLayoutStrategy.m
//  ImageFlow
//
//  Created by Michel Schinz on 25.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFTreeLayoutStrategy.h"

#import "IFTreeLayoutInputConnector.h"
#import "IFTreeLayoutOutputConnector.h"
#import "IFTreeLayoutMark.h"
#import "IFTreeLayoutSidePane.h"
#import "IFTreeLayoutCursor.h"
#import "IFTreeLayoutGhost.h"
#import "IFTreeLayoutComposite.h"

@implementation IFTreeLayoutStrategy

- (id)initWithView:(IFTreeView*)theView parameters:(IFTreeLayoutParameters*)theLayoutParams;
{
  if (![super init])
    return nil;
  view = theView;
  layoutParams = [theLayoutParams retain];
  layoutNodes = createMutableDictionaryWithRetainedKeys();
  deleteButtonCell = nil;
  sidePanePath = nil;
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(sidePanePath);
  OBJC_RELEASE(deleteButtonCell);
    
  OBJC_RELEASE(layoutNodes);
  OBJC_RELEASE(layoutParams);
  [super dealloc];
}

- (IFTreeLayoutElement*)layoutTree:(IFTreeNode*)root;
{
  const float columnWidth = [layoutParams columnWidth];
  NSMutableSet* layoutElems = [NSMutableSet set];
  
  // Layout all parents
  NSArray* parents = [root isFolded] ? [NSArray array] : [root parents];
  const int parentsCount = [parents count];
  NSMutableArray* directParentsLayout = [NSMutableArray arrayWithCapacity:parentsCount];
  float x = 0.0;
  for (int i = 0; i < parentsCount; i++) {
    if (i > 0) x += [layoutParams gutterWidth];
    IFTreeNode* parent = [parents objectAtIndex:i];
    
    IFTreeLayoutElement* parentLayout = [self layoutTree:parent];
    [layoutElems addObject:parentLayout];
    [directParentsLayout addObject:[parentLayout layoutElementForNode:parent kind:IFTreeLayoutElementKindNode]];
    
    [parentLayout translateBy:NSMakePoint(x, 0)];
    x += NSWidth([parentLayout frame]);
  }
  
  // Layout output connectors, if any.
  if (parentsCount > 1) {
    float connectorsHeight = 0.0;
    IFFilter* rootFilter = [[root filter] filter];
    for (int i = 0; i < parentsCount; ++i) {
      float currLeft = NSMinX([[directParentsLayout objectAtIndex:i] frame]);
      float leftReach = (i > 0)
        ? (currLeft - NSMinX([[directParentsLayout objectAtIndex:i-1] frame]) - columnWidth) / 2.0
        : 0.0;
      float rightReach = (i < parentsCount - 1)
        ? (NSMinX([[directParentsLayout objectAtIndex:i+1] frame]) - currLeft - columnWidth) / 2.0
        : 0.0;
      
      IFTreeLayoutElement* outputConnectorLayout = [self layoutOutputConnectorForTreeNode:[parents objectAtIndex:i]
                                                                                      tag:[rootFilter nameOfParentAtIndex:i]
                                                                                leftReach:leftReach
                                                                               rightReach:rightReach];
      [outputConnectorLayout translateBy:NSMakePoint(currLeft,0)];
      [layoutElems addObject:outputConnectorLayout];
      connectorsHeight = NSHeight([outputConnectorLayout frame]);
    }
    [[layoutElems do] translateBy:NSMakePoint(0,connectorsHeight)];
  }
  
  // Layout input connector
  float rootColumnLeft;
  if (parentsCount == 0)
    rootColumnLeft = 0;
  else {
    float directParentsLeft = NSMinX([[directParentsLayout objectAtIndex:0] frame]);
    float directParentsRight = NSMaxX([[directParentsLayout lastObject] frame]);
    rootColumnLeft = directParentsLeft + (directParentsRight - directParentsLeft - columnWidth) / 2.0;
    
    IFTreeLayoutElement* inputConnectorLayout = [self layoutInputConnectorForTreeNode:root];
    [inputConnectorLayout translateBy:NSMakePoint(rootColumnLeft,0)];
    [layoutElems addObject:inputConnectorLayout];
    [[layoutElems do] translateBy:NSMakePoint(0,NSHeight([inputConnectorLayout frame]))];
  }
  
  // Layout root.
  IFTreeLayoutNode* rootLayoutElem = [self layoutNodeForTreeNode:root];
  [rootLayoutElem setTranslation:NSMakePoint(rootColumnLeft,0)];
  [[layoutElems do] translateBy:NSMakePoint(0,NSHeight([rootLayoutElem frame]))];
  
  [layoutElems addObject:rootLayoutElem];
  return [layoutElems count] > 1
    ? [IFTreeLayoutComposite layoutCompositeWithElements:layoutElems containingView:view]
    : [layoutElems anyObject];
}

- (IFTreeLayoutNode*)layoutNodeForTreeNode:(IFTreeNode*)theNode;
{
  IFTreeLayoutNode* layoutNode = [layoutNodes objectForKey:theNode];
  if (layoutNode == nil) {
    layoutNode = [IFTreeLayoutSingle layoutSingleWithNode:theNode containingView:view];
    CFDictionarySetValue((CFMutableDictionaryRef)layoutNodes, theNode, layoutNode);
  }
  return layoutNode;
}

- (IFTreeLayoutElement*)layoutInputConnectorForTreeNode:(IFTreeNode*)node;
{
  return [IFTreeLayoutInputConnector layoutConnectorWithNode:node containingView:view];
}

- (IFTreeLayoutElement*)layoutOutputConnectorForTreeNode:(IFTreeNode*)node tag:(NSString*)tag leftReach:(float)lReach rightReach:(float)rReach;
{
  return [IFTreeLayoutOutputConnector layoutConnectorWithNode:node
                                               containingView:view
                                                          tag:tag
                                                    leftReach:lReach
                                                   rightReach:rReach];
}

- (IFTreeLayoutElement*)layoutSidePaneForElement:(IFTreeLayoutSingle*)base;
{
  if (base == nil)
    return [IFTreeLayoutComposite layoutComposite];
  
  return [IFTreeLayoutSidePane layoutSidePaneWithBase:base];
}

- (IFTreeLayoutElement*)layoutSelectedNodes:(NSSet*)nodes
                                     cursor:(IFTreeNode*)cursorNode
                              forTreeLayout:(IFTreeLayoutElement*)rootLayout;
{
  NSMutableSet* result = [NSMutableSet set];
  NSSet* elements = [rootLayout layoutElementsForNodes:nodes kind:IFTreeLayoutElementKindNode];
  NSEnumerator* elemsEnumerator = [elements objectEnumerator];
  IFTreeLayoutSingle* element;
  const float cursorWidth = [layoutParams cursorWidth], selectionWidth = [layoutParams selectionWidth];
  while (element = [elemsEnumerator nextObject]) {
    BOOL isCursor = [element node] == cursorNode;
    [result addObject:[IFTreeLayoutCursor layoutCursorWithBase:element pathWidth:(isCursor ? cursorWidth : selectionWidth)]];
  }
  return [result count] == 1
    ? [result anyObject]
    : [IFTreeLayoutComposite layoutCompositeWithElements:result containingView:view];
}

- (IFTreeLayoutElement*)layoutMarks:(NSArray*)marks forTreeLayout:(IFTreeLayoutElement*)rootLayout;
{
  NSCountedSet* markedNodes = [NSCountedSet set];
  NSMutableSet* elems = [NSMutableSet set];
  unsigned int i, count = [marks count];
  for (i = 1; i < count; i++) {
    IFTreeMark *mark = [marks objectAtIndex:i];
    if (![mark isSet])
      continue;
    
    IFTreeLayoutSingle* node = [rootLayout layoutElementForNode:[mark node] kind:IFTreeLayoutElementKindNode];
    if (node == nil)
      continue;
    
    IFTreeLayoutMark* markLayout = [IFTreeLayoutMark layoutMarkWithBase:node position:[markedNodes countForObject:node] markIndex:i];
    [markedNodes addObject:node];
    [elems addObject:markLayout];
  }
  return [elems count] == 1
    ? [elems anyObject]
    : [IFTreeLayoutComposite layoutCompositeWithElements:elems containingView:view];
}

- (NSBezierPath*)sidePanePath;
{
  if (sidePanePath == nil) {
    const NSSize sidePaneSize = [layoutParams sidePaneSize];
    const float sidePaneCornerRadius = [layoutParams sidePaneCornerRadius];
    const float externalMargin = [layoutParams nodeInternalMargin];
    
    sidePanePath = [[NSBezierPath bezierPath] retain];
    [sidePanePath moveToPoint:NSMakePoint(0,externalMargin)];
    [sidePanePath lineToPoint:NSMakePoint(0,sidePaneSize.height + externalMargin)];
    [sidePanePath appendBezierPathWithArcWithCenter:NSMakePoint(-(sidePaneSize.width - sidePaneCornerRadius),
                                                                sidePaneSize.height + externalMargin - sidePaneCornerRadius)
                                             radius:sidePaneCornerRadius
                                         startAngle:90
                                           endAngle:180];
    [sidePanePath appendBezierPathWithArcWithCenter:NSMakePoint(-(sidePaneSize.width - sidePaneCornerRadius),
                                                                externalMargin + sidePaneCornerRadius)
                                             radius:sidePaneCornerRadius
                                         startAngle:180
                                           endAngle:270];
    [sidePanePath closePath];
    [sidePanePath setCachesBezierPath:YES];
  }
  return sidePanePath;
}

- (NSButtonCell*)deleteButtonCell;
{
  if (deleteButtonCell == nil) {
    deleteButtonCell = [[NSButtonCell alloc] initImageCell:[NSImage imageNamed:@"button_delete"]];
    [deleteButtonCell setAlternateImage:[NSImage imageNamed:@"button_delete_active"]];
    [deleteButtonCell setButtonType:NSMomentaryChangeButton];
    [deleteButtonCell setBordered:NO];
    [deleteButtonCell setAction:@selector(deleteNodeUnderMouse:)];
    [deleteButtonCell setTarget:self];
  }
  return deleteButtonCell;
}

@end
