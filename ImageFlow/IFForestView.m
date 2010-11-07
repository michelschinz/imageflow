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
#import "IFForestLayoutManager.h"
#import "IFImageOrMaskLayer.h"
#import "IFLayerSetExplicit.h"
#import "IFLayerPredicateSubset.h"
#import "IFLayerSubsetComposites.h"
#import "IFDocument.h"
#import "IFTreeTemplateManager.h"
#import "IFLayoutParameters.h"
#import "IFVariableKVO.h"
#import "IFLayerGeometry.h"
#import "IFDragBadgeCreator.h"

@interface IFForestView ()
- (IFTree*)freshLoadTreeForURL:(NSURL*)fileURL;
@property(retain) IFTreeCursorPair* cursors;
@property(readonly) IFLayerSet* nodeConnectorLayers;
@property(readonly) IFLayerSet* nodeLayers;
@property(readonly) IFLayerSet* visibleNodeConnectorLayers;
@property(readonly) IFLayerSet* visibleNodeLayers;
@property(retain) IFVariable* canvasBoundsVar;
- (void)syncLayersWithTree;
- (void)documentTreeChanged:(NSNotification*)notification;
- (IFNodeCompositeLayer*)compositeLayerForNode:(IFTreeNode*)node;
- (void)updateBounds;
- (void)startEditingGhost:(IFNodeCompositeLayer*)ghostCompositeLayer withMouseClick:(NSEvent*)mouseEvent;
@property(retain) NSInvocation* delayedMouseEventInvocation;
- (void)moveToNode:(IFTreeNode*)node path:(IFArrayPath*)path extendingSelection:(BOOL)extendSelection;
- (void)moveToClosestNodeInDirection:(IFDirection)direction extendingSelection:(BOOL)extendSelection;
- (void)updateViewLockButton;
- (void)updateCursorLayers;
@property(copy) NSSet* selectedNodes;
@property(readonly) IFSubtree* selectedSubtree;
- (void)setCursorNode:(IFTreeNode*)newCursorNode path:(IFArrayPath*)newPath;
@property(readonly) IFTreeNode* cursorNode;
- (void)selectNodes:(NSSet*)nodes puttingCursorOn:(IFTreeNode*)node path:(IFArrayPath*)path extendingSelection:(BOOL)extendSelection;
- (BOOL)canExtendSelectionTo:(IFTreeNode*)node;
- (void)extendSelectionTo:(IFTreeNode*)node path:(IFArrayPath*)path;
@property(assign, nonatomic) IFCompositeLayer* highlightedLayer;
@end

@implementation IFForestView

static NSString* IFTreePboardType = @"IFTreePboardType";
static NSString* IFVisualisedCursorDidChangeContext = @"IFVisualisedCursorDidChangeContext";

- (id)initWithFrame:(NSRect)theFrame;
{
  if (![super initWithFrame:theFrame])
    return nil;
  grabableViewMixin = [[IFGrabableViewMixin alloc] initWithView:self];

  [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,IFTreePboardType,nil]];
  [self addObserver:self forKeyPath:@"visualisedCursor.node" options:0 context:IFVisualisedCursorDidChangeContext];
  [self addObserver:self forKeyPath:@"visualisedCursor.viewLockedNode" options:0 context:IFVisualisedCursorDidChangeContext];
  [self addObserver:self forKeyPath:@"visualisedCursor.isViewLocked" options:0 context:IFVisualisedCursorDidChangeContext];

  return self;
}

- (void)dealloc;
{
  [self removeObserver:self forKeyPath:@"visualisedCursor.isViewLocked"];
  [self removeObserver:self forKeyPath:@"visualisedCursor.viewLockedNode"];
  [self removeObserver:self forKeyPath:@"visualisedCursor.node"];

  if (document != nil) {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFTreeChangedNotification object:document];
    document = nil;
  }

  OBJC_RELEASE(visualisedCursor);
  OBJC_RELEASE(cursors);
  OBJC_RELEASE(grabableViewMixin);
  [super dealloc];
}

- (void)awakeFromNib;
{
  CALayer* rootLayer = [CALayer layer];

  rootLayer.backgroundColor = [IFLayoutParameters backgroundColor];

  IFForestLayoutManager* rootLayoutManager = [IFForestLayoutManager forestLayoutManager];
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
  if (newDocument == document)
    return;

  IFForestLayoutManager* layoutManager = (IFForestLayoutManager*)self.layer.layoutManager;
  layoutManager.layoutParameters = newDocument.layoutParameters;
  layoutManager.tree = newDocument.tree;

  NSNotificationCenter* notifCenter = [NSNotificationCenter defaultCenter];
  if (document != nil) {
    [notifCenter removeObserver:self name:IFTreeChangedNotification object:document];
  }
  if (newDocument != nil) {
    [notifCenter addObserver:self selector:@selector(documentTreeChanged:) name:IFTreeChangedNotification object:newDocument];
    self.cursors = [IFSplittableTreeCursorPair splittableTreeCursorPair];
    self.canvasBoundsVar = [IFVariableKVO variableWithKVOCompliantObject:newDocument key:@"canvasBounds"];
  }

  document = newDocument;
  [self syncLayersWithTree];
}

- (BOOL)acceptsFirstResponder;
{
  return YES;
}

- (BOOL)becomeFirstResponder;
{
  if (delegate != nil)
    [delegate forestViewWillBecomeActive:self];
  return YES;
}

// MARK: Misc. callbacks

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
  if (context == IFVisualisedCursorDidChangeContext)
    [self updateCursorLayers];
  else
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize;
{
  [self updateBounds];
}

- (void)layoutManager:(IFForestLayoutManager*)layoutManager didLayoutSublayersOfLayer:(CALayer*)parent;
{
  [self updateBounds];

  // Re-create tool tips
  [self removeAllToolTips];
  for (IFNodeCompositeLayer* nodeLayer in self.visibleNodeLayers)
    [self addToolTipRect:NSRectFromCGRect(nodeLayer.frame) owner:self userData:nodeLayer.node];

  // Position view lock button
  [self updateViewLockButton];
}

- (NSString*)view:(NSView*)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void*)userData;
{
  NSAssert(view == self, @"unexpected view");
  return [(IFTreeNode*)userData toolTip];
}

// MARK: Event handling

- (void)moveUpExtendingSelection:(BOOL)extendSelection;
{
  IFTreeNode* node = self.cursorNode;
  if (![node isFolded] && [[document tree] parentsCountOfNode:node] > 0) {
    NSArray* parents = [[document tree] parentsOfNode:node];
    [self moveToNode:[parents objectAtIndex:(([parents count] - 1) / 2)] path:nil extendingSelection:extendSelection]; // FIXME: pass correct path
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
  IFTreeNode* current = self.cursorNode;
  if ([[document roots] indexOfObject:current] == NSNotFound)
    [self moveToNode:[[document tree] childOfNode:current] path:nil extendingSelection:extendSelection]; // FIXME: pass correct path
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
  IFTreeNode* currentNode = self.cursorNode;

  NSArray* arraySiblings = [[self compositeLayerForNode:currentNode].baseLayer valueForKey:@"thumbnailLayers"];
  IFArrayPath* currentReversedPath = self.cursors.path.reversed;
  IFArrayPath* pathAtLeft = nil;
  for (int i = 0; i < [arraySiblings count]; ++i) {
    if ([[[arraySiblings objectAtIndex:i] reversedPath] isEqual:currentReversedPath]) {
      if (i > 0)
        pathAtLeft = [[[arraySiblings objectAtIndex:i-1] reversedPath] reversed];
      break;
    }
  }

  if (pathAtLeft != nil)
    [self moveToNode:currentNode path:pathAtLeft extendingSelection:extendSelection];
  else {
    NSArray* siblings = [[document tree] siblingsOfNode:currentNode];
    NSUInteger indexInSiblings = [siblings indexOfObject:currentNode];
    if (indexInSiblings != NSNotFound && indexInSiblings > 0)
      [self moveToNode:[siblings objectAtIndex:(indexInSiblings - 1)] path:nil extendingSelection:extendSelection]; // FIXME: pass correct path
    else
      [self moveToClosestNodeInDirection:IFLeft extendingSelection:extendSelection];
  }
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
  IFTreeNode* currentNode = self.cursorNode;

  NSArray* arraySiblings = [[self compositeLayerForNode:currentNode].baseLayer valueForKey:@"thumbnailLayers"];
  IFArrayPath* currentReversedPath = self.cursors.path.reversed;
  IFArrayPath* pathAtRight = nil;
  for (int i = 0; i < [arraySiblings count]; ++i) {
    if ([[[arraySiblings objectAtIndex:i] reversedPath] isEqual:currentReversedPath]) {
      if (i < [arraySiblings count] - 1)
        pathAtRight = [[[arraySiblings objectAtIndex:i+1] reversedPath] reversed];
      break;
    }
  }

  if (pathAtRight != nil)
    [self moveToNode:currentNode path:pathAtRight extendingSelection:extendSelection];
  else {
    NSArray* siblings = [[document tree] siblingsOfNode:currentNode];
    NSUInteger indexInSiblings = [siblings indexOfObject:currentNode];
    if (indexInSiblings != NSNotFound && indexInSiblings < [siblings count] - 1)
      [self moveToNode:[siblings objectAtIndex:(indexInSiblings + 1)] path:nil extendingSelection:extendSelection]; // FIXME: pass correct path
    else
      [self moveToClosestNodeInDirection:IFRight extendingSelection:extendSelection];
  }
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
  if ([document canDeleteSubtree:subtree]) {
    IFTreeNode* deletedSubtreeChild = [document.tree childOfNode:subtree.root];
    unsigned deletedSubtreeChildIndex = [[document.tree parentsOfNode:deletedSubtreeChild] indexOfObject:subtree.root];
    IFTreeNode* maybeGhost = [document deleteSubtree:subtree];
    IFTreeNode* newCursorNode = (maybeGhost != nil)
    ? maybeGhost
    : [[document.tree parentsOfNode:deletedSubtreeChild] objectAtIndex:deletedSubtreeChildIndex];
    [self moveToNode:newCursorNode path:nil extendingSelection:NO];
  } else
    NSBeep();
}

- (void)deleteBackward:(id)sender;
{
  [self delete:sender];
}

- (void)insertNewline:(id)sender
{
  [document insertCloneOfTree:[IFTree ghostTreeWithArity:1] asChildOfNode:self.cursorNode];
  [self moveToNode:[document.tree childOfNode:self.cursorNode] path:nil extendingSelection:NO];
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
  IFNodeCompositeLayer* clickedLayer = (IFNodeCompositeLayer*)[self.visibleNodeLayers hitTest:localPoint];
  if (clickedLayer != nil) {
    IFTreeNode* clickedNode = [clickedLayer node];

    CGPoint layerLocalPoint = [clickedLayer convertPoint:localPoint fromLayer:self.layer];
    CALayer* pathLayer;
    for (pathLayer = [clickedLayer.baseLayer hitTest:layerLocalPoint]; pathLayer != nil && [pathLayer valueForKey:@"reversedPath"] == nil; pathLayer = pathLayer.superlayer)
      ;
    IFArrayPath* path = [pathLayer valueForKey:@"reversedPath"];

    BOOL extendSelection = ([event modifierFlags] & NSShiftKeyMask) != 0;
    switch ([event clickCount]) {
      case 1: {
        NSInvocation* movementInvocation = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:@selector(moveToNode:path:extendingSelection:)]];
        [movementInvocation setSelector:@selector(moveToNode:path:extendingSelection:)];
        [movementInvocation setTarget:self];
        [movementInvocation setArgument:&clickedNode atIndex:2];
        [movementInvocation setArgument:&path atIndex:3];
        [movementInvocation setArgument:&extendSelection atIndex:4];

        if ([self.selectedNodes containsObject:clickedNode]) {
          [movementInvocation retainArguments];
          self.delayedMouseEventInvocation = movementInvocation;
        } else {
          [movementInvocation invoke];
          if (self.cursorNode == clickedNode && clickedNode.isGhost)
            [self startEditingGhost:clickedLayer withMouseClick:event];
        }
      } break;
      case 2:
        [self selectNodes:[document ancestorsOfNode:clickedNode] puttingCursorOn:clickedNode path:path extendingSelection:extendSelection];
        break;
      case 3:
        [self selectNodes:[document nodesOfTreeContainingNode:clickedNode] puttingCursorOn:clickedNode path:path extendingSelection:extendSelection];
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

  self.delayedMouseEventInvocation = nil;

  CGPoint localPoint = NSPointToCGPoint([self convertPoint:[event locationInWindow] fromView:nil]);
  IFNodeCompositeLayer* draggedLayer = (IFNodeCompositeLayer*)[self.visibleNodeLayers hitTest:localPoint];

  if (draggedLayer != nil && [self.selectedNodes containsObject:draggedLayer.node]) {
    NSPasteboard* pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    [pboard declareTypes:[NSArray arrayWithObject:IFTreePboardType] owner:self];
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:[[self selectedSubtree] extractTree]] forType:IFTreePboardType];

    isCurrentDragLocal = NO;

    IFNodeLayer* nodeLayer = (IFNodeLayer*)draggedLayer.baseLayer;
    NSImage* dragImage = nodeLayer.dragImage;
    unsigned nodesCount = [self.selectedNodes count];
    if (nodesCount > 1) {
      IFDragBadgeCreator* badgeCreator = [IFDragBadgeCreator sharedCreator];
      dragImage = [badgeCreator addBadgeToImage:dragImage count:nodesCount];
    }
    [self dragImage:dragImage at:NSPointFromCGPoint(draggedLayer.frame.origin) offset:NSZeroSize event:event pasteboard:pboard source:self slideBack:YES];
  }
}

- (void)mouseUp:(NSEvent*)event;
{
  if (![grabableViewMixin handlesMouseUp:event])
    [super mouseUp:event];

  if (self.delayedMouseEventInvocation != nil) {
    [self.delayedMouseEventInvocation invoke];
    self.delayedMouseEventInvocation = nil;
    if (self.cursorNode.isGhost)
      [self startEditingGhost:[self compositeLayerForNode:self.cursorNode] withMouseClick:nil];
  }
}

- (IBAction)toggleNodeFoldingState:(id)sender;
{
  IFTreeNode* node = self.cursorNode;

  IFTree* tree = document.tree;
  if (!node.isGhost && [tree ancestorsCountOfNode:node] > 1) {
    node.isFolded = !node.isFolded;
    [self.layer setNeedsLayout];
  } else
    NSBeep();
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
  if (!self.cursorNode.isGhost) {
    NSBeep(); // TODO: error message
    return;
  }

  NSPasteboard* pboard = [NSPasteboard generalPasteboard];
  NSString* available = [pboard availableTypeFromArray:[NSArray arrayWithObject:IFTreePboardType]];
  if (available == nil) {
    NSBeep(); // TODO: deactivate menu instead (or additionally)
    return;
  }

  IFTree* tree = [NSKeyedUnarchiver unarchiveObjectWithData:[pboard dataForType:IFTreePboardType]];
  if ([document canCloneTree:tree toReplaceGhostNode:self.cursorNode]) {
    IFTreeNode* pastedRoot = [document cloneTree:tree toReplaceGhostNode:self.cursorNode];
    [self moveToNode:pastedRoot path:nil extendingSelection:NO];
  } else
    NSBeep();
}

// MARK: Drag and drop

// NSDraggingSource methods

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal;
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

    case NSDragOperationDelete:
      if ([types containsObject:IFTreePboardType])
        [document deleteSubtree:[self selectedSubtree]];
      break;

    default:
      ; // do nothing
  }
}

// NSDraggingDestination methods

static enum {
  IFDragKindNode,
  IFDragKindFileName,
  IFDragKindUnknown
} dragKind;

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender;
{
  NSArray* types = [[sender draggingPasteboard] types];
  if ([types containsObject:IFTreePboardType])
    dragKind = IFDragKindNode;
  else if ([types containsObject:NSFilenamesPboardType])
    dragKind = IFDragKindFileName; // TODO check that we can load the files being dragged
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
  IFCompositeLayer* targetCompositeLayer = (IFCompositeLayer*)[self.visibleNodeConnectorLayers hitTest:targetLocation];
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
        IFTreeNode* node = targetCompositeLayer.node;
        highlightTarget = node.isGhost || ([node.original.settings valueForKey:@"fileURL"] != nil);
        allowedOperationsMask = highlightTarget ? NSDragOperationLink : NSDragOperationNone;
      } else
        allowedOperationsMask = NSDragOperationLink;
    } break;

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
  IFCompositeLayer* targetCompositeLayer = (IFCompositeLayer*)[self.visibleNodeConnectorLayers hitTest:targetLocation];
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
            if ([document canCloneTree:draggedTree toReplaceGhostNode:targetNode]) {
              [document cloneTree:draggedTree toReplaceGhostNode:targetNode];
              return YES;
            } else
              return NO;
          case IFInsertAsChild:
            if ([document canInsertCloneOfTree:draggedTree asChildOfNode:targetNode]) {
              [document insertCloneOfTree:draggedTree asChildOfNode:targetNode];
              return YES;
            } else
              return NO;
          case IFInsertAsParent:
            if ([document canInsertCloneOfTree:draggedTree asParentOfNode:targetNode]) {
              [document insertCloneOfTree:draggedTree asParentOfNode:targetNode];
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
          [document addCloneOfTree:[self freshLoadTreeForURL:[NSURL fileURLWithPath:[fileNames objectAtIndex:i]]]];
        return YES;
      } else if ([targetNode isGhost]) {
        // Replace ghost node by "load" node
        IFTree* loadTree = [self freshLoadTreeForURL:[NSURL fileURLWithPath:[fileNames objectAtIndex:0]]];
        if ([document canCloneTree:loadTree toReplaceGhostNode:targetNode]) {
          [document cloneTree:loadTree toReplaceGhostNode:targetNode];
          return YES;
        } else
          return NO;
      } else if ([targetNode.original.settings valueForKey:@"fileURL"] != nil) {
        // Change "fileURL" entry in environment to the dropped file name.
        [targetNode.original.settings setValue:[NSURL fileURLWithPath:[fileNames objectAtIndex:0]] forKey:@"fileURL"];
        return YES;
      } else
        return NO;
    }

    default:
      NSAssert(NO,@"unexpected drag kind");
      return NO;
  }
}

// MARK: -
// MARK: PRIVATE

- (IFTree*)freshLoadTreeForURL:(NSURL*)fileURL;
{
  NSData* archivedClone = [NSKeyedArchiver archivedDataWithRootObject:[[[IFTreeTemplateManager sharedManager] loadFileTemplate] tree]];
  IFTree* clonedTree = [NSKeyedUnarchiver unarchiveObjectWithData:archivedClone];
  [[[clonedTree root] settings] setValue:fileURL forKey:@"fileURL"];
  return clonedTree;
}

- (IFLayerSet*)nodeConnectorLayers;
{
  return [IFLayerSubsetComposites compositeSubsetOf:[IFLayerSetExplicit layerSetWithLayers:self.layer.sublayers]];
}

- (IFLayerSet*)nodeLayers;
{
  return [IFLayerPredicateSubset subsetOf:self.nodeConnectorLayers predicate:[NSPredicate predicateWithFormat:@"isNode == YES"]];
}

- (IFLayerSet*)visibleNodeConnectorLayers;
{
  return [IFLayerPredicateSubset subsetOf:self.nodeConnectorLayers predicate:[NSPredicate predicateWithFormat:@"hidden == NO"]];
}

- (IFLayerSet*)visibleNodeLayers;
{
  return [IFLayerPredicateSubset subsetOf:self.nodeConnectorLayers predicate:[NSPredicate predicateWithFormat:@"isNode == YES && hidden == NO"]];
}

@synthesize canvasBoundsVar;

- (void)syncLayersWithTree;
{
  NSMutableDictionary* existingNodeLayers = [createMutableDictionaryWithRetainedKeys() autorelease];
  NSMutableDictionary* existingInConnectorLayers = [createMutableDictionaryWithRetainedKeys() autorelease];
  NSMutableDictionary* existingOutConnectorLayers = [createMutableDictionaryWithRetainedKeys() autorelease];

  for (IFCompositeLayer* layer in self.nodeConnectorLayers) {
    NSMutableDictionary* dict;
    if (layer.isNode)
      dict = existingNodeLayers;
    else if (layer.isInputConnector)
      dict = existingInConnectorLayers;
    else
      dict = existingOutConnectorLayers;

    CFDictionarySetValue((CFMutableDictionaryRef)dict, layer.node, layer);
  }

  IFLayoutParameters* layoutParameters = document.layoutParameters;
  IFTree* tree = document.tree;
  IFTreeNode* root = tree.root;
  for (IFTreeNode* node in tree.nodes) {
    if (node == root)
      continue;

    if ([existingNodeLayers objectForKey:node] != nil)
      [existingNodeLayers removeObjectForKey:node];
    else
      [self.layer addSublayer:[IFNodeCompositeLayer layerForNode:node ofTree:tree layoutParameters:layoutParameters canvasBounds:canvasBoundsVar]];

    IFLayerNeededMask layersNeeded = [IFForestLayoutManager layersNeededFor:node inTree:tree];
    if (layersNeeded & IFLayerNeededIn) {
      if ([existingInConnectorLayers objectForKey:node] != nil)
        [existingInConnectorLayers removeObjectForKey:node];
      else
        [self.layer addSublayer:[IFConnectorCompositeLayer layerForNode:node kind:IFConnectorKindInput]];
    }

    if (layersNeeded & IFLayerNeededOut) {
      if ([existingOutConnectorLayers objectForKey:node] != nil)
        [existingOutConnectorLayers removeObjectForKey:node];
      else
        [self.layer addSublayer:[IFConnectorCompositeLayer layerForNode:node kind:IFConnectorKindOutput]];
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

- (IFNodeCompositeLayer*)compositeLayerForNode:(IFTreeNode*)node;
{
  for (IFNodeCompositeLayer* layer in self.nodeLayers) {
    if (layer.node == node)
      return layer;
  }
  return nil;
}

// MARK: View resizing

- (void)updateBounds;
{
  IFLayerSet* allLayers = self.visibleNodeConnectorLayers;
  NSSize newSize = NSSizeFromCGSize(allLayers.boundingBox.size);
  NSSize minSize = self.superview.frame.size;

  newSize.width = round(fmax(newSize.width, minSize.width));
  newSize.height = round(fmax(newSize.height, minSize.height));

  if (!NSEqualSizes(self.frame.size, newSize))
    [self setFrameSize:newSize];
}

// MARK: Ghost node editing

- (void)startEditingGhost:(IFNodeCompositeLayer*)ghostCompositeLayer withMouseClick:(NSEvent*)mouseEvent;
{
  NSTextField* textField = [[[NSTextField alloc] init] autorelease];

  [textField setEditable:YES];
  [textField setAllowsEditingTextAttributes:NO];
  [textField setImportsGraphics:NO];
  [textField setDrawsBackground:NO];
  [textField setBordered:NO];
  [textField setFont:[IFLayoutParameters labelFont]];
  [textField setFrame:NSRectFromCGRect([ghostCompositeLayer convertRect:ghostCompositeLayer.baseLayer.frame toLayer:self.layer])];
  [textField setDelegate:self];

  [textField setTarget:self];
  [textField setAction:@selector(replaceGhostAction:)];

  [self addSubview:textField];
  textField.layer.zPosition = ghostCompositeLayer.zPosition + 1.0;

  [self.window makeFirstResponder:textField];
  if (mouseEvent != nil)
    [textField mouseDown:mouseEvent];

  [delegate beginPreviewForNode:ghostCompositeLayer.node ofTree:document.tree];
}

// text field action method
- (void)replaceGhostAction:(id)sender;
{
  IFTreeTemplate* treeTemplate = [delegate selectedTreeTemplate];
  if (treeTemplate != nil) {
    IFTreeNode* newRoot = [document cloneTree:treeTemplate.tree toReplaceGhostNode:self.cursorNode];
    [self moveToNode:newRoot path:nil extendingSelection:NO];
  } else
    NSBeep();
}

// text field delegate method
- (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)command;
{
  if (command == @selector(cancelOperation:)) {
    [self.window makeFirstResponder:self];
    return YES;
  } else if (command == @selector(insertTab:)) {
    if (![self.delegate selectNextTreeTemplate])
      NSBeep();
    return YES;
  } else if (command == @selector(insertBacktab:)) {
    if (![self.delegate selectPreviousTreeTemplate])
      NSBeep();
    return YES;
  }
  return NO;
}

// text field delegate method
- (void)controlTextDidChange:(NSNotification*)notification;
{
  [self.delegate previewFilterStringDidChange:((NSTextField*)notification.object).stringValue];
}

- (void)controlTextDidEndEditing:(NSNotification*)notification;
{
  [delegate endPreview];

  [self.window makeFirstResponder:self];
  [notification.object removeFromSuperview];
}

// MARK: Cursor & selection

@synthesize delayedMouseEventInvocation;

- (void)moveToNode:(IFTreeNode*)node path:(IFArrayPath*)path extendingSelection:(BOOL)extendSelection;
{
  if (extendSelection) {
    if ([self canExtendSelectionTo:node])
      [self extendSelectionTo:node path:path];
    else
      NSBeep();
  } else {
    self.selectedNodes = [NSSet set];
    [self setCursorNode:node path:path];
  }
}

- (void)moveToClosestNodeInDirection:(IFDirection)direction extendingSelection:(BOOL)extendSelection;
{
  CALayer* closestLayer = closestLayerInDirection([self compositeLayerForNode:self.cursorNode], [self.visibleNodeLayers toArray], direction);
  if (closestLayer != nil)
    [self moveToNode:((IFNodeCompositeLayer*)closestLayer).node path:nil extendingSelection:extendSelection]; // FIXME: pass correct path
  else
    NSBeep();
}

- (void)updateViewLockButton;
{
  for (IFNodeCompositeLayer* nodeLayer in self.visibleNodeLayers) {
    const CALayer* displayedImageLayer = nodeLayer.displayedImageLayer;
    if (displayedImageLayer.hidden == NO) {
      CGRect diLayerFrame = [displayedImageLayer.superlayer convertRect:displayedImageLayer.frame toLayer:self.layer];
      [viewLockButton setFrameOrigin:NSMakePoint(CGRectGetMinX(diLayerFrame) + 2.0, CGRectGetMaxY(diLayerFrame) - NSHeight([viewLockButton frame]) - 1.0)];
      viewLockButton.layer.zPosition = 2.0;
      [viewLockButton setHidden:NO];
      return;
    }
  }
  [viewLockButton setHidden:YES];
}

- (void)updateCursorLayers;
{
  [self syncLayersWithTree]; // Make sure all layers exist

  IFTreeNode* cursorNode = self.cursorNode;
  NSSet* selNodes = self.selectedNodes;
  IFTreeNode* displayedNode = visualisedCursor.viewLockedNode;

  for (IFNodeCompositeLayer* nodeLayer in self.visibleNodeLayers) {
    IFTreeNode* node = nodeLayer.node;

    if (node == displayedNode) {
      CALayer* displayedImageLayer = nodeLayer.displayedImageLayer;
      displayedImageLayer.hidden = NO;
      displayedImageLayer.backgroundColor = cursors.isViewLocked ? [IFLayoutParameters displayedImageLockedBackgroundColor] : [IFLayoutParameters displayedImageUnlockedBackgroundColor];
    } else
      nodeLayer.displayedImageLayer.hidden = YES;

    if (node == cursorNode) {
      nodeLayer.cursorIndicator = IFLayerCursorIndicatorCursor;
      [self scrollRectToVisible:NSRectFromCGRect(nodeLayer.frame)];

      IFArrayPath* reversedPath = self.cursors.viewLockedPath.reversed;
      for (IFImageOrMaskLayer* thumbnailLayer in nodeLayer.thumbnailLayers)
        thumbnailLayer.borderHighlighted = ([thumbnailLayer.reversedPath isEqual:reversedPath]);
    } else {
      if ([selNodes containsObject:node])
        nodeLayer.cursorIndicator = IFLayerCursorIndicatorSelection;
      else
        nodeLayer.cursorIndicator = IFLayerCursorIndicatorNone;
      for (IFImageOrMaskLayer* thumbnailLayer in nodeLayer.thumbnailLayers)
        thumbnailLayer.borderHighlighted = NO;
    }
  }
  [self updateViewLockButton];
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
}

- (NSSet*)selectedNodes;
{
  if (self.cursorNode == nil)
    return [NSSet set];
  else if ([selectedNodes count] == 0) {
    IFTreeNode* cursorNode = self.cursorNode;
    return [cursorNode isFolded] ? [document ancestorsOfNode:cursorNode] : [NSSet setWithObject:cursorNode];
  } else
    return selectedNodes;
}

- (IFSubtree*)selectedSubtree;
{
  return [IFSubtree subtreeOf:[document tree] includingNodes:[self selectedNodes]];
}

- (void)setCursorNode:(IFTreeNode*)newCursorNode path:(IFArrayPath*)newPath;
{
  if (newPath == nil)
    newPath = [IFArrayPath leftmostPathForType:newCursorNode.type.resultType];
  [cursors setTree:document.tree node:newCursorNode path:newPath];
}

- (IFTreeNode*)cursorNode;
{
  return cursors.node;
}

- (void)selectNodes:(NSSet*)nodes puttingCursorOn:(IFTreeNode*)node path:(IFArrayPath*)path extendingSelection:(BOOL)extendSelection;
{
  NSAssert([nodes containsObject:node], @"invalid selection");
  if (extendSelection) {
    NSMutableSet* allNodes = [NSMutableSet setWithSet:nodes];
    [allNodes unionSet:[self selectedNodes]];
    nodes = allNodes;
  }
  self.selectedNodes = nodes;
  [self setCursorNode:node path:path];
}

- (BOOL)canExtendSelectionTo:(IFTreeNode*)node;
{
  return [document rootOfTreeContainingNode:node] == [document rootOfTreeContainingNode:self.cursorNode];
}

- (void)extendSelectionTo:(IFTreeNode*)node path:(IFArrayPath*)path;
{
  NSArray* nodeRootPath = [document pathFromRootTo:node];
  NSArray* cursorRootPath = [document pathFromRootTo:self.cursorNode];
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
  [self selectNodes:newSelection puttingCursorOn:node path:path extendingSelection:YES];
}

// MARK: highlighting

@synthesize highlightedLayer;

- (void)setHighlightedLayer:(IFCompositeLayer*)newHighlightedLayer;
{
  if (newHighlightedLayer == highlightedLayer)
    return;
  if (highlightedLayer != nil)
    highlightedLayer.highlighted = NO;
  if (newHighlightedLayer != nil)
    newHighlightedLayer.highlighted = YES;
  highlightedLayer = newHighlightedLayer;
}

@end
