//
//  IFImageInspectorWindowController.m
//  ImageFlow
//
//  Created by Michel Schinz on 08.08.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFImageInspectorWindowController.h"
#import "IFDocument.h"
#import "IFFilterController.h"
#import "IFAnnotation.h"
#import "IFErrorConstantExpression.h"

typedef enum {
  IFFilterDelegateHasMouseDown = 1<<0,
  IFFilterDelegateHasMouseDragged = 1<<1,
  IFFilterDelegateHasMouseUp = 1<<2
} IFFilterDelegateCapabilities;

@interface IFImageInspectorWindowController (Private)
- (void)setEvaluator:(IFExpressionEvaluator*)newEvaluator;
- (void)setMainExpression:(IFExpression*)newExpression;
- (void)setThumbnailExpression:(IFExpression*)newExpression;
- (void)setErrorMessage:(NSString*)newErrorMessage;
- (NSString*)errorMessage;
- (void)installSecondaryProbe;
- (void)removeSecondaryProbe;
- (void)setCurrentSecondaryNode:(IFTreeNode*)newNode;
- (void)setCurrentNode:(IFTreeNode*)newNode;
- (void)updateMainImageViewExpression;
- (void)updateAuxiliaryImageViewExpression;
- (void)updateVariantsAndAnnotations;
- (void)updateFloatingWindows;
- (void)updateEditViewTransform;
- (void)updateSettingsView;
- (IFFilterController*)filterControllerForName:(NSString*)filterName;
@end

@implementation IFImageInspectorWindowController

static const float thumbnailFactor = 4;

static NSString* IFExpressionChangedContext = @"IFExpressionChangedContext";
static NSString* IFSecondaryExpressionChangedContext = @"IFSecondaryExpressionChangedContext";

static NSString* IFToolbarModeItemIdentifier = @"IFToolbarModeItemIdentifier";
static NSString* IFToolbarZoomItemIdentifier = @"IFToolbarZoomItemIdentifier";
static NSString* IFToolbarLayoutItemIdentifier = @"IFToolbarLayoutItemIdentifier";

- (id)init;
{
  if (![super initWithWindowNibName:@"IFImageView"])
    return nil;
  filterControllers = [NSMutableDictionary new];
  tabIndices = [NSMutableDictionary new];
  panelSizes = [NSMutableDictionary new];
  mode = IFImageInspectorModeView;
  layout = IFImageInspectorLayoutSingle;
  evaluator = nil;
  mainExpression = nil;
  thumbnailExpression = nil;
  variants = [[NSArray array] retain];
  activeVariant = nil;
  editViewTransform = [[NSAffineTransform transform] retain];
  viewEditTransform = [[NSAffineTransform transform] retain];
  proxy = [NSValue valueWithNonretainedObject:self];
  return self;
}

- (void)awakeFromNib;
{
  // NOTE Rigorously, we should ask for frame modifications of all ancestors of imageView.
  [[imageView superview] setPostsFrameChangedNotifications:YES];

  // Configure thumbnail window
  [thumbnailWindow setBackgroundColor:[NSColor whiteColor]];
  [thumbnailWindow setDisplaysWhenScreenProfileChanges:YES];

  // Configure main variant window
  [mainVariantWindow setOpaque:NO];
  [mainVariantWindow setBackgroundColor:[NSColor colorWithDeviceWhite:1.0 alpha:0.7]];
  NSSize mainVariantButtonSize = [mainVariantButton frame].size;
  [mainVariantWindow setContentSize:NSMakeSize(mainVariantButtonSize.width+4,mainVariantButtonSize.height)];
  [mainVariantButton setFrameOrigin:NSZeroPoint];
  [mainVariantButton setFrameSize:mainVariantButtonSize];

  // Configure main window
  [[self window] setFrameAutosaveName:@"IFImageInspector"];
  [[self window] setDisplaysWhenScreenProfileChanges:YES];
}

- (void)windowDidLoad;
{
  [super windowDidLoad];

  NSScrollView* scrollView = [imageView enclosingScrollView];
  [scrollView setHasHorizontalRuler:YES];
  [scrollView setHasVerticalRuler:YES];
  [scrollView setRulersVisible:YES];

  // Configure toolbar
  NSNib* toolbarItemsNib = [[NSNib alloc] initWithNibNamed:@"IFImageViewToolbarItems" bundle:nil];
  NSArray* nibObjects = nil;
  BOOL nibOk = [toolbarItemsNib instantiateNibWithOwner:proxy topLevelObjects:&nibObjects];
  NSAssert1(nibOk, @"error during nib instantiation %@", toolbarItemsNib);

  NSArray* topLevelViews = (NSArray*)[[nibObjects select] __isKindOfClass:[NSView class]];
  NSAssert([topLevelViews count] == 1, @"incorrect number of views in Nib");
  toolbarItems = [[topLevelViews objectAtIndex:0] retain];
  //[nibObjects release];

  NSToolbar* toolbar = [[[NSToolbar alloc] initWithIdentifier:@"IFImageView"] autorelease];
  [toolbar setAllowsUserCustomization:YES];
  [toolbar setDelegate:self];
  [[self window] setToolbar:toolbar];

  // Watch expression
  [probe addObserver:self forKeyPath:@"mark.node.expression" options:0 context:IFExpressionChangedContext];

  [self updateFloatingWindows];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(viewFrameDidChange:)
                                               name:NSViewFrameDidChangeNotification
                                             object:[imageView superview]];
  [self updateMainImageViewExpression];
  [self updateSettingsView];
  [self updateVariantsAndAnnotations];

  [imageView setDelegate:self];
}

- (void)windowWillClose:(NSNotification*)notification;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [probe removeObserver:self forKeyPath:@"mark.node.expression"];
}

- (void)dealloc;
{
  [self setEvaluator:nil];
  [self setMainExpression:nil];
  [self setThumbnailExpression:nil];
  [self setErrorMessage:nil];

  [self setCurrentNode:nil];
  [self removeSecondaryProbe];

  OBJC_RELEASE(zoomToolbarItem);
  OBJC_RELEASE(modeToolbarItem);

  OBJC_RELEASE(proxy);
  OBJC_RELEASE(viewEditTransform);
  OBJC_RELEASE(editViewTransform);
  OBJC_RELEASE(activeVariant);
  OBJC_RELEASE(variants);
  OBJC_RELEASE(panelSizes);
  OBJC_RELEASE(tabIndices);
  OBJC_RELEASE(filterControllers);
  [super dealloc];
}

- (void)documentDidChange:(IFDocument*)newDocument;
{
  [self setEvaluator:[newDocument evaluator]];
  [imageView setCanvasBounds:[newDocument canvasBounds]];
  [super documentDidChange:newDocument];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  if (context == IFExpressionChangedContext) {
    if (currentNode != [[probe mark] node]) {
      [self setCurrentNode:[[probe mark] node]];
      [self updateSettingsView];
      [self updateVariantsAndAnnotations];
      [self updateEditViewTransform];
    }

    if (layout != IFImageInspectorLayoutDual)
      [self updateMainImageViewExpression];
    else
      [self updateAuxiliaryImageViewExpression];
  } else if (context == IFSecondaryExpressionChangedContext) {
    if (currentSecondaryNode != [[secondaryProbe mark] node]) {
      [self setCurrentSecondaryNode:[[secondaryProbe mark] node]];
      [self updateEditViewTransform];
    }
    [self updateMainImageViewExpression];
  } else
    NSAssert1(NO, @"unexpected context: %@",context);
}

- (NSRect)windowWillUseStandardFrame:(NSWindow*)window defaultFrame:(NSRect)defaultFrame;
{
  // TODO take settings sub-view into account, as well as sliders (if possible)
  NSRect windowFrame = [window frame];
  NSSize visibleViewSize = [imageView visibleRect].size;
  NSSize idealViewSize = [imageView bounds].size;
  NSSize minSize = [window minSize];

  float deltaW = fmax(idealViewSize.width - visibleViewSize.width,  minSize.width - NSWidth(windowFrame));
  float deltaH = fmax(idealViewSize.height - visibleViewSize.height, minSize.height - NSHeight(windowFrame));

  windowFrame.size.width += deltaW;
  windowFrame.size.height += deltaH;
  windowFrame.origin.y -= deltaH;
  return windowFrame;
}

- (NSArray*)variants;
{
  return variants;
}

- (void)setVariants:(NSArray*)newVariants;
{
  if (newVariants == variants)
    return;

  if (![newVariants containsObject:[self activeVariant]])
    [self setActiveVariant:[newVariants objectAtIndex:0]];

  [variants release];
  variants = [newVariants copy];
}

- (IFImageVariant*)activeVariant;
{
  return activeVariant;
}

- (void)setActiveVariant:(IFImageVariant*)newActiveVariant;
{
  if (newActiveVariant == activeVariant)
    return;

  [activeVariant release];
  activeVariant = [newActiveVariant retain];

  if ([activeVariant mark] != [secondaryProbe mark])
    [secondaryProbe setMark:[activeVariant mark]];
  [self updateMainImageViewExpression];
}

#pragma mark Toolbar

- (NSArray*)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar;
{
  return [NSArray arrayWithObjects:
    IFToolbarModeItemIdentifier,
    IFToolbarLayoutItemIdentifier,
    IFToolbarZoomItemIdentifier,
    NSToolbarCustomizeToolbarItemIdentifier,
    NSToolbarFlexibleSpaceItemIdentifier,
    NSToolbarSpaceItemIdentifier,
    NSToolbarSeparatorItemIdentifier,
    nil];
}

- (NSArray*)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar;
{
  return [NSArray arrayWithObjects:
    IFToolbarModeItemIdentifier,
    IFToolbarLayoutItemIdentifier,
    IFToolbarZoomItemIdentifier,
    NSToolbarFlexibleSpaceItemIdentifier,
    NSToolbarCustomizeToolbarItemIdentifier,
    nil];
}

- (NSToolbarItem*)toolbar:(NSToolbar*)toolbar itemForItemIdentifier:(NSString*)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;
{
  if ([itemIdentifier isEqualToString:IFToolbarModeItemIdentifier]) {
    if (modeToolbarItem == nil) {
      modeToolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:IFToolbarModeItemIdentifier];
      [modeToolbarItem setLabel:@"Mode"];
      [modeToolbarItem setPaletteLabel:@"Mode"];
      NSView* modeItemView = [[toolbarItems viewWithTag:0] retain];
      [modeItemView removeFromSuperview];
      [modeToolbarItem setView:modeItemView];
      [modeToolbarItem setMinSize:[modeItemView bounds].size];
      [modeItemView release];
    }
    return modeToolbarItem;
  } else if ([itemIdentifier isEqualToString:IFToolbarLayoutItemIdentifier]) {
    if (layoutToolbarItem == nil) {
      layoutToolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:IFToolbarLayoutItemIdentifier];
      [layoutToolbarItem setLabel:@"Layout"];
      [layoutToolbarItem setPaletteLabel:@"Layout"];
      NSSegmentedControl* layoutItemView = [[toolbarItems viewWithTag:1] retain];
      for (int i = 0; i < [layoutItemView segmentCount]; ++i)
        [layoutItemView setLabel:nil forSegment:i];
      [layoutItemView removeFromSuperview];
      [layoutToolbarItem setView:layoutItemView];
      [layoutToolbarItem setMinSize:[layoutItemView bounds].size];
      [layoutItemView release];
    }
    return layoutToolbarItem;
  } else if ([itemIdentifier isEqualToString:IFToolbarZoomItemIdentifier]) {
    if (zoomToolbarItem == nil) {
      zoomToolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:IFToolbarZoomItemIdentifier];
      [zoomToolbarItem setLabel:@"Zoom"];
      [zoomToolbarItem setPaletteLabel:@"Zoom"];
      NSView* zoomItemView = [[toolbarItems viewWithTag:2] retain];
      [zoomItemView removeFromSuperview];
      [zoomToolbarItem setView:zoomItemView];
      [zoomToolbarItem setMinSize:[zoomItemView bounds].size];
      [zoomItemView release];
    }
    return zoomToolbarItem;
  } else
    return nil;
}

- (void)setMode:(IFImageInspectorMode)newMode;
{
  if (newMode == mode)
    return;

  mode = newMode;

  NSSegmentedControl* layoutControl = (NSSegmentedControl*)[layoutToolbarItem view];
  [layoutControl setEnabled:(mode == IFImageInspectorModeEdit) forSegment:IFImageInspectorLayoutDual];
  if (mode == IFImageInspectorModeView && layout == IFImageInspectorLayoutDual)
    [self setLayout:IFImageInspectorLayoutSingle];
  
  [self updateVariantsAndAnnotations];
  [self updateSettingsView];
}

- (IFImageInspectorMode)mode;
{
  return mode;
}

- (void)setLayout:(IFImageInspectorLayout)newLayout;
{
  if (newLayout == layout)
    return;

  layout = newLayout;

  [self updateVariantsAndAnnotations];
  if (layout == IFImageInspectorLayoutDual) {
    NSAssert(![thumbnailWindow isVisible], @"thumbnail window already visible");
    [self updateFloatingWindows];
    [[self window] addChildWindow:thumbnailWindow ordered:NSWindowAbove];
    [self updateAuxiliaryImageViewExpression];
    [thumbnailWindow orderFront:self];
    
    NSView* v = [[imageView enclosingScrollView] contentView];
    [v setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainImageViewDidScroll:) name:NSViewBoundsDidChangeNotification object:v];
    
    [self installSecondaryProbe];
  } else {
    NSAssert([thumbnailWindow isVisible], @"thumbnail window not visible");
    [[self window] removeChildWindow:thumbnailWindow];
    [thumbnailWindow orderOut:self];

    NSView* v = [[imageView enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:v];
    
    [self removeSecondaryProbe];
  }
}

- (IFImageInspectorLayout)layout;
{
  return layout;
}

#pragma mark Event handling

- (void)handleMouseDown:(NSEvent*)event;
{
  if (filterDelegateCapabilities & IFFilterDelegateHasMouseDown) {
    NSPoint point = [viewEditTransform transformPoint:[imageView convertPoint:[event locationInWindow] fromView:nil]];
    [filterDelegate mouseDown:event atPoint:point withEnvironment:[[currentNode filter] environment]];
  }
}

- (void)handleMouseDragged:(NSEvent*)event;
{
  if (filterDelegateCapabilities & IFFilterDelegateHasMouseDragged) {
    NSPoint point = [viewEditTransform transformPoint:[imageView convertPoint:[event locationInWindow] fromView:nil]];
    [filterDelegate mouseDragged:event atPoint:point withEnvironment:[[currentNode filter] environment]];
  }
}

- (void)handleMouseUp:(NSEvent*)event;
{
  if (filterDelegateCapabilities & IFFilterDelegateHasMouseUp) {
    NSPoint point = [viewEditTransform transformPoint:[imageView convertPoint:[event locationInWindow] fromView:nil]];
    [filterDelegate mouseUp:event atPoint:point withEnvironment:[[currentNode filter] environment]];
  }
}

@end

@implementation IFImageInspectorWindowController (Private)

- (void)setEvaluator:(IFExpressionEvaluator*)newEvaluator;
{
  if (newEvaluator == evaluator)
    return;
  [evaluator release];
  evaluator = [newEvaluator retain];
}

- (void)setMainExpression:(IFExpression*)newExpression;
{
  if (newExpression == mainExpression)
    return;
  
  NSRect dirtyRect = (mainExpression == nil || newExpression == nil)
    ? NSRectInfinite()
    : [evaluator deltaFromOld:mainExpression toNew:newExpression];

  [mainExpression release];
  mainExpression = [newExpression retain];
  
  IFConstantExpression* evaluatedExpr = [evaluator evaluateExpressionAsImage:mainExpression];
  
  if ([evaluatedExpr isError]) {
    [imageView setImage:nil dirtyRect:NSRectInfinite()];
    [self setErrorMessage:[(IFErrorConstantExpression*)evaluatedExpr message]];
    [imageOrErrorTabView selectTabViewItemAtIndex:1];
    [self setMode:IFImageInspectorModeEdit];
  } else {
    [imageView setImage:[(IFImageConstantExpression*)evaluatedExpr image] dirtyRect:dirtyRect];
    [self setErrorMessage:nil];
    [imageOrErrorTabView selectTabViewItemAtIndex:0];
  }
}

- (void)setThumbnailExpression:(IFExpression*)newExpression;
{
  if (newExpression == thumbnailExpression)
    return;
  
  NSRect dirtyRect = (thumbnailExpression == nil || newExpression == nil)
    ? NSRectInfinite()
    : [evaluator deltaFromOld:thumbnailExpression toNew:newExpression];
  
  [thumbnailExpression release];
  thumbnailExpression = [newExpression retain];
  
  IFConstantExpression* evaluatedExpr = [evaluator evaluateExpressionAsImage:thumbnailExpression];
  
  if ([evaluatedExpr isError])
    [thumbnailView setImage:nil dirtyRect:NSRectInfinite()];
  else
    [thumbnailView setImage:[(IFImageConstantExpression*)evaluatedExpr image] dirtyRect:dirtyRect];
}

- (void)setErrorMessage:(NSString*)newErrorMessage;
{
  if (newErrorMessage == errorMessage)
    return;
  [errorMessage release];
  errorMessage = [newErrorMessage copy];
}

- (NSString*)errorMessage;
{
  return errorMessage;
}

- (void)installSecondaryProbe;
{
  secondaryProbe = [[IFProbe probeWithMark:[activeVariant mark]] retain];
  [secondaryProbe addObserver:self forKeyPath:@"mark.node.expression" options:0 context:IFSecondaryExpressionChangedContext];
  [self setCurrentSecondaryNode:[[secondaryProbe mark] node]];
}

- (void)removeSecondaryProbe;
{
  [secondaryProbe removeObserver:self forKeyPath:@"mark.node.expression"];
  OBJC_RELEASE(secondaryProbe);
  [self setCurrentSecondaryNode:nil];
}

- (void)setCurrentSecondaryNode:(IFTreeNode*)newNode;
{
  if (newNode == currentSecondaryNode)
    return;
  [currentSecondaryNode release];
  currentSecondaryNode = [newNode retain];  
}

- (void)setCurrentNode:(IFTreeNode*)newNode;
{
  if (newNode == currentNode)
    return;
  [currentNode release];
  currentNode = [newNode retain];

  filterDelegate = [[[currentNode filter] filter] delegate];
  filterDelegateCapabilities = 0
    | ([filterDelegate respondsToSelector:@selector(mouseDown:atPoint:withEnvironment:)] ? IFFilterDelegateHasMouseDown : 0)
    | ([filterDelegate respondsToSelector:@selector(mouseDragged:atPoint:withEnvironment:)] ? IFFilterDelegateHasMouseDragged : 0)
    | ([filterDelegate respondsToSelector:@selector(mouseUp:atPoint:withEnvironment:)] ? IFFilterDelegateHasMouseUp : 0);
}

- (void)updateMainImageViewExpression;
{
  IFTreeMark* mark = [self activeVariant] != nil ? [[self activeVariant] mark] : [probe mark];
  IFTreeNode* node = [mark node];
  IFFilter* filter = [[node filter] filter];
  IFExpression* expression = (node != nil ? [node expression] : [IFOperatorExpression nop]);
  if ([self activeVariant] != nil && ![[[self activeVariant] name] isEqualToString:@""])
    expression = [filter variantNamed:[[self activeVariant] name] ofExpression:expression];
  [self setMainExpression:expression];
}

- (void)updateAuxiliaryImageViewExpression;
{
  IFExpression* expr = [[[probe mark] node] expression];
  [self setThumbnailExpression:(expr == nil
                                ? nil
                                : [IFOperatorExpression resample:expr by:(1.0/thumbnailFactor)])];
}

- (NSArray*)variantsForMark:(IFTreeMark*)mark;
{
  IFFilter* filter = [[[mark node] filter] filter];
  NSArray* names = (mode == IFImageInspectorModeView) ? [filter variantNamesForViewing] : [filter variantNamesForEditing];
  return [[IFImageVariant collect] variantWithMark:mark name:[names each]];
}

- (void)updateVariantsAndAnnotations;
{
  IFTreeNode* node = [[probe mark] node];
  IFFilter* filter = [[node filter] filter];

  if (mode == IFImageInspectorModeView) {
    [self setVariants:[self variantsForMark:[probe mark]]];
    [imageView setAnnotations:nil];
  } else if (layout == IFImageInspectorLayoutDual) {
    NSMutableArray* allVariants = [NSMutableArray arrayWithArray:[self variantsForMark:[probe mark]]];

    for (int i = 1; i < [marks count]; ++i) {
      IFTreeNode* markedNode = [[marks objectAtIndex:i] node];
      if ([node isParentOf:markedNode])
        [allVariants addObjectsFromArray:[self variantsForMark:[marks objectAtIndex:i]]];
    }
    [self setVariants:allVariants];

    NSArray* annotations = [filter editingAnnotationsForNode:node view:imageView];
    [[annotations do] setTransform:editViewTransform];
    [imageView setAnnotations:annotations];
  } else {
    // edit mode, single layout
    [self setVariants:[self variantsForMark:[probe mark]]];
    [imageView setAnnotations:[filter editingAnnotationsForNode:node view:imageView]];
  }

  if ([[self variants] count] > 1) {
    if (![mainVariantWindow isVisible]) {
      [[self window] addChildWindow:mainVariantWindow ordered:NSWindowAbove];
      [mainVariantWindow orderFront:self];
    }
  } else {
    if ([mainVariantWindow isVisible]) {
      [[self window] removeChildWindow:mainVariantWindow];
      [mainVariantWindow orderOut:self];
    }
  }
}

- (void)mainImageViewDidScroll:(NSNotification*)notification;
{
  NSPoint o = [imageView visibleRect].origin;
  [(NSClipView*)[thumbnailView superview] scrollToPoint:NSMakePoint(o.x / thumbnailFactor,o.y / thumbnailFactor)];
}

- (void)updateFloatingWindows;
{
  NSRect visibleImageView = [imageView visibleRect];
  NSPoint visibleOrigin = visibleImageView.origin;
  NSPoint screenVisibleOrigin = [[self window] convertBaseToScreen:[imageView convertPoint:visibleOrigin toView:nil]];

  [mainVariantWindow setFrameOrigin:NSMakePoint(screenVisibleOrigin.x + 1,screenVisibleOrigin.y + 1)];

  NSSize visibleSize = visibleImageView.size;
  NSSize thumbnailSize = NSMakeSize(floor(visibleSize.width / thumbnailFactor), floor(visibleSize.height / thumbnailFactor));
  NSPoint thumbnailOrigin = NSMakePoint(screenVisibleOrigin.x,
                                        screenVisibleOrigin.y + visibleSize.height - thumbnailSize.height);
  NSRect thumbnailFrame = { thumbnailOrigin, thumbnailSize };
  
  float margin = 2;
  [[thumbnailView enclosingScrollView] setFrame:NSMakeRect(0,margin,thumbnailSize.width - margin,thumbnailSize.height - margin)];
  
  [thumbnailWindow setFrame:thumbnailFrame display:YES];
}

- (void)viewFrameDidChange:(NSNotification*)notification;
{
  NSView* changedView = [notification object];
  if ([imageView isDescendantOf:changedView])
    [self updateFloatingWindows];
}

- (void)windowDidResize:(NSNotification*)notification;
{
  [self updateFloatingWindows];
}

- (void)updateEditViewTransform;
{
  [editViewTransform release];
  editViewTransform = [[NSAffineTransform transform] retain];
  [viewEditTransform release];
  viewEditTransform = [editViewTransform copy];

  if ([[probe mark] isSet] && [[secondaryProbe mark] isSet]) {
    IFTreeNode* editedNode = [[probe mark] node];
    IFTreeNode* viewedNode = [[secondaryProbe mark] node];

    for (IFTreeNode* node = editedNode; node != viewedNode; node = [node child]) {
      IFConfiguredFilter* cFilter = [[node child] filter];
      int parentIndex = [[[node child] parents] indexOfObject:node];
      [editViewTransform appendTransform:[[cFilter filter] transformForParentAtIndex:parentIndex withEnvironment:[cFilter environment]]];
    }
    [viewEditTransform setTransformStruct:[editViewTransform transformStruct]];
    [viewEditTransform invert];
  }
  [self updateVariantsAndAnnotations];
}

- (void)updateSettingsView;
{
  [filterSettingsSubView setHidden:(mode == IFImageInspectorModeView)];

  if ((mode != IFImageInspectorModeEdit) || ([[probe mark] node] == nil))
    return;

  IFConfiguredFilter* confFilter = [[[probe mark] node] filter];
  IFFilter* filter = [confFilter filter];

  IFFilterController* filterController = [self filterControllerForName:[filter name]];
  [filterController setConfiguredFilter:confFilter];

  // Select appropriate tab
  NSNumber* tabIndex = [tabIndices objectForKey:[filter name]];
  if (tabIndex == nil) {
    // TODO when should the nib objects be deallocated? before the filterControllers are deleted (in dealloc), otherwise they still observe the deallocated filter controllers (see error message in log).
    NSArray* nibObjects = [filter instantiateSettingsNibWithOwner:filterController];
    if (nibObjects == nil)
      tabIndex = [NSNumber numberWithInt:0];
    else {
      NSArray* nibViews = (NSArray*)[[nibObjects select] __isKindOfClass:[NSView class]];
      NSAssert1([nibViews count] == 1, @"incorrect number of views in NIB file for filter %@", [filter name]);

      NSView* nibView = [nibViews objectAtIndex:0];
      [panelSizes setObject:[NSValue valueWithSize:[nibView bounds].size] forKey:[filter name]];
      NSTabViewItem* filterSettingsTabViewItem = [[[NSTabViewItem alloc] initWithIdentifier:nil] autorelease];
      [filterSettingsTabViewItem setView:nibView];
      tabIndex = [NSNumber numberWithInt:[filterSettingsTabView numberOfTabViewItems]];
      [filterSettingsTabView insertTabViewItem:filterSettingsTabViewItem atIndex:[tabIndex intValue]];
    }
    [tabIndices setObject:tabIndex forKey:[filter name]];
  }

  NSTabViewItem* item = [filterSettingsTabView tabViewItemAtIndex:[tabIndex intValue]];
  if (item != [filterSettingsTabView selectedTabViewItem]) {
    [filterNameTextField setStringValue:[filter name]];
    [filterSettingsTabView selectTabViewItem:item];

    NSSize visibleSize = [[item view] visibleRect].size;
    NSSize requiredSize = [[panelSizes objectForKey:[filter name]] sizeValue];
    float deltaH = requiredSize.height - visibleSize.height;

    float minDim = [filterSettingsSubView minDimension];
    float requiredDim = fmax([filterSettingsSubView dimension] + deltaH, minDim);
    [filterSettingsSubView setMinDimension:minDim andMaxDimension:requiredDim];
    [filterSettingsSubView setDimension:requiredDim];
  }
}

- (IFFilterController*)filterControllerForName:(NSString*)filterName;
{
  IFFilterController* controller = [filterControllers objectForKey:filterName];
  if (controller == nil) {
    controller = [IFFilterController new];
    [filterControllers setObject:controller forKey:filterName];
    [controller release];
  }
  return controller;
}

@end
