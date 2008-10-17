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

static NSString* IFTreePboardType = @"IFTreePboardType";

@interface IFPaletteView ()
@property IFPaletteViewMode mode;
@property(readonly) IFLayerSet* templateLayers;
- (void)syncLayersWithTemplates;
- (NSArray*)computeTemplates;
@property(retain) NSArray* templates;
- (void)updateBounds;
@end

@implementation IFPaletteView

static NSString* IFTreeTemplatesDidChangeContext = @"IFTreeTemplatesDidChangeContext";

- (id)initWithFrame:(NSRect)theFrame;
{
  if (![super initWithFrame:theFrame])
    return nil;
  grabableViewMixin = [[IFGrabableViewMixin alloc] initWithView:self];
  
  mode = IFPaletteViewModeNormal;
  templates = [[self computeTemplates] retain];
  acceptFirstResponder = NO;
  
  [self registerForDraggedTypes:[NSArray arrayWithObject:IFTreePboardType]];
  [[IFTreeTemplateManager sharedManager] addObserver:self forKeyPath:@"templates" options:0 context:IFTreeTemplatesDidChangeContext];
  
  return self;
}

- (void)dealloc;
{
  [[IFTreeTemplateManager sharedManager] removeObserver:self forKeyPath:@"templates"];
  
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
  
  [self updateBounds];
  [self syncLayersWithTemplates];
}

@synthesize delegate;

// MARK: Normal/preview modes

- (void)switchToPreviewModeForNode:(IFTreeNode*)node ofTree:(IFTree*)tree canvasBounds:(IFVariable*)canvasBoundsVar;
{
  for (IFTemplateLayer* templateLayer in self.templateLayers)
    [templateLayer switchToPreviewModeForNode:node ofTree:tree canvasBounds:canvasBoundsVar];
  [self.layer setNeedsLayout];
  
  self.mode = IFPaletteViewModePreview;
}

- (void)switchToNormalMode;
{
  for (IFTemplateLayer* templateLayer in self.templateLayers)
    [templateLayer switchToNormalMode];
  
  self.mode = IFPaletteViewModeNormal;
}

@synthesize mode;

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
  IFTemplateLayer* draggedLayer = (IFTemplateLayer*)[self.templateLayers hitTest:localPoint];
  
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
  IFCompositeLayer* layerUnderMouse = (IFCompositeLayer*)[self.templateLayers hitTest:localPoint];
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

- (void)syncLayersWithTemplates;
{
  NSMutableDictionary* existingTemplateLayers = createMutableDictionaryWithRetainedKeys();
  
  for (IFTemplateLayer* layer in self.templateLayers)
    CFDictionarySetValue((CFMutableDictionaryRef)existingTemplateLayers, layer.treeTemplate, layer);

  for (IFTreeTemplate* treeTemplate in templates) {
    if ([existingTemplateLayers objectForKey:treeTemplate] != nil)
      [existingTemplateLayers removeObjectForKey:treeTemplate];
    else
      [self.layer addSublayer:[IFTemplateLayer layerForTemplate:treeTemplate]];
  }
  
  for (CALayer* layer in [existingTemplateLayers objectEnumerator])
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

@synthesize templates;

// MARK: View size

- (void)updateBounds;
{
  IFLayerSet* allLayers = self.templateLayers;
  NSSize newSize = NSSizeFromCGSize(allLayers.boundingBox.size);
  NSSize minSize = self.superview.frame.size;

  newSize.width = round(minSize.width);
  newSize.height = round(fmax(newSize.height, minSize.height));
  
  if (!NSEqualSizes(self.frame.size, newSize))
    [self setFrameSize:newSize];
}

@end

