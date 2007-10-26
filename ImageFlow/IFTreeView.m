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
#import "IFImageInspectorWindowController.h"
#import "IFHistogramInspectorWindowController.h"
#import "IFTreeTemplate.h"
#import "IFTreeTemplateManager.h"
#import "IFTreeNodeProxy.h"
#import "IFUtilities.h"

@interface IFTreeView (Private)
- (NSRect)paddedBounds;
- (void)updateBounds;
- (void)highlightElement:(IFTreeLayoutSingle*)element;
- (void)clearHighlighting;
- (void)setCopiedNode:(IFTreeNode*)newCopiedNode;
- (IFTreeNode*)copiedNode;
- (void)updateUnreachableNodes;
- (void)setUnreachableNodes:(NSSet*)newUnreachableNodes;
- (void)clearSelectedNodes;
- (void)setSelectedNodes:(NSSet*)newSelectedNodes;
- (NSSet*)selectedNodes;
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

static NSString* IFPrivatePboard = @"ImageFlowPrivatePasteboard";

NSString* IFMarkPboardType = @"IFMarkPboardType";
NSString* IFTreeNodeArrayPboardType = @"IFTreeNodeArrayPboardType";
NSString* IFTreeNodePboardType = @"IFTreeNodePboardType";

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
  IFTreeMark* cursorMark = [IFTreeMark mark];
  IFTreeMark* viewMark = [IFTreeMark mark];
  allMarks = [[marks arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:cursorMark,viewMark,nil]] retain];
  cursors = [[IFTreeCursorPair treeCursorPairWithEditMark:cursorMark viewMark:viewMark] retain];
  unreachableNodes = [NSSet new];
  selectedNodes = [NSMutableSet new];
  copiedNode = nil;
  
  trackingRectTags = [NSMutableArray new];

  [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,IFTreeNodeArrayPboardType,IFMarkPboardType,nil]];

  [cursors addObserver:self forKeyPath:@"viewLockedNode" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:IFViewLockedChangedContext];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentTreeChanged:) name:IFTreeChangedNotification object:nil];
  
  return self;
}

- (void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [cursors removeObserver:self forKeyPath:@"isViewLocked"];

  [self unregisterDraggedTypes];

  [self clearHighlighting];
  [self removeAllTrackingRects];
  [self setDocument:nil];

  OBJC_RELEASE(trackingRectTags);

  OBJC_RELEASE(copiedNode);
  OBJC_RELEASE(selectedNodes);
  OBJC_RELEASE(unreachableNodes);
  OBJC_RELEASE(cursors);
  OBJC_RELEASE(allMarks);
  OBJC_RELEASE(marks);

  [super dealloc];
}

- (void)awakeFromNib;
{
  NSAssert(layoutParameters != nil, @"internal error");

  [super awakeFromNib];
  layoutStrategy = [[IFTreeLayoutStrategy alloc] initWithView:self parameters:layoutParameters];
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
    [[layoutParameters highlightingColor] set];
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
    NSPasteboard* pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    [pasteboard declareTypes:[NSArray arrayWithObject:IFTreeNodeArrayPboardType] owner:self];
    NSArray* nodes = [[IFTreeNodeProxy collect] proxyForNode:[[self selectedNodes] each] ofDocument:document];
    NSData* data = [NSArchiver archivedDataWithRootObject:nodes];
    [pasteboard setData:data forType:IFTreeNodeArrayPboardType];
  
    [self dragImage:[elementUnderMouse dragImage] at:[elementUnderMouse frame].origin offset:NSZeroSize event:event pasteboard:pasteboard source:self slideBack:YES];    
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
  [document deleteContiguousNodes:[self selectedNodes]];
}

- (void)deleteBackward:(id)sender;
{
  [self delete:sender];
}

- (void)deleteNodeUnderMouse:(id)sender;
{
  IFTreeNode* designatedNode = [[layoutStrategy deleteButtonCell] representedObject];
  [document deleteNode:designatedNode];
}

- (void)insertNewline:(id)sender
{
  [document insertNode:[IFTreeNode ghostNodeWithInputArity:1] asChildOf:[self cursorNode]];
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
  [document addTree:[IFTreeNodeAlias nodeAliasWithOriginal:[self cursorNode]]];
}

#pragma mark Copy and paste

- (void)copy:(id)sender;
{
  NSSet* nodesToCopy = [self selectedNodes];
  NSAssert([nodesToCopy count] == 1, @"cannot copy multiple nodes (TODO)");
  IFTreeNode* nodeToCopy = [nodesToCopy anyObject];
  NSPasteboard* pasteboard = [NSPasteboard pasteboardWithName:IFPrivatePboard];
  [pasteboard declareTypes:[NSArray arrayWithObject:IFTreeNodePboardType] owner:self];
  [self setCopiedNode:nodeToCopy];
}  

- (void)pasteboard:(NSPasteboard*)sender provideDataForType:(NSString*)type;
{
  NSAssert1([type isEqualToString:IFTreeNodePboardType], @"unexpected pasteboard type: %@",type);
  [sender setData:[NSArchiver archivedDataWithRootObject:[IFTreeNodeProxy proxyForNode:[self copiedNode] ofDocument:document]]
          forType:IFTreeNodePboardType];
}

- (void)pasteboardChangedOwner:(NSPasteboard *)sender;
{
  [self setCopiedNode:nil];
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

  NSPasteboard* pasteboard = [NSPasteboard pasteboardWithName:IFPrivatePboard];
  NSString* available = [pasteboard availableTypeFromArray:[NSArray arrayWithObject:IFTreeNodePboardType]];
  if (available == nil) {
    NSBeep(); // TODO deactivate menu instead (or additionally)
    return;
  }
  IFTreeNodeProxy* proxy = [NSUnarchiver unarchiveObjectWithData:[pasteboard dataForType:IFTreeNodePboardType]];
  IFTreeNode* node = [[proxy node] cloneNode];
  if ([document canReplaceGhostNode:[self cursorNode] usingNode:node])
    [document replaceGhostNode:[self cursorNode] usingNode:node];
  else
    NSBeep();
}

#pragma mark Drag and drop

// NSDraggingSource methods

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal;
{
  return isLocal ? NSDragOperationEvery : NSDragOperationDelete;
}

- (void)draggedImage:(NSImage*)image endedAt:(NSPoint)point operation:(NSDragOperation)operation;
{
  if (operation != NSDragOperationDelete)
    return;

  NSPasteboard* pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
  NSArray* types = [pboard types];

  if ([types containsObject:IFMarkPboardType]) {
    int markIndex = [(NSNumber*)[NSUnarchiver unarchiveObjectWithData:[pboard dataForType:IFMarkPboardType]] intValue];
    [(IFTreeMark*)[marks objectAtIndex:markIndex] unset];
  } else if ([types containsObject:IFTreeNodeArrayPboardType]) {
    NSArray* nodeProxies = [NSUnarchiver unarchiveObjectWithData:[pboard dataForType:IFTreeNodeArrayPboardType]];
    [document deleteContiguousNodes:[NSSet setWithArray:(NSArray*)[[nodeProxies collect] node]]];
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
  if ([types containsObject:IFTreeNodeArrayPboardType])
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
  if (dragKind == IFDragKindUnknown)
    return NSDragOperationNone;

  NSPoint targetLocation = [self convertPoint:[sender draggingLocation] fromView:nil];
  IFTreeLayoutSingle* targetElement = (IFTreeLayoutSingle*)[self layoutElementAtPoint:targetLocation inLayerAtIndex:IFLayoutLayerTree];
  BOOL highlightTarget;

  NSDragOperation allowedOperations;
  switch (dragKind) {
    case IFDragKindNode:
      highlightTarget = YES;
      allowedOperations = NSDragOperationEvery;
      break;
    case IFDragKindFileName: {
      if (targetElement != nil) {
        IFTreeNode* node = [targetElement node];
        highlightTarget = [node isGhost] || ([[[node filter] environment] valueForKey:@"fileName"] != nil);
        allowedOperations = highlightTarget ? (NSDragOperationLink | NSDragOperationCopy) : NSDragOperationNone;
      } else
        allowedOperations = NSDragOperationLink;
    } break;
    case IFDragKindMark:
      highlightTarget = YES;
      allowedOperations = NSDragOperationMove|NSDragOperationDelete;
      break;
    default:
      NSAssert(NO,@"unexpected drag kind");
  }
  
  if (highlightTarget)
    [self highlightElement:targetElement];
  else
    [self clearHighlighting];

  return [sender draggingSourceOperationMask] & allowedOperations;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender;
{
  [self clearHighlighting];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
{
  [self clearHighlighting];

  NSPoint targetLocation = [self convertPoint:[sender draggingLocation] fromView:nil];
  IFTreeLayoutSingle* targetElement = (IFTreeLayoutSingle*)[self layoutElementAtPoint:targetLocation inLayerAtIndex:IFLayoutLayerTree];
  IFTreeNode* targetNode = [targetElement node];

  NSPasteboard* pboard = [sender draggingPasteboard];
  switch (dragKind) {
    case IFDragKindNode: {
      NSArray* draggedNodeProxies = [NSUnarchiver unarchiveObjectWithData:[pboard dataForType:IFTreeNodeArrayPboardType]];
      NSSet* draggedNodes = [NSSet setWithArray:(NSArray*)[[draggedNodeProxies collect] node]];
      NSDragOperation operation = [sender draggingSourceOperationMask];

      if (targetNode == nil)
        return NO;
      
      if ((operation & (NSDragOperationCopy|NSDragOperationMove)) != 0) {
        // Copy or move node
        NSAssert([draggedNodes count] == 1, @"cannot drag multiple nodes (TODO)");
        IFTreeNode* draggedMacro = [draggedNodes anyObject];
        if ([targetElement isKindOfClass:[IFTreeLayoutInputConnector class]]) {
          if ([document canInsertNode:draggedMacro asParentOf:targetNode])
            [document insertNode:draggedMacro asParentOf:targetNode];
          else
            return NO;
        } else if ([targetElement isKindOfClass:[IFTreeLayoutOutputConnector class]]) {
          if ([document canInsertNode:draggedMacro asChildOf:targetNode])
            [document insertNode:draggedMacro asChildOf:targetNode];
          else
            return NO;
        } else {
          NSAssert1([targetElement isKindOfClass:[IFTreeLayoutSingle class]], @"unexpected target element %@",targetElement);
          if ([targetNode isGhost] && [document canReplaceGhostNode:targetNode usingNode:draggedMacro])
            [document replaceGhostNode:targetNode usingNode:draggedMacro];
          else
            return NO;
        }
        if (([sender draggingSourceOperationMask] & NSDragOperationMove) != 0)
          [document deleteContiguousNodes:draggedNodes];
        return YES;        
      } else if ((operation & NSDragOperationLink) != 0) {
        // Link: create node alias
        IFTreeNode* alias = [IFTreeNodeAlias nodeAliasWithOriginal:[draggedNodes anyObject]];
        if ([draggedNodes count] == 1 && [targetNode isGhost] && [document canReplaceGhostNode:targetNode usingNode:alias]) {
          [document replaceGhostNode:targetNode usingNode:alias];
          return YES;
        } else
          return NO;
      } else
        return NO;
    }

    case IFDragKindFileName: {
      NSArray* fileNames = [pboard propertyListForType:NSFilenamesPboardType];
      if (targetElement == nil) {
        // Create new file source nodes for dragged files
        IFTreeTemplate* loadTemplate = [[IFTreeTemplateManager sharedManager] loadFileTemplate];
        IFTreeNode* loadNode = [loadTemplate node];
        for (int i = 0; i < [fileNames count]; ++i) {
          IFTreeNode* newNode = [loadNode cloneNode];
          [[[newNode filter] environment] setValue:[fileNames objectAtIndex:i] forKey:@"fileName"];
          [document addTree:newNode];
        }
        return YES;
      } else if ([targetNode isGhost]) {
        // Replace ghost node by "load" node
        IFTreeTemplate* loadTemplate = [[IFTreeTemplateManager sharedManager] loadFileTemplate];
        IFTreeNode* loadNode = [loadTemplate node];
        [[[loadNode filter] environment] setValue:[fileNames objectAtIndex:0] forKey:@"fileName"];
        if ([document canReplaceGhostNode:targetNode usingNode:loadNode]) {
          [document replaceGhostNode:targetNode usingNode:[loadNode cloneNode]];
          return YES;
        } else
          return NO;
      } else if ([[[targetNode filter] environment] valueForKey:@"fileName"] != nil) {
        // Change "fileName" entry in environment to the dropped file name.
        [[[targetNode filter] environment] setValue:[fileNames objectAtIndex:0] forKey:@"fileName"];
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
        [[roots objectAtIndex:i] translateBy:NSMakePoint(NSMaxX([[roots objectAtIndex:i-1] frame]) + [layoutParameters gutterWidth],0)];
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

- (void)documentTreeChanged:(NSNotification*)aNotification;
{
  [self invalidateLayout];
}

- (NSRect)paddedBounds;
{
  NSRect unpaddedBounds = [[self layoutLayerAtIndex:IFLayoutLayerTree] frame];
  return NSInsetRect(unpaddedBounds,-[layoutParameters gutterWidth],-3.0);
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

#pragma mark Copy and paste

- (void)setCopiedNode:(IFTreeNode*)newCopiedNode;
{
  if (newCopiedNode == copiedNode)
    return;
  [copiedNode release];
  copiedNode = [newCopiedNode retain];
}

- (IFTreeNode*)copiedNode;
{
  return copiedNode;
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
  NSEnumerator* nodesEnum = [newSelectedNodes objectEnumerator];
  IFTreeNode* node;
  while (node = [nodesEnum nextObject]) {
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
  NSEnumerator* nodesEnum = [nodes objectEnumerator];
  IFTreeLayoutNode* layoutNode;
  while (layoutNode = [nodesEnum nextObject])
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
  NSEnumerator* nodesEnum = [nodes objectEnumerator];
  IFTreeLayoutNode* layoutNode;
  while (layoutNode = [nodesEnum nextObject]) {
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
    
    NSEnumerator* candidatesEnum = [candidates objectEnumerator];
    IFTreeLayoutElement* candidate;
    IFTreeLayoutElement* bestCandidate = nil;
    float bestCandidateDistancePar = searchDistance, bestCandidateDistancePer = searchDistance;
    while (candidate = [candidatesEnum nextObject]) {
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
