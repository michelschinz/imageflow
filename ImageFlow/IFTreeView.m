//
//  IFTreeView.m
//  ImageFlow
//
//  Created by Michel Schinz on 15.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFTreeView.h"
#import "IFTreeNodeAlias.h"
#import "IFTreeLayoutElement.h"
#import "IFTreeLayoutNode.h"
#import "IFTreeLayoutInputConnector.h"
#import "IFTreeLayoutOutputConnector.h"
#import "IFTreeLayoutMark.h"
#import "IFTreeLayoutSidePane.h"
#import "IFTreeLayoutCursor.h"
#import "IFTreeLayoutGhost.h"
#import "IFTreeLayoutComposite.h"
#import "IFTreeNode.h"
#import "IFUtilities.h"
#import "IFAppController.h"
#import "IFImageInspectorWindowController.h"
#import "IFHistogramInspectorWindowController.h"
#import "IFDocumentTemplate.h"
#import "IFDocumentTemplateManager.h"
#import "IFTreeNodeProxy.h"

typedef enum { IFUp, IFDown, IFLeft, IFRight } IFDirection;

@interface IFTreeView (Private)
- (NSRect)paddedBounds;
- (void)recomputeFrameSize;
- (void)highlightElement:(IFTreeLayoutSingle*)element;
- (void)clearHighlighting;
- (void)setCopiedNode:(IFTreeNode*)newCopiedNode;
- (IFTreeNode*)copiedNode;
- (void)clearSelectedNodes;
- (void)setSelectedNodes:(NSSet*)newSelectedNodes;
- (NSSet*)selectedNodes;
- (void)setCursorNode:(IFTreeNode*)newCursorNode;
- (IFTreeNode*)cursorNode;
- (void)updateLayout:(NSNotification*)notification;
- (void)selectNodes:(NSSet*)nodes puttingCursorOn:(IFTreeNode*)node;
- (void)invalidateLayoutLayer:(int)layoutLayer;
- (void)invalidateLayout;
- (void)enqueueLayoutNotification;
- (IFTreeLayoutElement*)layoutTree:(IFTreeNode*)root;
- (IFTreeLayoutNode*)layoutNodeForTreeNode:(IFTreeNode*)theNode;
- (IFTreeLayoutElement*)layoutInputConnectorForTreeNode:(IFTreeNode*)node;
- (IFTreeLayoutElement*)layoutOutputConnectorForTreeNode:(IFTreeNode*)node tag:(NSString*)tag leftReach:(float)lReach rightReach:(float)rReach;
- (IFTreeLayoutElement*)layoutSidePaneForElement:(IFTreeLayoutSingle*)base;
- (IFTreeLayoutElement*)layoutSelectedNodes:(NSSet*)nodes cursor:(IFTreeNode*)cursorNode forTreeLayout:(IFTreeLayoutElement*)rootLayout;
- (IFTreeLayoutElement*)layoutMarks:(NSArray*)marks forTreeLayout:(IFTreeLayoutElement*)rootLayout;
- (IFTreeLayoutElement*)layoutElementAtPoint:(NSPoint)point inLayerAtIndex:(int)layerIndex;
- (IFTreeLayoutElement*)layoutElementAtPoint:(NSPoint)point;
- (void)addToolTipsForLayoutNodes:(NSSet*)nodes;
- (void)addTrackingRectsForLayoutNodes:(NSSet*)layoutNodes;
- (void)removeAllTrackingRects;
- (void)moveToNode:(IFTreeNode*)node;
- (void)moveToNodeRepresentedBy:(IFTreeLayoutElement*)layoutElem;
- (void)moveToClosestNodeInDirection:(IFDirection)direction;
@end

@implementation IFTreeView

static NSString* IFPrivatePboard = @"ImageFlowPrivatePasteboard";

NSString* IFMarkPboardType = @"IFMarkPboardType";
NSString* IFTreeNodesPboardType = @"IFTreeNodesPboardType";
NSString* IFTreeNodePboardType = @"IFTreeNodePboardType";

typedef enum {
  IFLayoutLayerTree,
  IFLayoutLayerSidePane,
  IFLayoutLayerSelection,
  IFLayoutLayerMarks
} IFLayoutLayer;

static NSString* IFTreeViewNeedsLayout = @"IFTreeViewNeedsLayout";

static NSString* IFMarkChangedContext = @"IFMarkChangedContext";
static NSString* IFCursorMovedContext = @"IFCursorMovedContext";
static NSString* IFBoundsChangedContext = @"IFBoundsChangedContext";

static const float NODE_INTERNAL_MARGIN = 4.0;
static const float GUTTER_WIDTH = 14.0 + 4.0;
static const float SIDE_PANE_CORNER_RADIUS = 4.0;
static const float CURSOR_PATH_WIDTH = 3.0;
static const float SELECTION_PATH_WIDTH = 1.0;

static NSColor* sidePaneColor;
static NSSize sidePaneSize;

+ (void)initialize;
{
  sidePaneColor = [[NSColor colorWithCalibratedWhite:0.8 alpha:1.0] retain];
  sidePaneSize = NSMakeSize(15,50);
}

- (id)initWithFrame:(NSRect)frame;
{
  if (![super initWithFrame:frame]) return nil;

  grabableViewMixin = [[IFGrabableViewMixin alloc] initWithView:self];
  
  backgroundColor = [[NSColor colorWithCalibratedWhite:0.5 alpha:1.0] retain];
  layoutLayers = [[NSMutableArray alloc] initWithObjects:
    [NSNull null],
    [NSNull null],
    [NSNull null],
    [NSNull null],
    nil];
  trackingRectTags = [NSMutableArray new];
  selectedNodes = [NSMutableSet new];
  copiedNode = nil;
  showThumbnails = NO;
  columnWidth = 50.0;

  labelFont = [[NSFont fontWithName:@"Verdana" size:9.0] retain];
  NSLayoutManager* layoutManager = [[NSLayoutManager alloc] init];
  labelFontHeight = [layoutManager defaultLineHeightForFont:labelFont];
  [layoutManager release];
  
  connectorColor = [[NSColor colorWithCalibratedWhite:0.2 alpha:1.0] retain];
  connectorLabelColor = [[NSColor colorWithCalibratedWhite:0.6 alpha:1.0] retain];
  connectorArrowSize = 4.0;

  cursorColor = [[NSColor redColor] retain];
  markBackgroundColor = [[NSColor blueColor] retain];
  highlightingColor = [[[NSColor blueColor] colorWithAlphaComponent:0.5] retain];

  layoutNodes = createMutableDictionaryWithRetainedKeys();
  layoutThumbnails = createMutableDictionaryWithRetainedKeys();
  
  [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,IFTreeNodesPboardType,IFMarkPboardType,nil]];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLayout:) name:IFTreeViewNeedsLayout object:self];
  return self;
}

- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self unregisterDraggedTypes];

  [self clearHighlighting];
  [self removeAllTrackingRects];
  [self setDocument:nil];

  [sidePanePath release];
  sidePanePath = nil;
  [deleteButtonCell release];
  deleteButtonCell = nil;
  [layoutThumbnails release];
  layoutThumbnails = nil;
  [layoutNodes release];
  layoutNodes = nil;
  [highlightingColor release];
  highlightingColor = nil;
  [markBackgroundColor release];
  markBackgroundColor = nil;
  [cursorColor release];
  cursorColor = nil;
  [connectorLabelColor release];
  connectorLabelColor = nil;
  [connectorColor release];
  connectorColor = nil;
  [labelFont release];
  labelFont = nil;

  [copiedNode release];
  copiedNode = nil;
  [selectedNodes release];
  selectedNodes = nil;
  [trackingRectTags release];
  trackingRectTags = nil;
  [layoutLayers release];
  layoutLayers = nil;
  [backgroundColor release];
  backgroundColor = nil;
  
  [grabableViewMixin release];
  grabableViewMixin = nil;
  [super dealloc];
}

-(BOOL)acceptsFirstResponder {
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

- (void)setDocument:(IFDocument*)newDocument {
  if (document != nil) {
    NSArray* marks = [document marks];
    NSEnumerator* marksEnum = [marks objectEnumerator];
    IFTreeMark* mark;
    while (mark = [marksEnum nextObject])
      [mark removeObserver:self forKeyPath:@"node"];
    [document removeObserver:self forKeyPath:@"cursorMark.node"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFTreeChangedNotification object:document];
  }
  document = newDocument;  // don't retain, to avoid cycles.
  if (document != nil) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentTreeChanged:)
                                                 name:IFTreeChangedNotification
                                               object:document];
    [document addObserver:self forKeyPath:@"cursorMark.node" options:0 context:IFCursorMovedContext];
    NSArray* marks = [document marks];
    NSEnumerator* marksEnum = [marks objectEnumerator];
    IFTreeMark* mark;
    while (mark = [marksEnum nextObject])
      [mark addObserver:self forKeyPath:@"node" options:0 context:IFMarkChangedContext];
  }
  [self invalidateLayout];
}

- (IFDocument*)document;
{
  return document;
}

#pragma mark Layout parameters

- (float)columnWidth;
{
  return columnWidth;
}

- (void)setColumnWidth:(float)newColumnWidth;
{
  float roundedNewColumnWidth = round(newColumnWidth);
  if (roundedNewColumnWidth == columnWidth)
    return;
  columnWidth = roundedNewColumnWidth;
  [self invalidateLayout];
}

- (NSColor*)backgroundColor;
{
  return backgroundColor;
}

- (float)nodeInternalMargin;
{
  return NODE_INTERNAL_MARGIN;
}

- (NSFont*)labelFont;
{
  return labelFont;
}

- (float)labelFontHeight;
{
  return labelFontHeight;
}

- (NSColor*)sidePaneColor;
{
  return sidePaneColor;
}

- (NSSize)sidePaneSize;
{
  return sidePaneSize;
}

- (NSBezierPath*)sidePanePath;
{
  if (sidePanePath == nil) {
    NSSize sidePaneSize = [self sidePaneSize];
    float externalMargin = [self nodeInternalMargin];
    
    sidePanePath = [[NSBezierPath bezierPath] retain];
    [sidePanePath moveToPoint:NSMakePoint(0,externalMargin)];
    [sidePanePath lineToPoint:NSMakePoint(0,sidePaneSize.height + externalMargin)];
    [sidePanePath appendBezierPathWithArcWithCenter:NSMakePoint(-(sidePaneSize.width - SIDE_PANE_CORNER_RADIUS),
                                                                sidePaneSize.height + externalMargin - SIDE_PANE_CORNER_RADIUS)
                                             radius:SIDE_PANE_CORNER_RADIUS
                                         startAngle:90
                                           endAngle:180];
    [sidePanePath appendBezierPathWithArcWithCenter:NSMakePoint(-(sidePaneSize.width - SIDE_PANE_CORNER_RADIUS),
                                                                externalMargin + SIDE_PANE_CORNER_RADIUS)
                                             radius:SIDE_PANE_CORNER_RADIUS
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

- (NSColor*)connectorColor;
{
  return connectorColor;
}

- (NSColor*)connectorLabelColor;
{
  return connectorLabelColor;
}

- (float)connectorArrowSize;
{
  return connectorArrowSize;
}

- (NSColor*)cursorColor;
{
  return cursorColor;
}

- (NSColor*)markBackgroundColor;
{
  return markBackgroundColor;
}

- (NSColor*)highlightingColor;
{
  return highlightingColor;
}

- (NSSize)idealSize;
{
  return [self paddedBounds].size;
}

- (BOOL)showThumbnails;
{
  return showThumbnails;
}

- (void)setShowThumbnails:(BOOL)theValue;
{
  if (theValue != showThumbnails) {
    showThumbnails = theValue;
    [self invalidateLayout];
  }
}

- (IBAction)makeNodeAlias:(id)sender;
{
  [document addTree:[IFTreeNodeAlias nodeAliasWithOriginal:[self cursorNode]]];
}

- (IBAction)toggleNodeFoldingState:(id)sender;
{
  IFTreeNode* node = [self cursorNode];
  [node setIsFolded:![node isFolded]];
  [self invalidateLayout];
}

- (BOOL)validateMenuItem:(NSMenuItem*)item;
{
  const SEL action = [item action];
  if (action == @selector(toggleNodeFoldingState:))
    return [[[self cursorNode] parents] count] > 0;
  else if (action == @selector(removeBookmark:) || action == @selector(goToBookmark:))
    return [[[document marks] objectAtIndex:[item tag]] isSet];
  else
    return YES;
}

#pragma mark Bookmarks

- (IBAction)setBookmark:(id)sender;
{
  NSMenuItem* item = sender;
  [[[document marks] objectAtIndex:[item tag]] setLikeMark:[document cursorMark]];
}

- (IBAction)removeBookmark:(id)sender;
{
  NSMenuItem* item = sender;
  IFTreeMark* mark = [[document marks] objectAtIndex:[item tag]];
  if ([mark isSet])
    [mark unset];
  else
    NSBeep();
}

- (IBAction)goToBookmark:(id)sender;
{
  NSMenuItem* item = sender;
  IFTreeMark* mark = [[document marks] objectAtIndex:[item tag]];
  if ([mark isSet])
    [[document cursorMark] setLikeMark:mark];
  else
    NSBeep();
}

#pragma mark Event handling

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context;
{
  if (context == IFCursorMovedContext) {
    [self invalidateLayoutLayer:IFLayoutLayerSelection];
    [self scrollRectToVisible:[[self layoutNodeForTreeNode:[self cursorNode]] frame]];
  } else if (context == IFMarkChangedContext)
    [self invalidateLayoutLayer:IFLayoutLayerMarks];
  else if (context == IFBoundsChangedContext)
    [self invalidateLayout];
  else
    NSAssert(NO,@"unexpected key path");
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
  } else {
    switch ([theEvent clickCount]) {
      case 1:
        if ([clickedElement isKindOfClass:[IFTreeLayoutSingle class]])
          [self moveToNodeRepresentedBy:clickedElement];
        [clickedElement activateWithMouseDown:theEvent];
        break;
      case 2:
        if ([clickedElement isKindOfClass:[IFTreeLayoutSingle class]]) {
          IFTreeNode* clickedNode = [clickedElement node];
          [self selectNodes:[document ancestorsOfNode:clickedNode] puttingCursorOn:clickedNode];
        }
        break;
      case 3:
        if ([clickedElement isKindOfClass:[IFTreeLayoutSingle class]]) {
          IFTreeNode* clickedNode = [clickedElement node];
          [self selectNodes:[document nodesOfTreeContainingNode:clickedNode] puttingCursorOn:clickedNode];
        }
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

  NSPoint localPoint = [self convertPoint:[event locationInWindow] fromView:nil];
  IFTreeLayoutElement* elementUnderMouse = [self layoutElementAtPoint:localPoint];

  if ([elementUnderMouse node] == [self cursorNode]) {
    NSPasteboard* pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    [pasteboard declareTypes:[NSArray arrayWithObject:IFTreeNodesPboardType] owner:self];
    NSArray* nodes = [NSArray arrayWithObject:[IFTreeNodeProxy proxyForNode:[elementUnderMouse node] ofDocument:document]];
    NSData* data = [NSArchiver archivedDataWithRootObject:nodes];
    [pasteboard setData:data forType:IFTreeNodesPboardType];
  
    [self dragImage:[elementUnderMouse dragImage] at:[elementUnderMouse frame].origin offset:NSZeroSize event:event pasteboard:pasteboard source:self slideBack:YES];    
  }
}

- (void)mouseUp:(NSEvent*)event;
{
  if (![grabableViewMixin handlesMouseUp:event])
    [super mouseUp:event];
}

- (void)moveUp:(id)sender;
{
  IFTreeNode* node = [self cursorNode];
  if (![node isFolded] && [[node parents] count] > 0)
    [self moveToNode:[[node parents] objectAtIndex:0]];
  else
    [self moveToClosestNodeInDirection:IFUp];
}

- (void)moveDown:(id)sender;
{
  IFTreeNode* current = [self cursorNode];
  if ([[document roots] indexOfObject:current] == NSNotFound)
    [self moveToNode:[current child]];
  else
    [self moveToClosestNodeInDirection:IFDown];
}

- (void)moveLeft:(id)sender;
{
  IFTreeNode* current = [self cursorNode];
  NSArray* siblings = [[current child] parents];
  int indexInSiblings = [siblings indexOfObject:current];
  if (indexInSiblings != NSNotFound && indexInSiblings > 0)
    [self moveToNode:[siblings objectAtIndex:(indexInSiblings - 1)]];
  else
    [self moveToClosestNodeInDirection:IFLeft];
}

- (void)moveRight:(id)sender;
{
  IFTreeNode* current = [self cursorNode];
  NSArray* siblings = [[current child] parents];
  int indexInSiblings = [siblings indexOfObject:current];
  if (indexInSiblings != NSNotFound && indexInSiblings < [siblings count] - 1)
    [self moveToNode:[siblings objectAtIndex:(indexInSiblings + 1)]];
  else
    [self moveToClosestNodeInDirection:IFRight];
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
  if ([[document cursorMark] isSet])
    [[self layoutNodeForTreeNode:[self cursorNode]] activate];
}

- (void)delete:(id)sender;
{
  NSSet* nodesToDelete = [self selectedNodes];
  IFTreeNode* nodeToDelete;
  if ([nodesToDelete count] > 1) {
    IFTreeNodeMacro* macroNode = [document macroNodeByCopyingNodesOf:nodesToDelete inlineOnInsertion:NO];
    [document replaceNodesIn:nodesToDelete byMacroNode:macroNode];
    nodeToDelete = macroNode;
  } else
    nodeToDelete = [nodesToDelete anyObject];
  [document deleteNode:nodeToDelete];
}

- (void)deleteBackward:(id)sender;
{
  [self delete:sender];
}

- (void)deleteNodeUnderMouse:(id)sender;
{
  NSLog(@"delete sender: %@",sender);
  //[document deleteNode:[sender representedObject]];
}

- (void)insertNewline:(id)sender
{
  [document insertNode:[IFTreeNode nodeWithFilter:[IFConfiguredFilter ghostFilter]] asChildOf:[self cursorNode]];
  [self moveToNode:[self cursorNode]];
}

- (NSMenu*)menuForEvent:(NSEvent*)event;
{
  NSPoint localPoint = [self convertPoint:[event locationInWindow] fromView:nil];
  IFTreeLayoutElement* designatedElement = [self layoutElementAtPoint:localPoint];

  if ([designatedElement isKindOfClass:[IFTreeLayoutMark class]]) {
    IFTreeLayoutMark* markElement = (IFTreeLayoutMark*)designatedElement;
    NSMenu* menu = [[[NSMenu alloc] initWithTitle:@"---"] autorelease];
    NSMenuItem* removeMarkItem = [menu addItemWithTitle:@"Remove Mark" action:@selector(removeBookmark:) keyEquivalent:@""];
    NSMenuItem* openInspectorItem = [menu addItemWithTitle:@"Attach New Inspector" action:nil keyEquivalent:@""];
    
    NSMenu* inspectorSubmenu = [[[NSMenu alloc] initWithTitle:@"---"] autorelease];
    NSMenuItem* item2 = [inspectorSubmenu addItemWithTitle:@"Image" action:@selector(newAttachedImageInspector:) keyEquivalent:@""];
    [item2 setTag:[markElement markIndex]];
    NSMenuItem* item3 = [inspectorSubmenu addItemWithTitle:@"Histogram" action:@selector(newAttachedHistogramInspector:) keyEquivalent:@""];
    [item3 setTag:[markElement markIndex]];

    [menu setSubmenu:inspectorSubmenu forItem:openInspectorItem];
    
    [removeMarkItem setTag:[markElement markIndex]];
    return menu;
  }
  
  return [super menuForEvent:event];
}

// TODO keep this ?
- (void)newAttachedImageInspector:(id)sender;
{
  IFAppController* appController = [[NSApplication sharedApplication] delegate];
  IFProbeWindowController* inspectorController = (IFProbeWindowController*)[appController newInspectorOfClass:[IFImageInspectorWindowController class] sender:sender];
  [inspectorController stickToBookmarkIndex:[(NSMenuItem*)sender tag]];
}

// TODO keep this ?
- (void)newAttachedHistogramInspector:(id)sender;
{
  IFAppController* appController = [[NSApplication sharedApplication] delegate];
  IFProbeWindowController* inspectorController = (IFProbeWindowController*)[appController newInspectorOfClass:[IFHistogramInspectorWindowController class] sender:sender];
  [inspectorController stickToBookmarkIndex:[(NSMenuItem*)sender tag]];
}

#pragma mark Copy and paste

- (void)copy:(id)sender;
{
  NSSet* nodesToCopy = [self selectedNodes];
  IFTreeNode* nodeToCopy = [document macroNodeByCopyingNodesOf:nodesToCopy inlineOnInsertion:YES];
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

  [document replaceNode:[self cursorNode] usingNode:[proxy node]];
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
    [(IFTreeMark*)[[document marks] objectAtIndex:markIndex] unset];
  } else if ([types containsObject:IFTreeNodesPboardType]) {
    NSArray* nodes = [NSUnarchiver unarchiveObjectWithData:[pboard dataForType:IFTreeNodesPboardType]];
    for (int i = 0; i < [nodes count]; ++i)
      [document deleteNode:(id)[(IFTreeNodeProxy*)[nodes objectAtIndex:i] node]];
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
  if ([[document cursorMark] isSet])
    [[self layoutNodeForTreeNode:[self cursorNode]] deactivate];

  NSArray* types = [[sender draggingPasteboard] types];
  if ([types containsObject:IFTreeNodesPboardType])
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
      NSArray* draggedNodesProxy = [NSUnarchiver unarchiveObjectWithData:[pboard dataForType:IFTreeNodesPboardType]];
      IFTreeNode* draggedNode = [[draggedNodesProxy objectAtIndex:0] node];
      NSDragOperation operation = [sender draggingSourceOperationMask];

      if (targetNode == nil)
        return NO;
      
      if ((operation & (NSDragOperationCopy|NSDragOperationMove)) != 0) {
        // Copy or move node
        IFTreeNode* draggedClone = [draggedNode cloneNode];
        if ([targetElement isKindOfClass:[IFTreeLayoutInputConnector class]]) {
          if ([document canInsertNode:draggedClone asParentOf:targetNode])
            [document insertNode:draggedClone asParentOf:targetNode];
          else
            return NO;
        } else if ([targetElement isKindOfClass:[IFTreeLayoutOutputConnector class]]) {
          if ([document canInsertNode:draggedClone asChildOf:targetNode])
            [document insertNode:draggedClone asChildOf:targetNode];
          else
            return NO;
        } else {
          NSAssert1([targetElement isKindOfClass:[IFTreeLayoutSingle class]], @"unexpected target element %@",targetElement);
          if ([document canReplaceNode:targetNode usingNode:draggedClone])
            [document replaceNode:targetNode usingNode:draggedClone];
          else
            return NO;
        }
        if (([sender draggingSourceOperationMask] & NSDragOperationMove) != 0)
          [document deleteNode:draggedNode];        
        return YES;        
      } else if ((operation & NSDragOperationLink) != 0) {
        // Link: create node alias
        if ([[targetNode parents] count] == 0) {
          [document replaceNode:targetNode usingNode:[IFTreeNodeAlias nodeAliasWithOriginal:draggedNode]];
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
        IFDocumentTemplate* loadTemplate = [[IFDocument documentTemplateManager] loadFileTemplate];
        IFTreeNode* loadNode = [loadTemplate node];
        for (int i = 0; i < [fileNames count]; ++i) {
          IFTreeNode* newNode = [loadNode cloneNode];
          [[[newNode filter] environment] setValue:[fileNames objectAtIndex:i] forKey:@"fileName"];
          [document addTree:newNode];
        }
        return YES;
      } else if ([targetNode isGhost]) {
        // Replace ghost node by "load" node
        IFDocumentTemplate* loadTemplate = [[IFDocument documentTemplateManager] loadFileTemplate];
        IFTreeNode* loadNode = [loadTemplate node];
        [[[loadNode filter] environment] setValue:[fileNames objectAtIndex:0] forKey:@"fileName"];
        [document replaceNode:targetNode usingNode:[loadNode cloneNode]];
        return YES;
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
      [(IFTreeMark*)[[document marks] objectAtIndex:markIndex] setNode:[targetElement node]];
      return YES;
    }

    default:
      NSAssert(NO,@"unexpected drag kind");
      return NO;
  }
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect;
{
  [[self backgroundColor] set];
  [[NSBezierPath bezierPathWithRect:[self bounds]] fill];
  
  for (int i = 0; i < [layoutLayers count]; ++i) {
    if (upToDateLayers & (1 << i))
      [[layoutLayers objectAtIndex:i] drawForRect:rect];
    else
      [self enqueueLayoutNotification];
  }
  
  if (highlightingPath != nil) {
    [[self highlightingColor] set];
    [highlightingPath fill];
    [highlightingPath stroke];
  }
}

@end

@implementation IFTreeView (Private)

- (void)documentTreeChanged:(NSNotification*)aNotification;
{
  [self invalidateLayout];
}

- (NSRect)paddedBounds;
{
  IFTreeLayoutElement* nodeLayer = [layoutLayers objectAtIndex:IFLayoutLayerTree];
  NSRect unpaddedBounds = (nodeLayer == (IFTreeLayoutElement*)[NSNull null]) ? NSZeroRect : [nodeLayer frame];
  return NSInsetRect(unpaddedBounds,-GUTTER_WIDTH,-3.0);
}  

- (void)recomputeFrameSize;
{
  NSRect newBounds = [self paddedBounds];
  
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
    [highlightingPath release];
    highlightingPath = nil;
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

#pragma mark Selection

- (void)clearSelectedNodes;
{
  [self setSelectedNodes:[NSSet set]];
}

- (void)setSelectedNodes:(NSSet*)newSelectedNodes;
{
  if (newSelectedNodes == selectedNodes)
    return;
  [selectedNodes release];
  selectedNodes = [newSelectedNodes copy];
  
  [self invalidateLayoutLayer:IFLayoutLayerSelection];
}

- (NSSet*)selectedNodes;
{
  if ([self cursorNode] == nil)
    return [NSSet set];
  else if ([selectedNodes count] == 0)
    return [NSSet setWithObject:[self cursorNode]];
  else
    return selectedNodes;
}

- (void)setCursorNode:(IFTreeNode*)newCursorNode;
{
  if (newCursorNode == [self cursorNode])
    return;

  [self clearSelectedNodes];
  [[document cursorMark] setNode:newCursorNode];  
}

- (IFTreeNode*)cursorNode;
{
  return [[document cursorMark] node];
}

- (void)selectNodes:(NSSet*)nodes puttingCursorOn:(IFTreeNode*)node;
{
  NSAssert([nodes containsObject:node], @"invalid selection");
  [self setCursorNode:node];
  [self setSelectedNodes:nodes];
}

#pragma mark Layout

- (void)enqueueLayoutNotification;
{
  [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:IFTreeViewNeedsLayout object:self]
                                             postingStyle:NSPostASAP
                                             coalesceMask:NSNotificationCoalescingOnName
                                                 forModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode,NSEventTrackingRunLoopMode,nil]];
}

- (IFTreeLayoutElement*)layoutForLayer:(IFLayoutLayer)layer;
{
  switch (layer) {
    case IFLayoutLayerTree: {
      [self removeAllTrackingRects];
      [self removeAllToolTips];
      
      NSArray* roots = (NSArray*)[[self collect] layoutTree:[[document roots] each]];
      for (int i = 1; i < [roots count]; ++i)
        [[roots objectAtIndex:i] translateBy:NSMakePoint(NSMaxX([[roots objectAtIndex:i-1] frame]) + GUTTER_WIDTH,0)];
      IFTreeLayoutElement* layer = [IFTreeLayoutComposite layoutCompositeWithElements:[NSSet setWithArray:roots] containingView:self];
      
      // Now that all elements are at their final position, establish tool tips and tracking rects
      NSSet* leaves = [layer leavesOfKind:IFTreeLayoutElementKindNode];
      [self addToolTipsForLayoutNodes:leaves];
      [self addTrackingRectsForLayoutNodes:leaves];
      return layer;
    }
    case IFLayoutLayerSidePane:
      return [self layoutSidePaneForElement:(IFTreeLayoutSingle*)pointedElement];
    case IFLayoutLayerSelection:
      return [self layoutSelectedNodes:[self selectedNodes] cursor:[self cursorNode] forTreeLayout:[layoutLayers objectAtIndex:IFLayoutLayerTree]];
    case IFLayoutLayerMarks:
      return [self layoutMarks:[document marks] forTreeLayout:[layoutLayers objectAtIndex:IFLayoutLayerTree]];
    default:
      NSAssert(NO, @"unexpected layer");
      return nil;
  }
}

- (void)updateLayout:(NSNotification*)notification;
{
  for (int layer = IFLayoutLayerTree; layer <= IFLayoutLayerMarks; ++layer) {
    if (upToDateLayers & (1 << layer))
      continue;
    IFTreeLayoutElement* old = [layoutLayers objectAtIndex:layer];
    if (old != (IFTreeLayoutElement*)[NSNull null])
      [self setNeedsDisplayInRect:[old frame]];
    IFTreeLayoutElement* new = [self layoutForLayer:layer];
    [layoutLayers replaceObjectAtIndex:layer withObject:new];
    upToDateLayers |= (1 << layer);
    [self setNeedsDisplayInRect:[[layoutLayers objectAtIndex:layer] frame]];
  }
  [self recomputeFrameSize];
}

- (void)invalidateLayoutLayer:(int)layoutLayer;
{
  upToDateLayers &= ~(1 << layoutLayer);
  [self enqueueLayoutNotification];
}

- (void)invalidateLayout;
{
  upToDateLayers = 0;
  [self enqueueLayoutNotification];  
}

- (IFTreeLayoutElement*)layoutTree:(IFTreeNode*)root;
{
  NSMutableSet* layoutElems = [NSMutableSet set];
  
  // Layout all parents
  NSArray* parents = [root isFolded] ? [NSArray array] : [root parents];
  const int parentsCount = [parents count];
  NSMutableArray* directParentsLayout = [NSMutableArray arrayWithCapacity:parentsCount];
  float x = 0.0;
  for (int i = 0; i < parentsCount; i++) {
    if (i > 0) x += GUTTER_WIDTH;
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
    ? [IFTreeLayoutComposite layoutCompositeWithElements:layoutElems containingView:self]
    : [layoutElems anyObject];
}

- (IFTreeLayoutNode*)layoutNodeForTreeNode:(IFTreeNode*)theNode;
{
  IFTreeLayoutNode* layoutNode = [layoutNodes objectForKey:theNode];
  if (layoutNode == nil) {
    layoutNode = [IFTreeLayoutSingle layoutSingleWithNode:theNode containingView:self];
    CFDictionarySetValue((CFMutableDictionaryRef)layoutNodes, theNode, layoutNode);
    [layoutNode addObserver:self forKeyPath:@"bounds" options:0 context:IFBoundsChangedContext];
  }
  return layoutNode;
}

- (IFTreeLayoutElement*)layoutInputConnectorForTreeNode:(IFTreeNode*)node;
{
  return [IFTreeLayoutInputConnector layoutConnectorWithNode:node containingView:self];
}

- (IFTreeLayoutElement*)layoutOutputConnectorForTreeNode:(IFTreeNode*)node tag:(NSString*)tag leftReach:(float)lReach rightReach:(float)rReach;
{
  return [IFTreeLayoutOutputConnector layoutConnectorWithNode:node
                                               containingView:self
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
  while (element = [elemsEnumerator nextObject]) {
    BOOL isCursor = [element node] == cursorNode;
    [result addObject:[IFTreeLayoutCursor layoutCursorWithBase:element pathWidth:(isCursor ? CURSOR_PATH_WIDTH : SELECTION_PATH_WIDTH)]];
  }
  return [result count] == 1
    ? [result anyObject]
    : [IFTreeLayoutComposite layoutCompositeWithElements:result containingView:self];
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
    : [IFTreeLayoutComposite layoutCompositeWithElements:elems containingView:self];
}

- (IFTreeLayoutElement*)layoutElementAtPoint:(NSPoint)point inLayerAtIndex:(int)layerIndex;
{
  return [[layoutLayers objectAtIndex:layerIndex] layoutElementAtPoint:point];
}

- (IFTreeLayoutElement*)layoutElementAtPoint:(NSPoint)point;
{
  NSEnumerator* layerEnum = [layoutLayers reverseObjectEnumerator];
  IFTreeLayoutElement* layer;
  while (layer = [layerEnum nextObject]) {
    IFTreeLayoutElement* maybeElement = [layer layoutElementAtPoint:point];
    if (maybeElement != nil)
      return maybeElement;
  }
  return nil;
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
  return [[[layoutNode node] filter] toolTip];
}

#pragma mark Tracking rectangles

- (void)resetCursorRects;
{
  [super resetCursorRects];
  [self removeAllTrackingRects];
  [self addTrackingRectsForLayoutNodes:[[layoutLayers objectAtIndex:IFLayoutLayerTree] leavesOfKind:IFTreeLayoutElementKindNode]];
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

- (void)moveToNode:(IFTreeNode*)node;
{
  [self moveToNodeRepresentedBy:[self layoutNodeForTreeNode:node]];
}

- (void)moveToNodeRepresentedBy:(IFTreeLayoutElement*)layoutElem;
{
  if (layoutElem != nil)
    [self setCursorNode:[layoutElem node]];
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

- (void)moveToClosestNodeInDirection:(IFDirection)direction;
{
  const float searchDistance = 1000;

  IFTreeLayoutElement* treeLayout = [layoutLayers objectAtIndex:IFLayoutLayerTree];
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
    [self moveToNodeRepresentedBy:bestCandidate];
  } else
    NSBeep();
}

@end
