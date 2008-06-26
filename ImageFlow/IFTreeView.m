//
//  IFTreeView.m
//  ImageFlow
//
//  Created by Michel Schinz on 15.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFTreeView.h"
#import "IFTreeNodeAlias.h"
#import "IFTreeNode.h"
#import "IFTreeLayoutElement.h"
#import "IFTreeLayoutMark.h"
#import "IFTreeLayoutInputConnector.h"
#import "IFTreeLayoutOutputConnector.h"
#import "IFTreeLayoutComposite.h"
#import "IFHistogramInspectorWindowController.h"
#import "IFTreeTemplate.h"
#import "IFTreeTemplateManager.h"
#import "IFUtilities.h"

@interface IFTreeView (Private)
- (IFTree*)newLoadTreeForFileNamed:(NSString*)fileName;
- (NSRect)paddedBounds;
- (void)updateBounds;
- (void)highlightElement:(IFTreeLayoutSingle*)element;
- (void)clearHighlighting;
- (void)updateUnreachableNodes;
- (void)setUnreachableNodes:(NSSet*)newUnreachableNodes;
- (void)clearSelectedNodes;
- (void)setSelectedNodes:(NSSet*)newSelectedNodes;
- (NSSet*)selectedNodes;
- (IFSubtree*)selectedSubtree;
- (void)setCursorNode:(IFTreeNode*)newCursorNode;
- (IFTreeNode*)cursorNode;
- (void)selectNodes:(NSSet*)nodes puttingCursorOn:(IFTreeNode*)node extendingSelection:(BOOL)extendSelection;
- (void)addToolTipsForLayoutNodes:(NSSet*)nodes;
- (void)addTrackingRectsForLayoutNodes:(NSSet*)layoutNodes;
- (void)removeAllTrackingRects;
- (void)moveToNode:(IFTreeNode*)node extendingSelection:(BOOL)extendSelection;
- (void)moveToNodeRepresentedBy:(IFTreeLayoutElement*)layoutElem extendingSelection:(BOOL)extendSelection;
- (void)moveToClosestNodeInDirection:(IFDirection)direction extendingSelection:(BOOL)extendSelection;
@end

@implementation IFTreeView

enum IFLayoutLayer {
  IFLayoutLayerTree,
  IFLayoutLayerSidePane,
  IFLayoutLayerSelection,
  IFLayoutLayerMarks
};

//static NSString* IFMarkChangedContext = @"IFMarkChangedContext";
//static NSString* IFCursorMovedContext = @"IFCursorMovedContext";
static NSString* IFViewLockedChangedContext = @"IFViewLockedChangedContext";

- (id)initWithFrame:(NSRect)frame;
{
  if (![super initWithFrame:frame layersCount:4])
    return nil;

  marks = [[NSArray arrayWithObjects:
    [IFTreeMark mark],
    [IFTreeMark mark],
    [IFTreeMark mark],
    [IFTreeMark mark],
    [IFTreeMark mark],
    [IFTreeMark mark],
    [IFTreeMark mark],
    [IFTreeMark mark],
    [IFTreeMark mark],
    [IFTreeMark mark],
    nil] retain];
  unreachableNodes = [NSSet new];
  selectedNodes = [NSMutableSet new];
  
  trackingRectTags = [NSMutableArray new];

  [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,IFTreePboardType,IFMarkPboardType,nil]];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentTreeChanged:) name:IFTreeChangedNotification object:nil];
  
  return self;
}

- (void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  [self unregisterDraggedTypes];

  [self clearHighlighting];
  [self removeAllTrackingRects];
  [self setDocument:nil];

  OBJC_RELEASE(trackingRectTags);

  OBJC_RELEASE(selectedNodes);
  OBJC_RELEASE(unreachableNodes);
  if (cursors != nil) {
    [cursors removeObserver:self forKeyPath:@"isViewLocked"];
    OBJC_RELEASE(cursors);
  }
  OBJC_RELEASE(marks);

  [super dealloc];
}

- (void)awakeFromNib;
{
  NSAssert(layoutParameters != nil, @"internal error");

  [super awakeFromNib];
  layoutStrategy = [[IFTreeLayoutStrategy alloc] initWithView:self parameters:layoutParameters];
}

- (void)setDocument:(IFDocument*)theDocument;
{
  [super setDocument:theDocument];

  NSAssert(cursors == nil, @"cursors already set!");
  cursors = [[IFTreeCursorPair treeCursorPairWithTree:[theDocument tree] editMark:[IFTreeMark mark] viewMark:[IFTreeMark mark]] retain];
  [cursors addObserver:self forKeyPath:@"viewLockedNode" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:IFViewLockedChangedContext];
}

- (IFTreeLayoutStrategy*)layoutStrategy;
{
  return layoutStrategy;
}

- (NSSize)idealSize;
{
  return [self paddedBounds].size;
}

#pragma mark NSView methods

-(BOOL)acceptsFirstResponder;
{
  return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent*)theEvent;
{
  return YES;
}

- (BOOL)isOpaque;
{
  return YES;
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize;
{
  [self updateBounds];
}

- (BOOL)validateMenuItem:(NSMenuItem*)item;
{
  const SEL action = [item action];
  if (action == @selector(toggleNodeFoldingState:))
    return [[document tree] parentsCountOfNode:[self cursorNode]] > 0;
  else if (action == @selector(removeBookmark:) || action == @selector(goToBookmark:))
    return [[marks objectAtIndex:[item tag]] isSet];
  else
    return YES;
}

- (void)drawRect:(NSRect)rect;
{
  [super drawRect:rect];
  
  if (highlightingPath != nil) {
    [layoutParameters.highlightingColor set];
    [highlightingPath fill];
    [highlightingPath stroke];
  }
}

#pragma mark Cursors and bookmarks

- (IFTreeCursorPair*)cursors;
{
  return cursors;
}

- (IBAction)setBookmark:(id)sender;
{
  NSMenuItem* item = sender;
  [[marks objectAtIndex:[item tag]] setLikeMark:[cursors editMark]];
}

- (IBAction)removeBookmark:(id)sender;
{
  NSMenuItem* item = sender;
  IFTreeMark* mark = [marks objectAtIndex:[item tag]];
  if ([mark isSet])
    [mark unset];
  else
    NSBeep();
}

- (IBAction)goToBookmark:(id)sender;
{
  NSMenuItem* item = sender;
  IFTreeMark* mark = [marks objectAtIndex:[item tag]];
  if ([mark isSet])
    [self moveToNode:[mark node] extendingSelection:NO];
  else
    NSBeep();
}

#pragma mark Actions / event handling

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context;
{
//  if (context == IFCursorMovedContext) {
//    [self invalidateLayoutLayer:IFLayoutLayerSelection];
//    [self scrollRectToVisible:[[layoutStrategy layoutNodeForTreeNode:[self cursorNode]] frame]];
//  } else if (context == IFMarkChangedContext)
//    [self invalidateLayoutLayer:IFLayoutLayerMarks];
  if (context == IFViewLockedChangedContext) {
    id oldNode = [change objectForKey:NSKeyValueChangeOldKey];
    id newNode = [change objectForKey:NSKeyValueChangeNewKey];
    NSAssert((oldNode == [NSNull null] && newNode != [NSNull null]) || (oldNode != [NSNull null] && newNode == [NSNull null]),
             @"internal error");
    IFTreeNode* viewLockedNode = (oldNode != [NSNull null] ? oldNode : newNode);

    IFTreeLayoutNode* layoutElem = (IFTreeLayoutNode*)
      [[self layoutLayerAtIndex:IFLayoutLayerTree] layoutElementForNode:viewLockedNode kind:IFTreeLayoutElementKindNode];
    [layoutElem toggleIsViewLocked];
    [self updateUnreachableNodes];
  } else
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}  

- (void)mouseEntered:(NSEvent*)event;
{
  pointedElement = [event userData];
  [self invalidateLayoutLayer:IFLayoutLayerSidePane];
}

- (void)mouseExited:(NSEvent*)event;
{
  pointedElement = nil;
  [self invalidateLayoutLayer:IFLayoutLayerSidePane];
}

- (void)mouseDown:(NSEvent*)theEvent;
{
  if ([grabableViewMixin handlesMouseDown:theEvent])
    return;

  NSPoint localPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  IFTreeLayoutElement* clickedElement = [self layoutElementAtPoint:localPoint];

  if ([clickedElement isKindOfClass:[IFTreeLayoutMark class]]) {
    IFTreeLayoutMark* markElement = (IFTreeLayoutMark*)clickedElement;
  
    NSPasteboard* pasteBoard = [NSPasteboard pasteboardWithName:NSDragPboard];
    [pasteBoard declareTypes:[NSArray arrayWithObject:IFMarkPboardType] owner:self];
    NSData* data = [NSArchiver archivedDataWithRootObject:[NSNumber numberWithInt:[markElement markIndex]]];
    [pasteBoard setData:data forType:IFMarkPboardType];

    [self dragImage:[clickedElement dragImage] at:[clickedElement frame].origin offset:NSZeroSize event:theEvent pasteboard:pasteBoard source:self slideBack:YES];
  } else if ([clickedElement isKindOfClass:[IFTreeLayoutSingle class]]) {
    IFTreeNode* clickedNode = [clickedElement node];
    if ([unreachableNodes containsObject:clickedNode]) {
      NSBeep();
      return;
    }
    BOOL extendSelection = ([theEvent modifierFlags] & NSShiftKeyMask) != 0;
    switch ([theEvent clickCount]) {
      case 1:
        [self moveToNodeRepresentedBy:clickedElement extendingSelection:extendSelection];
        [clickedElement activateWithMouseDown:theEvent];
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
  } else {
    [clickedElement activateWithMouseDown:theEvent];
  }
}

- (void)mouseDragged:(NSEvent*)event;
{
  if ([grabableViewMixin handlesMouseDragged:event])
    return;

  NSPoint localPoint = [self convertPoint:[event locationInWindow] fromView:nil];
  IFTreeLayoutElement* elementUnderMouse = [self layoutElementAtPoint:localPoint];

  if ([elementUnderMouse node] == [self cursorNode]) {
    NSPasteboard* pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    [pboard declareTypes:[NSArray arrayWithObject:IFTreePboardType] owner:self];
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:[[self selectedSubtree] extractTree]] forType:IFTreePboardType];

    isCurrentDragLocal = NO;
    [self dragImage:[elementUnderMouse dragImage] at:[elementUnderMouse frame].origin offset:NSZeroSize event:event pasteboard:pboard source:self slideBack:YES];    
  }
}

- (void)mouseUp:(NSEvent*)event;
{
  if (![grabableViewMixin handlesMouseUp:event])
    [super mouseUp:event];
}

// Cursor movement

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

- (void)keyDown:(NSEvent*)event;
{
  if (![grabableViewMixin handlesKeyDown:event])
    [self interpretKeyEvents:[NSArray arrayWithObject:event]];
}

- (void)keyUp:(NSEvent*)event;
{
  if (![grabableViewMixin handlesKeyUp:event])
    [super keyUp:event];
}

- (void)cancelOperation:(id)sender;
{
  if ([[cursors editMark] isSet])
    [[layoutStrategy layoutNodeForTreeNode:[self cursorNode]] activate];
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

- (void)deleteNodeUnderMouse:(id)sender;
{
  IFSubtree* subtree = [IFSubtree subtreeOf:[document tree] includingNodes:[NSSet setWithObject:[[layoutStrategy deleteButtonCell] representedObject]]];
  if ([document canDeleteSubtree:subtree])
    [document deleteSubtree:subtree];
  else
    NSBeep();
}

- (void)insertNewline:(id)sender
{
  [document insertCopyOfTree:[IFTree ghostTreeWithArity:1] asChildOfNode:[self cursorNode]];
  [self moveToNode:[self cursorNode] extendingSelection:NO];
}

- (IBAction)toggleNodeFoldingState:(id)sender;
{
  IFTreeNode* node = [self cursorNode];
  [node setIsFolded:![node isFolded]];
  [self invalidateLayout];
}

- (void)foldNodeUnderMouse:(id)sender;
{
  IFTreeNode* designatedNode = [[layoutStrategy foldButtonCell] representedObject];
  [designatedNode setIsFolded:![designatedNode isFolded]];
  [self invalidateLayout];
}

- (IBAction)makeNodeAlias:(id)sender;
{
  [document addCopyOfTree:[IFTree treeWithNode:[IFTreeNodeAlias nodeAliasWithOriginal:[self cursorNode]]]];
}

#pragma mark Copy and paste

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

#pragma mark Drag and drop

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
  if ([[cursors editMark] isSet])
    [[layoutStrategy layoutNodeForTreeNode:[self cursorNode]] deactivate];

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

  NSPoint targetLocation = [self convertPoint:[sender draggingLocation] fromView:nil];
  IFTreeLayoutSingle* targetElement = (IFTreeLayoutSingle*)[self layoutElementAtPoint:targetLocation inLayerAtIndex:IFLayoutLayerTree];
  IFTreeNode* targetNode = targetElement == nil ? nil : [targetElement node];
  BOOL highlightTarget;

  NSDragOperation allowedOperationsMask;
  switch (dragKind) {
    case IFDragKindNode:
      highlightTarget = (targetNode != nil && ([targetNode isGhost] || [targetElement kind] == IFTreeLayoutElementKindInputConnector || [targetElement kind] == IFTreeLayoutElementKindOutputConnector));
      allowedOperationsMask = NSDragOperationEvery;
      break;
    case IFDragKindFileName: {
      if (targetElement != nil) {
        IFTreeNode* node = [targetElement node];
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
  
  if (highlightTarget)
    [self highlightElement:targetElement];
  else
    [self clearHighlighting];

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
  [self clearHighlighting];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
{
  [self clearHighlighting];

  isCurrentDragLocal = ([sender draggingSource] == self);
  
  NSPoint targetLocation = [self convertPoint:[sender draggingLocation] fromView:nil];
  IFTreeLayoutSingle* targetElement = (IFTreeLayoutSingle*)[self layoutElementAtPoint:targetLocation inLayerAtIndex:IFLayoutLayerTree];
  IFTreeNode* targetNode = [targetElement node];
  
  NSPasteboard* pboard = [sender draggingPasteboard];
  switch (dragKind) {
    case IFDragKindNode: {
      enum { IFReplace, IFInsertAsChild, IFInsertAsParent } operationKind;
      if ([targetElement kind] == IFTreeLayoutElementKindInputConnector)
        operationKind = IFInsertAsParent;
      else if ([targetElement kind] == IFTreeLayoutElementKindOutputConnector)
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
      if (targetElement == nil) {
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
      if (targetElement == nil)
        return NO;
      int markIndex = [(NSNumber*)[NSUnarchiver unarchiveObjectWithData:[pboard dataForType:IFMarkPboardType]] intValue];
      [(IFTreeMark*)[marks objectAtIndex:markIndex] setNode:[targetElement node]];
      return YES;
    }

    default:
      NSAssert(NO,@"unexpected drag kind");
      return NO;
  }
}

#pragma mark Layout

- (IFTreeLayoutElement*)layoutForLayer:(int)layer;
{
  switch (layer) {
    case IFLayoutLayerTree: {
      [self removeAllTrackingRects];
      [self removeAllToolTips];
      
      NSArray* roots = (NSArray*)[[layoutStrategy collect] layoutTree:[[document roots] each]];
      for (int i = 1; i < [roots count]; ++i)
        [[roots objectAtIndex:i] translateBy:NSMakePoint(NSMaxX([[roots objectAtIndex:i-1] frame]) + layoutParameters.gutterWidth,0)];
      IFTreeLayoutElement* layer = [IFTreeLayoutComposite layoutCompositeWithElements:[NSSet setWithArray:roots] containingView:self];
      
      // Now that all elements are at their final position, establish tool tips and tracking rects
      NSSet* leaves = [layer leavesOfKind:IFTreeLayoutElementKindNode];
      [self addToolTipsForLayoutNodes:leaves];
      [self addTrackingRectsForLayoutNodes:leaves];
      return layer;
    }
    case IFLayoutLayerSidePane:
      return [layoutStrategy layoutSidePaneForElement:(IFTreeLayoutSingle*)pointedElement];
    case IFLayoutLayerSelection:
      return [layoutStrategy layoutSelectedNodes:[self selectedNodes] cursor:[self cursorNode] forTreeLayout:[self layoutLayerAtIndex:IFLayoutLayerTree]];
    case IFLayoutLayerMarks:
      return [layoutStrategy layoutMarks:marks forTreeLayout:[self layoutLayerAtIndex:IFLayoutLayerTree]];
    default:
      NSAssert(NO, @"unexpected layer");
      return nil;
  }
}

- (void)layoutDidChange;
{
  [self updateBounds];
}

@end

@implementation IFTreeView (Private)

- (IFTree*)newLoadTreeForFileNamed:(NSString*)fileName;
{
  NSData* archivedClone = [NSKeyedArchiver archivedDataWithRootObject:[[[IFTreeTemplateManager sharedManager] loadFileTemplate] tree]];
  IFTree* clonedTree = [NSKeyedUnarchiver unarchiveObjectWithData:archivedClone];
  [[[clonedTree root] settings] setValue:fileName forKey:@"fileName"];
  return clonedTree;
}

- (void)documentTreeChanged:(NSNotification*)aNotification;
{
  [self invalidateLayout];
}

- (NSRect)paddedBounds;
{
  NSRect unpaddedBounds = [[self layoutLayerAtIndex:IFLayoutLayerTree] frame];
  return NSInsetRect(unpaddedBounds,-layoutParameters.gutterWidth,-3.0);
}

- (void)updateBounds;
{
  NSRect newBounds = [self paddedBounds];
  NSSize minSize = [[self superview] frame].size;

  if (NSWidth(newBounds) < minSize.width) {
    newBounds.origin.x -= floor((minSize.width - NSWidth(newBounds)) / 2.0);
    newBounds.size.width = minSize.width;
  }
  if (NSHeight(newBounds) < minSize.height)
    newBounds.size.height = minSize.height;
  
  if (NSEqualSizes([self frame].size, newBounds.size) && NSEqualPoints([self bounds].origin,newBounds.origin))
    return;
  
  [self setFrameSize:newBounds.size];
  [self setBoundsOrigin:newBounds.origin];
  [self setNeedsDisplay:YES];
}

#pragma mark Highlighting

- (void)highlightElement:(IFTreeLayoutSingle*)element;
{
  if (element == pointedElement)
    return;
  
  [self clearHighlighting];
  highlightingPath = [[element outlinePath] copy];
  NSPoint translation = [element translation];
  NSAffineTransform* transform = [NSAffineTransform transform];
  [transform translateXBy:translation.x yBy:translation.y];
  [highlightingPath transformUsingAffineTransform:transform];
  const float width = 4;
  [highlightingPath setLineWidth:width];
  [self setNeedsDisplayInRect:NSInsetRect([highlightingPath bounds],-width,-width)];
  pointedElement = element;
}

- (void)clearHighlighting;
{
  if (highlightingPath != nil) {
    const float width = [highlightingPath lineWidth];
    [self setNeedsDisplayInRect:NSInsetRect([highlightingPath bounds],-width,-width)];
    OBJC_RELEASE(highlightingPath);
    pointedElement = nil;
  }
}

#pragma mark View locking

- (void)setUnreachableNodes:(NSSet*)newUnreachableNodes;
{
  NSAssert(newUnreachableNodes != unreachableNodes, @"internal error");

  // update nodes which are in (old union new) \ (old intersection new)
  NSMutableSet* changedNodes = [NSMutableSet setWithSet:unreachableNodes];
  [changedNodes unionSet:newUnreachableNodes];
  NSMutableSet* newOldIntersection = [NSMutableSet setWithSet:unreachableNodes];
  [newOldIntersection intersectSet:newUnreachableNodes];
  [changedNodes minusSet:newOldIntersection];
  
  IFTreeLayoutElement* nodesLayer = [self layoutLayerAtIndex:IFLayoutLayerTree];
  NSSet* changedNodesLayoutElems = [nodesLayer layoutElementsForNodes:changedNodes kind:IFTreeLayoutElementKindNode];
  [[changedNodesLayoutElems do] toggleIsUnreachable];
  
  [unreachableNodes release];
  unreachableNodes = [newUnreachableNodes retain];
}

- (void)updateUnreachableNodes;
{
  NSMutableSet* newUnreachableNodes = [NSMutableSet set];
  if ([cursors isViewLocked]) {
    [newUnreachableNodes unionSet:[document allNodes]];
    [newUnreachableNodes minusSet:[document ancestorsOfNode:[[cursors viewMark] node]]];
  }
  [self setUnreachableNodes:newUnreachableNodes];

  // TODO view locked node
}

#pragma mark Selection

- (void)clearSelectedNodes;
{
  [self setSelectedNodes:[NSSet set]];
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
  
  [self invalidateLayoutLayer:IFLayoutLayerSelection];
}

- (NSSet*)selectedNodes;
{
  if ([self cursorNode] == nil)
    return [NSSet set];
  else if ([selectedNodes count] == 0) {
    IFTreeNode* cursorNode = [self cursorNode];
    return [cursorNode isFolded]
      ? [document ancestorsOfNode:cursorNode]
      : [NSSet setWithObject:cursorNode];
  } else
    return selectedNodes;
}

- (IFSubtree*)selectedSubtree;
{
  return [IFSubtree subtreeOf:[document tree] includingNodes:[self selectedNodes]];
}

- (void)setCursorNode:(IFTreeNode*)newCursorNode;
{
  if (newCursorNode == [self cursorNode])
    return;

  [self clearSelectedNodes];
  [cursors moveToNode:newCursorNode];
}

- (IFTreeNode*)cursorNode;
{
  return [[cursors editMark] node];
}

- (void)selectNodes:(NSSet*)nodes puttingCursorOn:(IFTreeNode*)node extendingSelection:(BOOL)extendSelection;
{
  NSAssert([nodes containsObject:node], @"invalid selection");
  if (extendSelection) {
    NSMutableSet* allNodes = [NSMutableSet setWithSet:nodes];
    [allNodes unionSet:[self selectedNodes]];
    nodes = allNodes;
  }
  [self setCursorNode:node];
  [self setSelectedNodes:nodes];
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

#pragma mark Tool tips

- (void)addToolTipsForLayoutNodes:(NSSet*)nodes;
{
  for (IFTreeLayoutNode* layoutNode in nodes)
    [self addToolTipRect:[layoutNode frame] owner:self userData:layoutNode];
}

- (NSString*)view:(NSView*)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void*)userData;
{
  NSAssert(view == self, @"unexpected view");
  IFTreeLayoutNode* layoutNode = userData;
  return [[layoutNode node] toolTip];
}

#pragma mark Tracking rectangles

- (void)resetCursorRects;
{
  [super resetCursorRects];
  [self removeAllTrackingRects];
  [self addTrackingRectsForLayoutNodes:[[self layoutLayerAtIndex:IFLayoutLayerTree] leavesOfKind:IFTreeLayoutElementKindNode]];
}

- (void)addTrackingRectsForLayoutNodes:(NSSet*)nodes;
{
  for (IFTreeLayoutNode* layoutNode in nodes) {
    NSRect frame = [layoutNode frame];
    NSRect rect = NSMakeRect(NSMinX(frame) - 14.0,NSMinY(frame),NSWidth(frame) + 14.0,NSHeight(frame));
    NSTrackingRectTag tag = [self addTrackingRect:rect owner:self userData:layoutNode assumeInside:NO];
    [trackingRectTags addObject:[NSNumber numberWithInt:tag]];
  }
}

- (void)removeAllTrackingRects;
{
  for (int i = [trackingRectTags count]; i > 0; --i)
    [self removeTrackingRect:[[trackingRectTags objectAtIndex:i-1] intValue]];
}

#pragma mark Cursor movement

- (void)moveToNode:(IFTreeNode*)node extendingSelection:(BOOL)extendSelection;
{
  [self moveToNodeRepresentedBy:[layoutStrategy layoutNodeForTreeNode:node] extendingSelection:extendSelection];
}

- (void)moveToNodeRepresentedBy:(IFTreeLayoutElement*)layoutElem extendingSelection:(BOOL)extendSelection;
{
  IFTreeNode* node = [layoutElem node];
  
  if (![unreachableNodes containsObject:node] && (!extendSelection || [self canExtendSelectionTo:node])) {
    if (extendSelection)
      [self extendSelectionTo:node];
    else
      [self setCursorNode:node];
  } else
    NSBeep();
}

NSPoint IFMidPoint(NSPoint p1, NSPoint p2)
{
  return NSMakePoint(p1.x + (p2.x - p1.x) / 2.0, p1.y + (p2.y - p1.y) / 2.0);
}

NSPoint IFFaceMidPoint(NSRect r, IFDirection faceDirection) {
  NSPoint bl = NSMakePoint(NSMinX(r),NSMinY(r));
  NSPoint br = NSMakePoint(NSMaxX(r),NSMinY(r));
  NSPoint tr = NSMakePoint(NSMaxX(r),NSMaxY(r));
  NSPoint tl = NSMakePoint(NSMinX(r),NSMaxY(r));
  NSPoint p1 = (faceDirection == IFLeft || faceDirection == IFDown) ? bl : tr;
  NSPoint p2 = (faceDirection == IFLeft || faceDirection == IFUp) ? tl : br;
  return IFMidPoint(p1,p2);
}

IFDirection IFPerpendicularDirection(IFDirection d) {
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

IFInterval IFMakeInterval(float begin, float end)
{
  IFInterval i = { begin, end };
  return i;
}

BOOL IFIntersectsInterval(IFInterval i1, IFInterval i2)
{
  return (i1.begin <= i2.begin && i2.begin <= i1.end) || (i2.begin <= i1.begin && i1.begin <= i2.end);
}

float IFIntervalDistance(IFInterval i1, IFInterval i2)
{
  if (IFIntersectsInterval(i1,i2))
    return 0;
  else if (i1.begin < i2.begin)
    return i2.begin - i1.end;
  else
    return i1.begin - i2.end;
}

IFInterval IFProjectRect(NSRect r, IFDirection projectionDirection) {
  return (projectionDirection == IFUp || projectionDirection == IFDown)
  ? IFMakeInterval(NSMinX(r),NSMaxX(r))
  : IFMakeInterval(NSMinY(r),NSMaxY(r));
}

- (void)moveToClosestNodeInDirection:(IFDirection)direction extendingSelection:(BOOL)extendSelection;
{
  const float searchDistance = 1000;

  IFTreeLayoutElement* treeLayout = [self layoutLayerAtIndex:IFLayoutLayerTree];
  IFTreeLayoutSingle* refLayoutElement = [treeLayout layoutElementForNode:[self cursorNode] kind:IFTreeLayoutElementKindNode];
  NSRect refRect = [refLayoutElement frame];
  
  NSPoint refMidPoint = IFFaceMidPoint(refRect,direction);
  NSPoint searchRectCorner;
  const float epsilon = 0.1;
  switch (direction) {
    case IFUp:
      searchRectCorner = NSMakePoint(refMidPoint.x - searchDistance / 2.0, refMidPoint.y + epsilon);
      break;
    case IFDown:
      searchRectCorner = NSMakePoint(refMidPoint.x - searchDistance / 2.0, refMidPoint.y - (searchDistance + epsilon));
      break;
    case IFLeft:
      searchRectCorner = NSMakePoint(refMidPoint.x - (searchDistance + epsilon), refMidPoint.y - searchDistance / 2.0);
      break;
    case IFRight:
      searchRectCorner = NSMakePoint(refMidPoint.x + epsilon, refMidPoint.y - searchDistance / 2.0);
      break;
    default:
      abort();
  }
  NSRect searchRect = { searchRectCorner, NSMakeSize(searchDistance,searchDistance) };
  
  NSSet* candidates = [treeLayout layoutElementsIntersectingRect:searchRect kind:IFTreeLayoutElementKindNode];
  if ([unreachableNodes count] > 0) {
    NSMutableSet* reachableCandidates = [NSMutableSet setWithSet:candidates];
    [reachableCandidates minusSet:unreachableNodes];
    candidates = reachableCandidates;
  }
  
  if ([candidates count] > 0) {
    IFDirection perDirection = IFPerpendicularDirection(direction);
    
    IFInterval refProjectionPar = IFProjectRect(refRect, direction);
    IFInterval refProjectionPer = IFProjectRect(refRect, perDirection);
    
    IFTreeLayoutElement* bestCandidate = nil;
    float bestCandidateDistancePar = searchDistance, bestCandidateDistancePer = searchDistance;
    for (IFTreeLayoutElement* candidate in candidates) {
      NSRect r = [candidate frame];
      
      float dPer = IFIntervalDistance(refProjectionPar,IFProjectRect(r,direction));
      float dPar = IFIntervalDistance(refProjectionPer,IFProjectRect(r,perDirection));

      if (dPer < bestCandidateDistancePer ||
          (dPer == bestCandidateDistancePer && dPar < bestCandidateDistancePar)) {
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

@end
