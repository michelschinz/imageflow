//
//  IFPaletteView2.m
//  ImageFlow
//
//  Created by Michel Schinz on 22.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFPaletteView2.h"

#import "IFTreeTemplateManager.h"
#import "IFTreeTemplate.h"
#import "IFNodeCompositeLayer.h"
#import "IFLayoutParameters.h"
#import "IFPaletteLayoutManager.h"
#import "IFNodeLayer.h"
#import "IFLayerSetExplicit.h"
#import "IFLayerSubsetComposites.h"

static NSString* IFTreePboardType = @"IFTreePboardType";

@interface IFPaletteView2 (Private)
@property(readonly) IFLayerSet* nodeLayers;
- (void)syncLayersWithTemplates;
- (NSArray*)computeTemplates;
@property(retain) NSArray* templates;
- (IFTreeTemplate*)templateContainingNode:(IFTreeNode*)node;
@property(retain) NSArray* normalModeTrees;
- (NSArray*)computeNormalModeTrees;
- (void)updateBounds;
@end

@implementation IFPaletteView2

static NSString* IFTreeTemplatesDidChangeContext = @"IFTreeTemplatesDidChangeContext";

- (id)initWithFrame:(NSRect)theFrame;
{
  if (![super initWithFrame:theFrame])
    return nil;
  grabableViewMixin = [[IFGrabableViewMixin alloc] initWithView:self];
  
  templates = [[self computeTemplates] retain];
  normalModeTrees = nil;
  acceptFirstResponder = NO;
  
  [self updateBounds];
  [self registerForDraggedTypes:[NSArray arrayWithObject:IFTreePboardType]];
  [[IFTreeTemplateManager sharedManager] addObserver:self forKeyPath:@"templates" options:0 context:IFTreeTemplatesDidChangeContext];
  
  return self;
}

- (void)dealloc;
{
  [[IFTreeTemplateManager sharedManager] removeObserver:self forKeyPath:@"templates"];
  
  OBJC_RELEASE(normalModeTrees);
  OBJC_RELEASE(templates);
  OBJC_RELEASE(grabableViewMixin);
  [super dealloc];
}

- (void)awakeFromNib;
{
  CALayer* rootLayer = [CALayer layer];
  
  const IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  rootLayer.backgroundColor = layoutParameters.backgroundColor;
  
  IFPaletteLayoutManager* rootLayoutManager = [IFPaletteLayoutManager paletteLayoutManager];
  rootLayoutManager.delegate = self;
  rootLayer.layoutManager = rootLayoutManager;
  
  self.layer = rootLayer;
  self.wantsLayer = YES;
  
  self.enclosingScrollView.wantsLayer = YES;
  self.enclosingScrollView.contentView.wantsLayer = YES;
  
  [self syncLayersWithTemplates];
}

@synthesize delegate;

// MARK: First responder

- (BOOL)acceptsFirstResponder;
{
  return YES;
}

- (BOOL)becomeFirstResponder;
{
  if (acceptFirstResponder) {
    return [super becomeFirstResponder];
  } else
    return NO;
}

- (BOOL)resignFirstResponder;
{
  acceptFirstResponder = NO;
  return [super resignFirstResponder];
}

// MARK: Event handing

- (void)mouseDown:(NSEvent*)event;
{
  if ([grabableViewMixin handlesMouseDown:event])
    return;
}

- (void)mouseDragged:(NSEvent*)event;
{
  if ([grabableViewMixin handlesMouseDragged:event])
    return;
  
  CGPoint localPoint = NSPointToCGPoint([self convertPoint:[event locationInWindow] fromView:nil]);
  IFCompositeLayer* draggedLayer = (IFCompositeLayer*)[self.nodeLayers hitTest:localPoint];
  
  if (draggedLayer == nil)
    return;
  
  IFTreeTemplate* template = [self templateContainingNode:[draggedLayer node]];
  NSPasteboard* pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
  [pboard declareTypes:[NSArray arrayWithObject:IFTreePboardType] owner:self];
  [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:[template tree]] forType:IFTreePboardType];
  
  IFNodeLayer* nodeLayer = (IFNodeLayer*)draggedLayer.baseLayer;
  [self dragImage:nodeLayer.dragImage at:NSPointFromCGPoint(draggedLayer.frame.origin) offset:NSZeroSize event:event pasteboard:pboard source:self slideBack:YES];    
}

- (void)mouseUp:(NSEvent*)event;
{
  if ([grabableViewMixin handlesMouseUp:event])
    return;
  
  acceptFirstResponder = YES;
  [self.window makeFirstResponder:self];
  
  CGPoint localPoint = NSPointToCGPoint([self convertPoint:[event locationInWindow] fromView:nil]);
  IFCompositeLayer* layerUnderMouse = (IFCompositeLayer*)[self.nodeLayers hitTest:localPoint];
  if (layerUnderMouse == nil)
    return;
  [cursors moveToNode:layerUnderMouse.node];
}

// MARK: Drag & drop

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

// MARK: Misc. callbacks

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context;
{
  if (context == IFTreeTemplatesDidChangeContext) {
    [self setTemplates:[self computeTemplates]];
    self.normalModeTrees = [self computeNormalModeTrees];
    [self syncLayersWithTemplates];
  } else
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)layoutManager:(IFPaletteLayoutManager*)layoutManager didLayoutSublayersOfLayer:(CALayer*)layer;
{
  [self updateBounds];
}

@end

@implementation IFPaletteView2 (Private)

- (IFLayerSet*)nodeLayers;
{
  return [IFLayerSubsetComposites compositeSubsetOf:[IFLayerSetExplicit layerSetWithLayers:self.layer.sublayers]];
}

- (void)syncLayersWithTemplates;
{
  NSMutableDictionary* existingNodeLayers = createMutableDictionaryWithRetainedKeys();
  
  for (IFCompositeLayer* layer in self.nodeLayers)
    CFDictionarySetValue((CFMutableDictionaryRef)existingNodeLayers, [layer valueForKey:@"template"], layer);

  NSArray* trees = self.normalModeTrees;
  int i = 0;
  for (IFTree* template in templates) {
    if ([existingNodeLayers objectForKey:template] != nil)
      [existingNodeLayers removeObjectForKey:template];
    else {
      CALayer* newLayer = [IFNodeCompositeLayer layerForNode:((IFTree*)[trees objectAtIndex:i]).root];
      [newLayer setValue:template forKey:@"template"];
      [self.layer addSublayer:newLayer];
    }
    ++i;
  }
  
  for (CALayer* layer in [existingNodeLayers objectEnumerator])
    [layer removeFromSuperlayer];
}

// MARK: Templates

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
  int i = 0;
  for (IFTree* tree in normalModeTrees) {
    if (tree.root == node)
      return [templates objectAtIndex:i];
    ++i;
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

// MARK: View size

- (void)updateBounds;
{
  IFLayerSet* allLayers = self.nodeLayers;
  NSSize newSize = NSSizeFromCGSize(allLayers.boundingBox.size);
  NSSize minSize = self.superview.frame.size;

  newSize.width = round(minSize.width);
  newSize.height = round(fmax(newSize.height, minSize.height));
  
  if (!NSEqualSizes(self.frame.size, newSize))
    [self setFrameSize:newSize];
}

@end

