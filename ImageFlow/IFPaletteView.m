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
- (NSArray*)computeTemplates;
- (NSArray*)templates;
- (void)setTemplates:(NSArray*)newTemplates;

- (IFTreeTemplate*)templateContainingNode:(IFTreeNode*)node;
- (NSArray*)normalModeTrees;
- (void)setNormalModeTrees:(NSArray*)newNormalModeTrees;
- (NSArray*)computeNormalModeTrees;

- (void)updateBounds;
- (IFTreeLayoutElement*)layoutForNode:(IFTreeNode*)node;
- (IFTreeLayoutElement*)layoutForTrees:(NSArray*)allTrees;
@end

@implementation IFPaletteView

static NSString* IFTreeTemplatesDidChangeContext = @"IFTreeTemplatesDidChangeContext";

enum IFLayoutLayer {
  IFLayoutLayerNodes
};

- (id)initWithFrame:(NSRect)frame;
{
  if (![super initWithFrame:frame layersCount:1])
    return nil;
  templates = [[self computeTemplates] retain];
  normalModeTrees = nil;

  [self updateBounds];
  [self registerForDraggedTypes:[NSArray arrayWithObject:IFTreePboardType]];
  [[IFTreeTemplateManager sharedManager] addObserver:self forKeyPath:@"templates" options:0 context:IFTreeTemplatesDidChangeContext];
  return self;
}

- (void)dealloc;
{
  if (normalModeTrees != nil)
    OBJC_RELEASE(normalModeTrees);
  OBJC_RELEASE(templates);
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
  
  if (elementUnderMouse == nil)
    return;

  IFTreeTemplate* template = [self templateContainingNode:[elementUnderMouse node]];
  NSPasteboard* pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
  [pboard declareTypes:[NSArray arrayWithObject:IFTreePboardType] owner:self];
  [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:[template tree]] forType:IFTreePboardType];

  [self dragImage:[elementUnderMouse dragImage] at:[elementUnderMouse frame].origin offset:NSZeroSize event:event pasteboard:pboard source:self slideBack:YES];    
}

#pragma mark Drag & drop

// Dragging source

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal;
{
  return NSDragOperationCopy; // TODO add NSDragOperationDelete, which implies implementing imageEndedAt...
}

// Dragging destination

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender;
{
  if ([sender draggingSource] == self)
    return NSDragOperationNone;
  return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
{
  IFTreeTemplateManager* templateManager = [IFTreeTemplateManager sharedManager];
  NSPasteboard* pboard = [sender draggingPasteboard];
  IFTree* draggedTree = [NSKeyedUnarchiver unarchiveObjectWithData:[pboard dataForType:IFTreePboardType]];
  IFTreeTemplate* newTemplate = [IFTreeTemplate templateWithName:@"template" description:@"" tree:draggedTree];
  [templateManager addTemplate:newTemplate];
  return YES;
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context;
{
  if (context == IFTreeTemplatesDidChangeContext) {
    [self setTemplates:[self computeTemplates]];
    if (normalModeTrees != nil) {
      [normalModeTrees release];
      normalModeTrees = nil;
    }
    [self invalidateLayoutLayer:IFLayoutLayerNodes];
  } else
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end

@implementation IFPaletteView (Private)

- (NSArray*)computeTemplates;
{
  NSSet* templateSet = [[IFTreeTemplateManager sharedManager] templates];
  NSMutableArray* allTemplates = [NSMutableArray arrayWithCapacity:[templateSet count]];
  for (IFTreeTemplate* treeTemplate in templateSet)
    [allTemplates addObject:treeTemplate];
  return allTemplates;
}

- (NSArray*)templates;
{
  return templates;
}

- (void)setTemplates:(NSArray*)newTemplates;
{
  if (newTemplates == templates)
    return;
  [templates release];
  templates = [newTemplates retain];
}

- (IFTreeTemplate*)templateContainingNode:(IFTreeNode*)node;
{
  for (int i = 0; i < [normalModeTrees count]; ++i) {
    IFTree* tree = [normalModeTrees objectAtIndex:i];
    if ([tree root] == node)
      return [templates objectAtIndex:i];
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
