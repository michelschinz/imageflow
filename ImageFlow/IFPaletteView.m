//
//  IFPaletteView.m
//  ImageFlow
//
//  Created by Michel Schinz on 22.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFPaletteView.h"

#import "IFTreeTemplateManager.h"
#import "IFTreeTemplate.h"
#import "IFNodeCompositeLayer.h"
#import "IFLayoutParameters.h"
#import "IFPaletteLayoutManager.h"
#import "IFNodeLayer.h"
#import "IFTemplateLayer.h"
#import "IFLayerSetExplicit.h"
#import "IFLayerSubsetComposites.h"
#import "IFLayerPredicateSubset.h"
#import "IFUnsplittableTreeCursorPair.h"
#import "IFLayerGeometry.h"
#import "IFVariableKVO.h"

static NSString* IFTreePboardType = @"IFTreePboardType";

@interface IFPaletteView ()
@property IFPaletteViewMode mode;
@property(readonly) IFLayerSet* templateLayers;
@property(readonly) IFLayerSet* visibleTemplateLayers;
@property(readonly) IFTemplateLayer* cursorLayer;
- (void)syncLayersWithTemplates;
- (void)updateCursorLayers;
- (void)updateFiltering;
- (NSArray*)computeTemplates;
@property(retain) NSArray* templates;
- (void)updateBounds;
- (void)moveToNodeRepresentedBy:(IFTemplateLayer*)layer;
- (void)moveToClosestNodeInDirection:(IFDirection)direction;
@end

@implementation IFPaletteView

static NSString* IFPreviewModeFilterStringDidChangeContext = @"IFPreviewModeFilterStringDidChangeContext";
static NSString* IFTreeTemplatesDidChangeContext = @"IFTreeTemplatesDidChangeContext";
static NSString* IFVisualisedCursorDidChangeContext = @"IFVisualisedCursorDidChangeContext";

- (id)initWithFrame:(NSRect)theFrame;
{
  if (![super initWithFrame:theFrame])
    return nil;
  grabableViewMixin = [[IFGrabableViewMixin alloc] initWithView:self];
  
  mode = IFPaletteViewModeNormal;
  cursors = [[IFUnsplittableTreeCursorPair unsplittableTreeCursorPair] retain];
  templates = [[self computeTemplates] retain];
  acceptFirstResponder = NO;
  
  [self registerForDraggedTypes:[NSArray arrayWithObject:IFTreePboardType]];
  [[IFTreeTemplateManager sharedManager] addObserver:self forKeyPath:@"templates" options:0 context:IFTreeTemplatesDidChangeContext];
  [self addObserver:self forKeyPath:@"previewModeFilterString" options:0 context:IFPreviewModeFilterStringDidChangeContext];
  [self addObserver:self forKeyPath:@"visualisedCursor.viewLockedNode" options:0 context:IFVisualisedCursorDidChangeContext];
  
  return self;
}

- (void)dealloc;
{
  [self removeObserver:self forKeyPath:@"visualisedCursor.viewLockedNode"];
  [self removeObserver:self forKeyPath:@"previewModeFilterString"];
  [[IFTreeTemplateManager sharedManager] removeObserver:self forKeyPath:@"templates"];
  
  OBJC_RELEASE(normalModeTrees);
  OBJC_RELEASE(templates);
  OBJC_RELEASE(visualisedCursor);
  OBJC_RELEASE(cursors);
  OBJC_RELEASE(previewModeFilterString);
  OBJC_RELEASE(grabableViewMixin);
  [super dealloc];
}

- (void)awakeFromNib;
{
  CALayer* rootLayer = [CALayer layer];
  
  rootLayer.backgroundColor = [IFLayoutParameters backgroundColor];
  
  IFPaletteLayoutManager* rootLayoutManager = [IFPaletteLayoutManager paletteLayoutManager];
  rootLayoutManager.delegate = self;
  rootLayer.layoutManager = rootLayoutManager;
  
  self.layer = rootLayer;
  self.wantsLayer = YES;
  
  self.enclosingScrollView.wantsLayer = YES;
  self.enclosingScrollView.contentView.wantsLayer = YES;
}

@synthesize cursors, visualisedCursor;
@synthesize delegate;

@synthesize document;
- (void)setDocument:(IFDocument*)newDocument;
{
  IFPaletteLayoutManager* layoutManager = (IFPaletteLayoutManager*)self.layer.layoutManager;
  layoutManager.layoutParameters = newDocument.layoutParameters;

  document = newDocument;
  
  self.layer.sublayers = [NSArray array];
  [self syncLayersWithTemplates];
}

// MARK: Normal/preview modes

- (void)switchToPreviewModeForNode:(IFTreeNode*)node;
{
  IFTree* tree = document.tree;
  IFVariable* canvasBoundsVar = [IFVariableKVO variableWithKVOCompliantObject:document key:@"canvasBounds"];
  
  for (IFTemplateLayer* templateLayer in self.templateLayers)
    [templateLayer switchToPreviewModeForNode:node ofTree:tree canvasBounds:canvasBoundsVar];
  [self updateFiltering];
  
  self.mode = IFPaletteViewModePreview;
}

- (void)switchToNormalMode;
{
  for (IFTemplateLayer* templateLayer in self.templateLayers)
    [templateLayer switchToNormalMode];
  self.mode = IFPaletteViewModeNormal;
}

@synthesize mode;
@synthesize previewModeFilterString;

- (IFTreeTemplate*)selectedTreeTemplate;
{
  const IFTreeNode* cursorNode = cursors.node;
  for (IFTemplateLayer* layer in self.visibleTemplateLayers) {
    if (layer.treeNode == cursorNode)
      return layer.treeTemplate;
  }
  return nil;
}

- (BOOL)selectPreviousTreeTemplate;
{
  const IFTreeNode* cursorNode = cursors.node;
  IFTemplateLayer* prev = (IFTemplateLayer*)self.visibleTemplateLayers.lastLayer;
  for (IFTemplateLayer* layer in self.visibleTemplateLayers) {
    if (layer.treeNode == cursorNode) {
      [cursors setTree:prev.tree node:prev.treeNode path:[IFArrayPath emptyPath]]; // FIXME: compute correct path based on type
      [self updateCursorLayers];
      return YES;
    }
    prev = layer;
  }
  return NO;
}

- (BOOL)selectNextTreeTemplate;
{
  const IFTreeNode* cursorNode = cursors.node;
  BOOL selectNext = NO;
  for (IFTemplateLayer* layer in self.visibleTemplateLayers) {
    if (selectNext) {
      [cursors setTree:layer.tree node:layer.treeNode path:[IFArrayPath emptyPath]]; // FIXME: compute correct path based on type
      [self updateCursorLayers];
      return YES;
    } else if (layer.treeNode == cursorNode)
      selectNext = YES;
    else
      ;
  }
  if (selectNext) {
    IFTemplateLayer* firstLayer = (IFTemplateLayer*)self.visibleTemplateLayers.firstLayer;
    [cursors setTree:firstLayer.tree node:firstLayer.treeNode path:[IFArrayPath emptyPath]];
  }
  return selectNext;
}

// MARK: First responder

- (BOOL)acceptsFirstResponder;
{
  return YES;
}

- (BOOL)becomeFirstResponder;
{
  return (acceptFirstResponder && [super becomeFirstResponder]);
}

- (BOOL)resignFirstResponder;
{
  acceptFirstResponder = NO;
  return [super resignFirstResponder];
}

// MARK: Event handing

- (void)moveUp:(id)sender;
{
  [self moveToClosestNodeInDirection:IFUp];
}

- (void)moveDown:(id)sender;
{
  [self moveToClosestNodeInDirection:IFDown];
}

- (void)moveLeft:(id)sender;
{
  [self selectPreviousTreeTemplate];
}

- (void)moveRight:(id)sender;
{
  [self selectNextTreeTemplate];
}

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
  IFTemplateLayer* draggedLayer = (IFTemplateLayer*)[self.visibleTemplateLayers hitTest:localPoint];
  
  if (draggedLayer == nil)
    return;
  
  IFTreeTemplate* template = draggedLayer.treeTemplate;
  NSPasteboard* pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
  [pboard declareTypes:[NSArray arrayWithObject:IFTreePboardType] owner:self];
  [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:template.tree] forType:IFTreePboardType];
  
  [self dragImage:draggedLayer.dragImage at:NSPointFromCGPoint(draggedLayer.frame.origin) offset:NSZeroSize event:event pasteboard:pboard source:self slideBack:YES];    
}

- (void)mouseUp:(NSEvent*)event;
{
  if ([grabableViewMixin handlesMouseUp:event])
    return;
  
  acceptFirstResponder = YES;
  [self.window makeFirstResponder:self];
  
  CGPoint localPoint = NSPointToCGPoint([self convertPoint:[event locationInWindow] fromView:nil]);
  IFTemplateLayer* layerUnderMouse = (IFTemplateLayer*)[self.visibleTemplateLayers hitTest:localPoint];
  if (layerUnderMouse == nil)
    return;

  [self moveToNodeRepresentedBy:layerUnderMouse];
  [delegate paletteViewWillBecomeActive:self];
}

// MARK: Drag & drop

// Dragging source

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal;
{
  return NSDragOperationCopy; // TODO: add NSDragOperationDelete, which implies implementing imageEndedAt...
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
  if (context == IFPreviewModeFilterStringDidChangeContext) {
    [self updateFiltering];
  } else if (context == IFVisualisedCursorDidChangeContext) {
    [self updateCursorLayers];
  } else if (context == IFTreeTemplatesDidChangeContext) {
    [self setTemplates:[self computeTemplates]];
    [self syncLayersWithTemplates];
  } else
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)layoutManager:(IFPaletteLayoutManager*)layoutManager didLayoutSublayersOfLayer:(CALayer*)layer;
{
  [self updateBounds];
}

// MARK: -
// MARK: PRIVATE

- (IFLayerSet*)templateLayers;
{
  return [IFLayerSetExplicit layerSetWithLayers:self.layer.sublayers];
}

- (IFLayerSet*)visibleTemplateLayers;
{
  return [IFLayerPredicateSubset subsetOf:self.templateLayers predicate:[NSPredicate predicateWithFormat:@"hidden == NO"]];
}

- (IFTemplateLayer*)cursorLayer;
{
  IFTreeNode* cursorNode = cursors.node;
  for (IFTemplateLayer* layer in self.visibleTemplateLayers) {
    if (layer.treeNode == cursorNode)
      return layer;
  }
  return nil;
}

- (void)syncLayersWithTemplates;
{
  NSMutableDictionary* existingTemplateLayers = [createMutableDictionaryWithRetainedKeys() autorelease];
  
  for (IFTemplateLayer* layer in self.templateLayers)
    CFDictionarySetValue((CFMutableDictionaryRef)existingTemplateLayers, layer.treeTemplate, layer);

  for (IFTreeTemplate* treeTemplate in templates) {
    if ([existingTemplateLayers objectForKey:treeTemplate] != nil)
      [existingTemplateLayers removeObjectForKey:treeTemplate];
    else
      [self.layer addSublayer:[IFTemplateLayer layerForTemplate:treeTemplate layoutParameters:document.layoutParameters]];
  }
  
  for (CALayer* layer in [existingTemplateLayers objectEnumerator])
    [layer removeFromSuperlayer];
}

- (void)updateCursorLayers;
{
  IFTree* cursorTree = visualisedCursor.tree;
  IFTreeNode* cursorNode = visualisedCursor.node;
  
  IFTree* displayedTree = visualisedCursor.viewLockedTree;
  IFTreeNode* displayedNode = visualisedCursor.viewLockedNode;

  for (IFTemplateLayer* layer in self.templateLayers) {
    IFNodeCompositeLayer* nodeLayer = layer.nodeCompositeLayer;
    nodeLayer.cursorIndicator = ((layer.tree == cursorTree && layer.treeNode == cursorNode) ? IFLayerCursorIndicatorCursor : IFLayerCursorIndicatorNone) ;
    nodeLayer.displayedImageLayer.hidden = !(layer.tree == displayedTree && layer.treeNode == displayedNode);
  }
}

- (void)updateFiltering;
{
  BOOL emptyFilter = (previewModeFilterString == nil || [previewModeFilterString isEqualToString:@""]);
  for (IFTemplateLayer* layer in self.templateLayers)
    layer.filterOut = !emptyFilter && [layer.treeTemplate.name rangeOfString:previewModeFilterString options:(NSCaseInsensitiveSearch | NSAnchoredSearch)].location == NSNotFound;

  for (IFTemplateLayer* layer in self.templateLayers) {
    if (!layer.hidden) {
      [cursors setTree:layer.tree node:layer.treeNode path:[IFArrayPath emptyPath]]; // FIXME: compute correct path based on type
      break;
    }
  }
  [self updateCursorLayers];
  
  [self.layer setNeedsLayout];
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

@synthesize templates;

// MARK: View size

- (void)updateBounds;
{
  IFLayerSet* allLayers = self.visibleTemplateLayers;
  NSSize newSize = NSSizeFromCGSize(allLayers.boundingBox.size);
  NSSize minSize = self.superview.frame.size;

  newSize.width = round(fmax(newSize.width, minSize.width));
  newSize.height = round(fmax(newSize.height, minSize.height));
  
  if (!NSEqualSizes(self.frame.size, newSize))
    [self setFrameSize:newSize];
}

// MARK: Cursor movement

- (void)moveToNodeRepresentedBy:(IFTemplateLayer*)layer;
{
  [cursors setTree:layer.tree node:layer.treeNode path:[IFArrayPath emptyPath]]; // FIXME: compute path based on type
  [self scrollRectToVisible:NSRectFromCGRect(layer.frame)];
}

- (void)moveToClosestNodeInDirection:(IFDirection)direction;
{
  CALayer* closestLayer = closestLayerInDirection(self.cursorLayer, [self.visibleTemplateLayers toArray], direction);
  if (closestLayer != nil)
    [self moveToNodeRepresentedBy:(IFTemplateLayer*)closestLayer];
  else
    NSBeep();
}

@end

