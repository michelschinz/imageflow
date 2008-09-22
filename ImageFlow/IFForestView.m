//
//  IFForestView.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.07.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFForestView.h"
#import "IFNodeCompositeLayer.h"
#import "IFConnectorCompositeLayer.h"
#import "IFNodeLayer.h"
#import "IFDisplayedImageLayer.h"
#import "IFForestLayoutManager.h"
#import "IFLayerSetExplicit.h"
#import "IFLayerPredicateSubset.h"
#import "IFLayerSubsetComposites.h"
#import "IFDocument.h"
#import "IFTreeTemplateManager.h"

@interface IFForestView (Private)
- (IFTree*)newLoadTreeForFileNamed:(NSString*)fileName;
- (void)setCursors:(IFTreeCursorPair*)newCursors;
@property(readonly) IFLayerSet* nodeLayers;
@property(readonly) IFLayerSet* visibleNodeLayers;
- (void)syncLayersWithTree;
- (void)documentTreeChanged:(NSNotification*)notification;
- (IFCompositeLayer*)compositeLayerForNode:(IFTreeNode*)node;
- (void)updateBounds;
- (void)startEditingGhost:(IFCompositeLayer*)ghostCompositeLayer withMouseClick:(NSEvent*)mouseEvent;
- (void)moveToNode:(IFTreeNode*)node extendingSelection:(BOOL)extendSelection;
- (void)moveToNodeRepresentedBy:(IFCompositeLayer*)layer extendingSelection:(BOOL)extendSelection;
- (void)moveToClosestNodeInDirection:(IFDirection)direction extendingSelection:(BOOL)extendSelection;
- (void)updateCursorLayers;
@property(copy) NSSet* selectedNodes;
@property(readonly, copy) IFSubtree* selectedSubtree;
@property(copy) IFTreeNode* cursorNode;
- (void)selectNodes:(NSSet*)nodes puttingCursorOn:(IFTreeNode*)node extendingSelection:(BOOL)extendSelection;
- (BOOL)canExtendSelectionTo:(IFTreeNode*)node;
- (void)extendSelectionTo:(IFTreeNode*)node;
@property(assign) IFCompositeLayer* highlightedLayer;
@end

@implementation IFForestView

static NSString* IFTreePboardType = @"IFTreePboardType";
static NSString* IFMarkPboardType = @"IFMarkPboardType";

static NSString* IFCanvasBoundsDidChange = @"IFCanvasBoundsDidChange";

- (id)initWithFrame:(NSRect)theFrame;
{
  if (![super initWithFrame:theFrame])
    return nil;
  grabableViewMixin = [[IFGrabableViewMixin alloc] initWithView:self];

  [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,IFTreePboardType,IFMarkPboardType,nil]];

  return self;
}

- (void)dealloc;
{
  if (document != nil) {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFTreeChangedNotification object:document];
    [document removeObserver:self forKeyPath:@"canvasBounds"];
    document = nil;
  }
  
  OBJC_RELEASE(cursors);
  OBJC_RELEASE(grabableViewMixin);
  [super dealloc];
}

- (void)awakeFromNib;
{
  CALayer* rootLayer = [CALayer layer];
  
  CGColorRef grayColor = CGColorCreateGenericRGB(0.5, 0.5, 0.5, 1.0); // TODO: use a converted version of layoutParameters.backgroundColor
  rootLayer.backgroundColor = grayColor;
  CGColorRelease(grayColor);
  
  IFForestLayoutManager* rootLayoutManager = [IFForestLayoutManager forestLayoutManagerWithLayoutParameters:layoutParameters];
  rootLayoutManager.delegate = self;
  rootLayer.layoutManager = rootLayoutManager;

  self.layer = rootLayer;
  self.wantsLayer = YES;

  self.enclosingScrollView.wantsLayer = YES;
  self.enclosingScrollView.contentView.wantsLayer = YES;
}

@synthesize document;
@synthesize cursors;
@synthesize delegate;

- (void)setDocument:(IFDocument*)newDocument;
{
  if (newDocument == document)
    return;

  ((IFForestLayoutManager*)self.layer.layoutManager).tree = newDocument.tree;
  
  NSNotificationCenter* notifCenter = [NSNotificationCenter defaultCenter];
  if (document != nil) {
    [notifCenter removeObserver:self name:IFTreeChangedNotification object:document];
    [document removeObserver:self forKeyPath:@"canvasBounds"];
  }
  if (newDocument != nil) {
    [newDocument addObserver:self forKeyPath:@"canvasBounds" options:0 context:IFCanvasBoundsDidChange];
    [notifCenter addObserver:self selector:@selector(documentTreeChanged:) name:IFTreeChangedNotification object:newDocument];
    self.cursors = [IFTreeCursorPair treeCursorPairWithTree:[newDocument tree] editMark:[IFTreeMark mark] viewMark:[IFTreeMark mark]];
  }

  document = newDocument;
  layoutParameters.canvasBounds = NSRectToCGRect(document.canvasBounds);
  [self syncLayersWithTree];
}

- (BOOL)acceptsFirstResponder;
{
  return YES;
}

- (BOOL)becomeFirstResponder;
{
  if (delegate != nil)
    [delegate willBecomeActive:self];
  return YES;
}

// MARK: Misc. callbacks

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize;
{
  [self updateBounds];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
  if (context == IFCanvasBoundsDidChange)
    layoutParameters.canvasBounds = NSRectToCGRect(document.canvasBounds);
  else
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)layoutManager:(IFForestLayoutManager*)layoutManager didLayoutSublayersOfLayer:(CALayer*)parent;
{
  [self updateBounds];
  
  // Re-create tool tips
  [self removeAllToolTips];
  for (IFNodeCompositeLayer* nodeLayer in self.visibleNodeLayers)
    [self addToolTipRect:NSRectFromCGRect(nodeLayer.frame) owner:self userData:nodeLayer.node];
}

- (NSString*)view:(NSView*)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void*)userData;
{
  NSAssert(view == self, @"unexpected view");
  return [(IFTreeNode*)userData toolTip];
}

// MARK: Event handling

- (void)moveUpExtendingSelection:(BOOL)extendSelection;
{
  IFTreeNode* node = [self cursorNode];
  if (![node isFolded] && [[document tree] parentsCountOfNode:node] > 0) {
    NSArray* parents = [[document tree] parentsOfNode:node];
    [self moveToNode:[parents objectAtIndex:(([parents count] - 1) / 2)] extendingSelection:extendSelection];
  } else
    [self moveToClosestNodeInDirection:IFUp extendingSelection:extendSelection];
}

- (void)moveUp:(id)sender;
{
  [self moveUpExtendingSelection:NO];
}

- (void)moveUpAndModifySelection:(id)sender;
{
  [self moveUpExtendingSelection:YES];
}

- (void)moveDownExtendingSelection:(BOOL)extendSelection;
{
  IFTreeNode* current = [self cursorNode];
  if ([[document roots] indexOfObject:current] == NSNotFound)
    [self moveToNode:[[document tree] childOfNode:current] extendingSelection:extendSelection];
  else
    [self moveToClosestNodeInDirection:IFDown extendingSelection:extendSelection];
}

- (void)moveDown:(id)sender;
{
  [self moveDownExtendingSelection:NO];
}

- (void)moveDownAndModifySelection:(id)sender;
{
  [self moveDownExtendingSelection:YES];
}

- (void)moveLeftExtendingSelection:(BOOL)extendSelection;
{
  IFTreeNode* current = [self cursorNode];
  NSArray* siblings = [[document tree] siblingsOfNode:current];
  int indexInSiblings = [siblings indexOfObject:current];
  if (indexInSiblings != NSNotFound && indexInSiblings > 0)
    [self moveToNode:[siblings objectAtIndex:(indexInSiblings - 1)] extendingSelection:extendSelection];
  else
    [self moveToClosestNodeInDirection:IFLeft extendingSelection:extendSelection];
}

- (void)moveLeft:(id)sender;
{
  [self moveLeftExtendingSelection:NO];
}

- (void)moveLeftAndModifySelection:(id)sender;
{
  [self moveLeftExtendingSelection:YES];
}

- (void)moveRightExtendingSelection:(BOOL)extendSelection;
{
  IFTreeNode* current = [self cursorNode];
  NSArray* siblings = [[document tree] siblingsOfNode:current];
  int indexInSiblings = [siblings indexOfObject:current];
  if (indexInSiblings != NSNotFound && indexInSiblings < [siblings count] - 1)
    [self moveToNode:[siblings objectAtIndex:(indexInSiblings + 1)] extendingSelection:extendSelection];
  else
    [self moveToClosestNodeInDirection:IFRight extendingSelection:extendSelection];
}

- (void)moveRight:(id)sender;
{
  [self moveRightExtendingSelection:NO];
}

- (void)moveRightAndModifySelection:(id)sender;
{
  [self moveRightExtendingSelection:YES];
}

- (void)cancelOperation:(id)sender;
{
  if (self.cursorNode.isGhost)
    [self startEditingGhost:[self compositeLayerForNode:self.cursorNode] withMouseClick:nil];
  else
    NSBeep();
}

- (void)delete:(id)sender;
{
  IFSubtree* subtree = [self selectedSubtree];
  if ([document canDeleteSubtree:subtree])
    [document deleteSubtree:subtree];
  else
    NSBeep();
}

- (void)deleteBackward:(id)sender;
{
  [self delete:sender];
}

- (void)insertNewline:(id)sender
{
  [document insertCopyOfTree:[IFTree ghostTreeWithArity:1] asChildOfNode:[self cursorNode]];
  [self moveToNode:[self cursorNode] extendingSelection:NO];
}

- (void)keyDown:(NSEvent*)event;
{
  if ([grabableViewMixin handlesKeyDown:event])
    return;
  
  if (([[event characters] caseInsensitiveCompare:@"e"] == NSOrderedSame) && self.cursorNode.isGhost)
    [self startEditingGhost:[self compositeLayerForNode:self.cursorNode] withMouseClick:nil];
  else
    [self interpretKeyEvents:[NSArray arrayWithObject:event]];
}

- (void)keyUp:(NSEvent*)event;
{
  if (![grabableViewMixin handlesKeyUp:event])
    [super keyUp:event];
}

- (void)mouseDown:(NSEvent*)event;
{
  if ([grabableViewMixin handlesMouseDown:event])
    return;
  
  CGPoint localPoint = NSPointToCGPoint([self convertPoint:[event locationInWindow] fromView:nil]);
  IFCompositeLayer* clickedLayer = (IFCompositeLayer*)[self.visibleNodeLayers hitTest:localPoint];
  if (clickedLayer != nil && clickedLayer.isNode) {
    IFTreeNode* clickedNode = [clickedLayer node];
    BOOL extendSelection = ([event modifierFlags] & NSShiftKeyMask) != 0;
    switch ([event clickCount]) {
      case 1:
        [self moveToNodeRepresentedBy:clickedLayer extendingSelection:extendSelection];
        if (clickedNode.isGhost)
          [self startEditingGhost:(IFNodeCompositeLayer*)clickedLayer withMouseClick:event];
        break;
      case 2:
        [self selectNodes:[document ancestorsOfNode:clickedNode] puttingCursorOn:clickedNode extendingSelection:extendSelection];
        break;
      case 3:
        [self selectNodes:[document nodesOfTreeContainingNode:clickedNode] puttingCursorOn:clickedNode extendingSelection:extendSelection];
        break;
      default:
        ; // ignore
    }
  }
}

- (void)mouseDragged:(NSEvent*)event;
{
  if ([grabableViewMixin handlesMouseDragged:event])
    return;
  
  CGPoint localPoint = NSPointToCGPoint([self convertPoint:[event locationInWindow] fromView:nil]);
  IFCompositeLayer* draggedLayer = (IFCompositeLayer*)[self.visibleNodeLayers hitTest:localPoint];
  
  if (draggedLayer.isNode && draggedLayer.node == self.cursorNode) {
    NSPasteboard* pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    [pboard declareTypes:[NSArray arrayWithObject:IFTreePboardType] owner:self];
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:[[self selectedSubtree] extractTree]] forType:IFTreePboardType];
    
    isCurrentDragLocal = NO;
    IFNodeLayer* nodeLayer = (IFNodeLayer*)draggedLayer.baseLayer;
    [self dragImage:nodeLayer.dragImage at:NSPointFromCGPoint(draggedLayer.frame.origin) offset:NSZeroSize event:event pasteboard:pboard source:self slideBack:YES];    
  }
}

- (void)mouseUp:(NSEvent*)event;
{
  if (![grabableViewMixin handlesMouseUp:event])
    [super mouseUp:event];
}

- (IBAction)toggleNodeFoldingState:(id)sender;
{
  IFTreeNode* node = self.cursorNode;
  node.isFolded = !node.isFolded;
  [self.layer setNeedsLayout];
}

// MARK: Copy and paste

- (void)copy:(id)sender;
{
  NSPasteboard* pboard = [NSPasteboard generalPasteboard];
  [pboard declareTypes:[NSArray arrayWithObject:IFTreePboardType] owner:self];
  [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:[[self selectedSubtree] extractTree]] forType:IFTreePboardType];
}

- (void)cut:(id)sender;
{
  [self copy:sender];
  [self delete:sender];
}

- (void)paste:(id)sender;
{
  if (![[self cursorNode] isGhost]) {
    NSBeep(); // TODO error message
    return;
  }
  
  NSPasteboard* pboard = [NSPasteboard generalPasteboard];
  NSString* available = [pboard availableTypeFromArray:[NSArray arrayWithObject:IFTreePboardType]];
  if (available == nil) {
    NSBeep(); // TODO deactivate menu instead (or additionally)
    return;
  }
  
  IFTree* tree = [NSKeyedUnarchiver unarchiveObjectWithData:[pboard dataForType:IFTreePboardType]];
  if ([document canCopyTree:tree toReplaceGhostNode:[self cursorNode]])
    [document copyTree:tree toReplaceGhostNode:[self cursorNode]];
  else
    NSBeep();
}

// MARK: Drag and drop

// NSDraggingSource methods

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal;
{
  if (isLocal) {
    NSSet* selected = [self selectedNodes];
    return (([selected count] == 1) && ![[selected anyObject] isGhost])
    ? NSDragOperationEvery
    : NSDragOperationEvery & ~NSDragOperationLink;
  } else
    return NSDragOperationDelete;
}

- (void)draggedImage:(NSImage*)image endedAt:(NSPoint)point operation:(NSDragOperation)operation;
{
  NSPasteboard* pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
  NSArray* types = [pboard types];
  
  switch (operation) {
    case NSDragOperationMove:
      if (!isCurrentDragLocal)
        [document deleteSubtree:[self selectedSubtree]];
      break;
      
    case NSDragOperationDelete: {
      if ([types containsObject:IFMarkPboardType]) {
        int markIndex = [(NSNumber*)[NSUnarchiver unarchiveObjectWithData:[pboard dataForType:IFMarkPboardType]] intValue];
        [(IFTreeMark*)[marks objectAtIndex:markIndex] unset];
      } else if ([types containsObject:IFTreePboardType])
        [document deleteSubtree:[self selectedSubtree]];
    } break;
      
    default:
      ; // do nothing
  }
}

// NSDraggingDestination methods

static enum {
  IFDragKindNode,
  IFDragKindFileName,
  IFDragKindMark,
  IFDragKindUnknown
} dragKind;

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender;
{
  NSArray* types = [[sender draggingPasteboard] types];
  if ([types containsObject:IFTreePboardType])
    dragKind = IFDragKindNode;
  else if ([types containsObject:NSFilenamesPboardType])
    dragKind = IFDragKindFileName; // TODO check that we can load the files being dragged
  else if ([types containsObject:IFMarkPboardType])
    dragKind = IFDragKindMark;
  else
    dragKind = IFDragKindUnknown;
  return [self draggingUpdated:sender];
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender;
{
  currentDragOperation = NSDragOperationNone;
  if (dragKind == IFDragKindUnknown)
    return NSDragOperationNone;
  
  CGPoint targetLocation = NSPointToCGPoint([self convertPoint:[sender draggingLocation] fromView:nil]);
  IFCompositeLayer* targetCompositeLayer = (IFCompositeLayer*)[self.visibleNodeLayers hitTest:targetLocation];
  IFTreeNode* targetNode = targetCompositeLayer == nil ? nil : targetCompositeLayer.node;
  BOOL highlightTarget = NO;
  
  NSDragOperation allowedOperationsMask;
  switch (dragKind) {
    case IFDragKindNode:
      highlightTarget = (targetNode != nil && ([targetNode isGhost] || targetCompositeLayer.isInputConnector || targetCompositeLayer.isOutputConnector));
      allowedOperationsMask = NSDragOperationEvery;
      break;
    case IFDragKindFileName: {
      if (targetCompositeLayer != nil) {
        IFTreeNode* node = [targetCompositeLayer node];
        highlightTarget = [node isGhost] || ([[node settings] valueForKey:@"fileName"] != nil);
        allowedOperationsMask = highlightTarget ? NSDragOperationLink : NSDragOperationNone;
      } else
        allowedOperationsMask = NSDragOperationLink;
    } break;
    case IFDragKindMark:
      highlightTarget = YES;
      allowedOperationsMask = NSDragOperationMove|NSDragOperationDelete;
      break;
    default:
      NSAssert(NO,@"unexpected drag kind");
  }
  
  self.highlightedLayer = highlightTarget ? targetCompositeLayer : nil;
    
  NSDragOperation operations = allowedOperationsMask & [sender draggingSourceOperationMask];
  if ((operations & (NSDragOperationMove|NSDragOperationGeneric)) != 0)
    currentDragOperation = NSDragOperationMove;
  else if ((operations & NSDragOperationCopy) != 0)
    currentDragOperation = NSDragOperationCopy;
  else if ((operations & NSDragOperationLink) != 0)
    currentDragOperation = NSDragOperationLink;
  else {
    NSAssert1(operations == 0, @"non-zero operations: %d", operations);
    currentDragOperation = NSDragOperationNone;
  }
  return currentDragOperation;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender;
{
  self.highlightedLayer = nil;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
{
  self.highlightedLayer = nil;
  
  isCurrentDragLocal = ([sender draggingSource] == self);
  
  CGPoint targetLocation = NSPointToCGPoint([self convertPoint:[sender draggingLocation] fromView:nil]);
  IFCompositeLayer* targetCompositeLayer = (IFCompositeLayer*)[self.visibleNodeLayers hitTest:targetLocation];
  IFTreeNode* targetNode = targetCompositeLayer.node;
  
  NSPasteboard* pboard = [sender draggingPasteboard];
  switch (dragKind) {
    case IFDragKindNode: {
      enum { IFReplace, IFInsertAsChild, IFInsertAsParent } operationKind;
      if (targetCompositeLayer.isInputConnector)
        operationKind = IFInsertAsParent;
      else if (targetCompositeLayer.isOutputConnector)
        operationKind = IFInsertAsChild;
      else
        operationKind = IFReplace;
      
      if (targetNode == nil || (operationKind == IFReplace && ![targetNode isGhost]))
        return NO;
      
      if ((currentDragOperation == NSDragOperationMove) && isCurrentDragLocal) {
        IFSubtree* subtree = [self selectedSubtree];
        switch (operationKind) {
          case IFReplace:
            if ([document canMoveSubtree:subtree toReplaceGhostNode:targetNode]) {
              [document moveSubtree:subtree toReplaceGhostNode:targetNode];
              return YES;
            } else
              return NO;
          case IFInsertAsChild:
            if ([document canMoveSubtree:subtree asChildOfNode:targetNode]) {
              [document moveSubtree:subtree asChildOfNode:targetNode];
              return YES;
            } else
              return NO;
          case IFInsertAsParent:
            if ([document canMoveSubtree:subtree asParentOfNode:targetNode]) {
              [document moveSubtree:subtree asParentOfNode:targetNode];
              return YES;
            } else
              return NO;
          default:
            NSAssert(NO, @"unexpected operation kind");
            return NO;
        }
      } else if ((currentDragOperation == NSDragOperationCopy) || (currentDragOperation == NSDragOperationMove)) {
        IFTree* draggedTree = [NSKeyedUnarchiver unarchiveObjectWithData:[pboard dataForType:IFTreePboardType]];
        switch (operationKind) {
          case IFReplace:
            if ([document canCopyTree:draggedTree toReplaceGhostNode:targetNode]) {
              [document copyTree:draggedTree toReplaceGhostNode:targetNode];
              return YES;
            } else
              return NO;
          case IFInsertAsChild:
            if ([document canInsertCopyOfTree:draggedTree asChildOfNode:targetNode]) {
              [document insertCopyOfTree:draggedTree asChildOfNode:targetNode];
              return YES;
            } else
              return NO;
          case IFInsertAsParent:
            if ([document canInsertCopyOfTree:draggedTree asParentOfNode:targetNode]) {
              [document insertCopyOfTree:draggedTree asParentOfNode:targetNode];
              return YES;
            } else
              return NO;
          default:
            NSAssert(NO, @"unexpected operation kind");
            return NO;
        }
      } else if (currentDragOperation == NSDragOperationLink) {
        if (isCurrentDragLocal && operationKind == IFReplace) {
          NSSet* nodeSet = [self selectedNodes];
          NSAssert([nodeSet count] == 1, @"unexpected number of selected nodes for link operation");
          IFTreeNode* original = [nodeSet anyObject];
          if ([document canCreateAliasToNode:original toReplaceGhostNode:targetNode]) {
            [document createAliasToNode:original toReplaceGhostNode:targetNode];
            return YES;
          } else
            return NO;
        } else
          return NO;
      } else
        NSAssert1(NO, @"unexpected drag operation %d", currentDragOperation);
    }
      
    case IFDragKindFileName: {
      NSArray* fileNames = [pboard propertyListForType:NSFilenamesPboardType];
      if (targetCompositeLayer == nil) {
        // Create new file source nodes for dragged files
        for (int i = 0; i < [fileNames count]; ++i)
          [document addCopyOfTree:[self newLoadTreeForFileNamed:[fileNames objectAtIndex:i]]];
        return YES;
      } else if ([targetNode isGhost]) {
        // Replace ghost node by "load" node
        IFTree* loadTree = [self newLoadTreeForFileNamed:[fileNames objectAtIndex:0]];
        if ([document canCopyTree:loadTree toReplaceGhostNode:targetNode]) {
          [document copyTree:loadTree toReplaceGhostNode:targetNode];
          return YES;
        } else
          return NO;
      } else if ([[targetNode settings] valueForKey:@"fileName"] != nil) {
        // Change "fileName" entry in environment to the dropped file name.
        [[targetNode settings] setValue:[fileNames objectAtIndex:0] forKey:@"fileName"];
        return YES;
      } else
        return NO;
    }
      
    case IFDragKindMark: {
      if (targetCompositeLayer == nil)
        return NO;
      int markIndex = [(NSNumber*)[NSUnarchiver unarchiveObjectWithData:[pboard dataForType:IFMarkPboardType]] intValue];
      [(IFTreeMark*)[marks objectAtIndex:markIndex] setNode:targetNode];
      return YES;
    }
      
    default:
      NSAssert(NO,@"unexpected drag kind");
      return NO;
  }
}

@end

@implementation IFForestView (Private)

- (IFTree*)newLoadTreeForFileNamed:(NSString*)fileName;
{
  NSData* archivedClone = [NSKeyedArchiver archivedDataWithRootObject:[[[IFTreeTemplateManager sharedManager] loadFileTemplate] tree]];
  IFTree* clonedTree = [NSKeyedUnarchiver unarchiveObjectWithData:archivedClone];
  [[[clonedTree root] settings] setValue:fileName forKey:@"fileName"];
  return clonedTree;
}

- (void)setCursors:(IFTreeCursorPair*)newCursors;
{
  if (newCursors != cursors) {
    [cursors release];
    cursors = [newCursors retain];
  }
}

- (IFLayerSet*)nodeLayers;
{
  return [IFLayerSubsetComposites compositeSubsetOf:[IFLayerSetExplicit layerSetWithLayers:self.layer.sublayers]];
}

- (IFLayerSet*)visibleNodeLayers;
{
  return [IFLayerPredicateSubset subsetOf:self.nodeLayers predicate:[NSPredicate predicateWithFormat:@"hidden == NO"]];
}

- (void)syncLayersWithTree;
{
  NSMutableDictionary* existingNodeLayers = createMutableDictionaryWithRetainedKeys();
  NSMutableDictionary* existingInConnectorLayers = createMutableDictionaryWithRetainedKeys();
  NSMutableDictionary* existingOutConnectorLayers = createMutableDictionaryWithRetainedKeys();
  
  for (IFCompositeLayer* layer in self.nodeLayers) {
    NSMutableDictionary* dict;
    if (layer.isNode)
      dict = existingNodeLayers;
    else if (layer.isInputConnector)
      dict = existingInConnectorLayers;
    else
      dict = existingOutConnectorLayers;
    
    CFDictionarySetValue((CFMutableDictionaryRef)dict, layer.node, layer);
  }
  
  IFTree* tree = document.tree;
  IFTreeNode* root = tree.root;
  for (IFTreeNode* node in tree.nodes) {
    if (node == root)
      continue;

    if ([existingNodeLayers objectForKey:node] != nil)
      [existingNodeLayers removeObjectForKey:node];
    else
      [self.layer addSublayer:[IFNodeCompositeLayer layerForNode:node layoutParameters:layoutParameters]];
    
    IFLayerNeededMask layersNeeded = [IFForestLayoutManager layersNeededFor:node inTree:tree];
    if (layersNeeded & IFLayerNeededIn) {
      if ([existingInConnectorLayers objectForKey:node] != nil)
        [existingInConnectorLayers removeObjectForKey:node];
      else
        [self.layer addSublayer:[IFConnectorCompositeLayer layerForNode:node kind:IFConnectorKindInput layoutParameters:layoutParameters]];
    }
    
    if (layersNeeded & IFLayerNeededOut) {
      if ([existingOutConnectorLayers objectForKey:node] != nil)
        [existingOutConnectorLayers removeObjectForKey:node];
      else 
        [self.layer addSublayer:[IFConnectorCompositeLayer layerForNode:node kind:IFConnectorKindOutput layoutParameters:layoutParameters]];
    }
  }

  for (CALayer* layer in [existingNodeLayers objectEnumerator])
    [layer removeFromSuperlayer];
  for (CALayer* layer in [existingInConnectorLayers objectEnumerator])
    [layer removeFromSuperlayer];
  for (CALayer* layer in [existingOutConnectorLayers objectEnumerator])
    [layer removeFromSuperlayer];
}

- (void)documentTreeChanged:(NSNotification*)notification;
{
  [self syncLayersWithTree];
}

- (IFCompositeLayer*)compositeLayerForNode:(IFTreeNode*)node;
{
  for (IFCompositeLayer* layer in self.nodeLayers) {
    if (layer.isNode) {
      if (layer.node == node)
        return layer;
    }
  }
  return nil;
}

// MARK: View resizing

- (void)updateBounds;
{
  IFLayerSet* allLayers = self.visibleNodeLayers;
  NSSize newSize = NSSizeFromCGSize(allLayers.boundingBox.size);
  NSSize minSize = self.superview.frame.size;
  
  newSize.width = round(fmax(newSize.width, minSize.width));
  newSize.height = round(fmax(newSize.height, minSize.height));
  
  if (!NSEqualSizes(self.frame.size, newSize)) {
    [self setFrameSize:newSize];
//    [self setNeedsDisplay:YES];
  }
}

// MARK: Ghost node editing

- (void)startEditingGhost:(IFCompositeLayer*)ghostCompositeLayer withMouseClick:(NSEvent*)mouseEvent;
{
  NSTextField* textField = [[[NSTextField alloc] init] autorelease];
  
  [textField setEditable:YES];
  [textField setAllowsEditingTextAttributes:NO];
  [textField setImportsGraphics:NO];
  [textField setDrawsBackground:NO];
  [textField setBordered:NO];
  [textField setFont:layoutParameters.labelFont];
  [textField setFrame:NSRectFromCGRect([ghostCompositeLayer convertRect:ghostCompositeLayer.baseLayer.frame toLayer:self.layer])];
  [textField setDelegate:self];
  
  [textField setTarget:self];
  [textField setAction:@selector(replaceGhostAction:)];
  
  [self addSubview:textField];
  textField.layer.zPosition = ghostCompositeLayer.zPosition + 1.0;
    
  [self.window makeFirstResponder:textField];
  if (mouseEvent != nil)
    [textField mouseDown:mouseEvent];
}

// text field action method
- (void)replaceGhostAction:(id)sender;
{
  NSLog(@"val: %@", [(NSTextField*)sender stringValue]);
}

// text field delegate method
- (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)command;
{
  NSLog(@"sel: %@  control: %@",NSStringFromSelector(command),control);
  if (command == @selector(cancelOperation:)) {
    [self.window makeFirstResponder:self];
    return YES;
  }
  return NO;
}

// text field delegate method
- (void)controlTextDidEndEditing:(NSNotification*)notification;
{
  [self.window makeFirstResponder:self];
  [notification.object removeFromSuperview];
}

// MARK: Cursor movement

- (void)moveToNode:(IFTreeNode*)node extendingSelection:(BOOL)extendSelection;
{
  if (extendSelection) {
    if ([self canExtendSelectionTo:node])
      [self extendSelectionTo:node];
    else
      NSBeep();
  } else {
    self.selectedNodes = [NSSet set];
    self.cursorNode = node;
  }
}

- (void)moveToNodeRepresentedBy:(IFCompositeLayer*)layer extendingSelection:(BOOL)extendSelection;
{
  [self moveToNode:layer.node extendingSelection:extendSelection];
}

static CGPoint IFMidPoint(CGPoint p1, CGPoint p2) {
  return CGPointMake(p1.x + (p2.x - p1.x) / 2.0, p1.y + (p2.y - p1.y) / 2.0);
}

static CGPoint IFFaceMidPoint(CGRect r, IFDirection faceDirection) {
  CGPoint bl = CGPointMake(CGRectGetMinX(r), CGRectGetMinY(r));
  CGPoint br = CGPointMake(CGRectGetMaxX(r), CGRectGetMinY(r));
  CGPoint tr = CGPointMake(CGRectGetMaxX(r), CGRectGetMaxY(r));
  CGPoint tl = CGPointMake(CGRectGetMinX(r), CGRectGetMaxY(r));
  CGPoint p1 = (faceDirection == IFLeft || faceDirection == IFDown) ? bl : tr;
  CGPoint p2 = (faceDirection == IFLeft || faceDirection == IFUp) ? tl : br;
  return IFMidPoint(p1,p2);
}

static IFDirection IFPerpendicularDirection(IFDirection d) {
  switch (d) {
    case IFUp: return IFRight;
    case IFRight: return IFDown;
    case IFDown: return IFLeft;
    case IFLeft: return IFUp;
    default: abort();
  }
}

typedef struct {
  float begin, end;
} IFInterval;

static IFInterval IFMakeInterval(float begin, float end) {
  IFInterval i = { begin, end };
  return i;
}

static BOOL IFIntersectsInterval(IFInterval i1, IFInterval i2) {
  return (i1.begin <= i2.begin && i2.begin <= i1.end) || (i2.begin <= i1.begin && i1.begin <= i2.end);
}

static float IFIntervalDistance(IFInterval i1, IFInterval i2) {
  if (IFIntersectsInterval(i1,i2))
    return 0;
  else if (i1.begin < i2.begin)
    return i2.begin - i1.end;
  else
    return i1.begin - i2.end;
}

static IFInterval IFProjectRect(CGRect r, IFDirection projectionDirection) {
  return (projectionDirection == IFUp || projectionDirection == IFDown)
  ? IFMakeInterval(CGRectGetMinX(r), CGRectGetMaxX(r))
  : IFMakeInterval(CGRectGetMinY(r), CGRectGetMaxY(r));
}

- (void)moveToClosestNodeInDirection:(IFDirection)direction extendingSelection:(BOOL)extendSelection;
{
  const float searchDistance = 1000;

  IFLayer* refLayer = [self compositeLayerForNode:self.cursorNode];
  CGRect refRect = [refLayer convertRect:refLayer.bounds toLayer:self.layer];
  
  CGPoint refMidPoint = IFFaceMidPoint(refRect, direction);
  CGPoint searchRectCorner;
  const float epsilon = 0.1;
  switch (direction) {
    case IFUp:
      searchRectCorner = CGPointMake(refMidPoint.x - searchDistance / 2.0, refMidPoint.y + epsilon);
      break;
    case IFDown:
      searchRectCorner = CGPointMake(refMidPoint.x - searchDistance / 2.0, refMidPoint.y - (searchDistance + epsilon));
      break;
    case IFLeft:
      searchRectCorner = CGPointMake(refMidPoint.x - (searchDistance + epsilon), refMidPoint.y - searchDistance / 2.0);
      break;
    case IFRight:
      searchRectCorner = CGPointMake(refMidPoint.x + epsilon, refMidPoint.y - searchDistance / 2.0);
      break;
    default:
      abort();
  }
  CGRect searchRect = { searchRectCorner, CGSizeMake(searchDistance, searchDistance) };
  
  NSMutableArray* candidates = [NSMutableArray array];
  for (IFCompositeLayer* layer in self.visibleNodeLayers) {
    if (layer.isNode && CGRectIntersectsRect(searchRect, layer.frame))
      [candidates addObject:layer];
  }
  
  if ([candidates count] > 0) {
    IFDirection perDirection = IFPerpendicularDirection(direction);
    
    IFInterval refProjectionPar = IFProjectRect(refRect, direction);
    IFInterval refProjectionPer = IFProjectRect(refRect, perDirection);
    
    IFCompositeLayer* bestCandidate = nil;
    float bestCandidateDistancePar = searchDistance, bestCandidateDistancePer = searchDistance;
    for (IFCompositeLayer* candidate in candidates) {
      CGRect r = [candidate convertRect:candidate.bounds toLayer:self.layer];
      
      float dPer = IFIntervalDistance(refProjectionPar, IFProjectRect(r, direction));
      float dPar = IFIntervalDistance(refProjectionPer, IFProjectRect(r, perDirection));
      
      if (dPer < bestCandidateDistancePer || (dPer == bestCandidateDistancePer && dPar < bestCandidateDistancePar)) {
        bestCandidate = candidate;
        bestCandidateDistancePar = dPar;
        bestCandidateDistancePer = dPer;
      }
    }
    if (bestCandidate != nil)
      [self moveToNodeRepresentedBy:bestCandidate extendingSelection:extendSelection];
    else
      NSBeep();
  } else
    NSBeep();
}

// MARK: Selection

- (void)updateCursorLayers;
{
  IFTreeNode* cursorNode = self.cursorNode;
  NSSet* selNodes = self.selectedNodes;
  
  for (IFCompositeLayer* nodeLayer in self.visibleNodeLayers) {
    if (!nodeLayer.isNode)
      continue;
    
    IFLayer* displayedImageLayer = nodeLayer.displayedImageLayer;
    CALayer* cursorLayer = nodeLayer.cursorLayer;
    IFTreeNode* node = nodeLayer.node;

    displayedImageLayer.hidden = (node != cursorNode);
    if ([selNodes containsObject:node]) {
      cursorLayer.hidden = NO;
      cursorLayer.borderWidth = (node == cursorNode) ? layoutParameters.cursorWidth : layoutParameters.selectionWidth;
    } else
      cursorLayer.hidden = YES;
  }
}

- (void)setSelectedNodes:(NSSet*)newSelectedNodes;
{
  if (newSelectedNodes == selectedNodes)
    return;
  
  NSMutableSet* expandedNodes = [NSMutableSet set];
  for (IFTreeNode* node in newSelectedNodes) {
    if ([node isFolded])
      [expandedNodes unionSet:[document ancestorsOfNode:node]];
    else
      [expandedNodes addObject:node];
  }
  [selectedNodes release];
  selectedNodes = [expandedNodes retain];
  
  [self updateCursorLayers];
}

- (NSSet*)selectedNodes;
{
  if ([self cursorNode] == nil)
    return [NSSet set];
  else if ([selectedNodes count] == 0) {
    IFTreeNode* cursorNode = [self cursorNode];
    return [cursorNode isFolded] ? [document ancestorsOfNode:cursorNode] : [NSSet setWithObject:cursorNode];
  } else
    return selectedNodes;
}

- (IFSubtree*)selectedSubtree;
{
  return [IFSubtree subtreeOf:[document tree] includingNodes:[self selectedNodes]];
}

- (void)setCursorNode:(IFTreeNode*)newCursorNode;
{
  if (newCursorNode == self.cursorNode)
    return;
  [cursors moveToNode:newCursorNode];
  [self updateCursorLayers];
}

- (IFTreeNode*)cursorNode;
{
  return cursors.editMark.node;
}

- (void)selectNodes:(NSSet*)nodes puttingCursorOn:(IFTreeNode*)node extendingSelection:(BOOL)extendSelection;
{
  NSAssert([nodes containsObject:node], @"invalid selection");
  if (extendSelection) {
    NSMutableSet* allNodes = [NSMutableSet setWithSet:nodes];
    [allNodes unionSet:[self selectedNodes]];
    nodes = allNodes;
  }
  self.selectedNodes = nodes;
  self.cursorNode = node;
}

- (BOOL)canExtendSelectionTo:(IFTreeNode*)node;
{
  return [document rootOfTreeContainingNode:node] == [document rootOfTreeContainingNode:[self cursorNode]];
}

- (void)extendSelectionTo:(IFTreeNode*)node;
{
  NSArray* nodeRootPath = [document pathFromRootTo:node];
  NSArray* cursorRootPath = [document pathFromRootTo:[self cursorNode]];
  NSAssert([nodeRootPath objectAtIndex:0] == [cursorRootPath objectAtIndex:0], @"unexpected paths!");
  
  int i = 0;
  while (i < [nodeRootPath count]
         && i < [cursorRootPath count]
         && [nodeRootPath objectAtIndex:i] == [cursorRootPath objectAtIndex:i])
    ++i;
  int commonPrefixLen = i;
  
  NSMutableSet* newSelection = [NSMutableSet set];
  [newSelection unionSet:[NSSet setWithArray:nodeRootPath]];
  [newSelection unionSet:[NSSet setWithArray:cursorRootPath]];
  [newSelection minusSet:[NSSet setWithArray:[nodeRootPath subarrayWithRange:NSMakeRange(0,commonPrefixLen - 1)]]];
  [self selectNodes:newSelection puttingCursorOn:node extendingSelection:YES];
}

// MARK: highlighting

- (IFCompositeLayer*)highlightedLayer;
{
  return highlightedLayer;
}

- (void)setHighlightedLayer:(IFCompositeLayer*)newHighlightedLayer;
{
  if (newHighlightedLayer == highlightedLayer)
    return;
  if (highlightedLayer != nil)
    highlightedLayer.highlightLayer.hidden = YES;
  if (newHighlightedLayer != nil)
    newHighlightedLayer.highlightLayer.hidden = NO;
  highlightedLayer = newHighlightedLayer;
}

@end
