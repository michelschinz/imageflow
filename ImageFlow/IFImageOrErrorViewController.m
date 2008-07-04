//
//  IFImageOrErrorViewController.m
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFImageOrErrorViewController.h"

#import "IFErrorConstantExpression.h"
#import "IFOperatorExpression.h"
#import "NSAffineTransformIFAdditions.h"

typedef enum {
  IFFilterDelegateHasMouseDown    = 1<<0,
  IFFilterDelegateHasMouseDragged = 1<<1,
  IFFilterDelegateHasMouseUp      = 1<<2
} IFFilterDelegateCapabilities;

@interface IFImageOrErrorViewController (Private)
- (void)setActiveView:(NSView*)newActiveView;
- (void)setErrorMessage:(NSString*)newErrorMessage;
- (void)setViewedNode:(IFTreeNode*)newViewedNode;
- (void)setExpression:(IFExpression*)newExpression;
- (void)updateImageViewVisibleBounds;
- (void)updateExpression;
- (void)updateAnnotations;
- (void)updateVariants;
@end

@implementation IFImageOrErrorViewController

static NSString* IFViewedExpressionDidChange = @"IFViewedExpressionDidChange";
static NSString* IFEditedNodeDidChange = @"IFEditedNodeDidChange";
static NSString* IFCanvasBoundsDidChange = @"IFCanvasBoundsDidChange";

- (id)init;
{
  if (![super initWithViewNibName:@"IFImageView"])
    return nil;
  activeView = nil;
  mode = IFImageViewModeView;
  expression = nil;
  errorMessage = nil;
  variants = [[NSArray array] retain];
  activeVariant = nil;
  viewedNode = nil;
  return self;
}

- (void)postInitWithCursorsVar:(IFVariable*)theCursorsVar canvasBoundsVar:(IFVariable*)theCanvasBoundsVar;
{
  NSAssert(cursorsVar == nil && canvasBoundsVar == nil, @"duplicate post-initialisation");

  cursorsVar = [theCursorsVar retain];
  canvasBoundsVar = [theCanvasBoundsVar retain];
  
  [cursorsVar addObserver:self forKeyPath:@"value.viewMark.node.expression" options:0 context:IFViewedExpressionDidChange];
  [cursorsVar addObserver:self forKeyPath:@"value.editMark.node" options:0 context:IFEditedNodeDidChange];
  [canvasBoundsVar addObserver:self forKeyPath:@"value" options:0 context:IFCanvasBoundsDidChange];
  
  [imageView setCanvasBounds:canvasBoundsVar];
  
  [self updateImageViewVisibleBounds];
}

- (void)dealloc;
{
  NSAssert(cursorsVar != nil && canvasBoundsVar != nil, @"post-initialisation not done");
  [canvasBoundsVar removeObserver:self forKeyPath:@"value"];
  OBJC_RELEASE(canvasBoundsVar);
  [cursorsVar removeObserver:self forKeyPath:@"value.editMark.node"];
  [cursorsVar removeObserver:self forKeyPath:@"value.viewMark.node.expression"];
  OBJC_RELEASE(cursorsVar);

  if (viewedNode != nil)
    OBJC_RELEASE(viewedNode);
  if (activeVariant != nil)
    OBJC_RELEASE(activeVariant);
  OBJC_RELEASE(variants);
  if (errorMessage != nil)
    OBJC_RELEASE(errorMessage);
  if (expression != nil)
    OBJC_RELEASE(expression);
  activeView = nil;
  OBJC_RELEASE(imageView);
  OBJC_RELEASE(imageOrErrorTabView);
  [super dealloc];
}

- (void)awakeFromNib;
{
  NSScrollView* scrollView = [imageView enclosingScrollView];
  [scrollView setHasHorizontalRuler:YES];
  [scrollView setHasVerticalRuler:YES];
  [scrollView setRulersVisible:YES];

  [scrollView.horizontalRulerView setReservedThicknessForMarkers:0.0];
  
  [imageView setDelegate:self];
  
  [self setActiveView:imageOrErrorTabView];
}

- (IFImageView*)imageView;
{
  return imageView;
}

- (NSView*)activeView;
{
  return activeView;
}

- (void)setMode:(IFImageViewMode)newMode;
{
  if (newMode == mode)
    return;

  mode = newMode;

  [self updateVariants];
  [self updateAnnotations];
}

- (IFImageViewMode)mode;
{
  return mode;
}

@synthesize errorMessage;

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

- (NSString*)activeVariant;
{
  return activeVariant;
}

- (void)setActiveVariant:(NSString*)newActiveVariant;
{
  if (newActiveVariant == activeVariant)
    return;

  [activeVariant release];
  activeVariant = [newActiveVariant retain];

  [self updateExpression];
}

- (void)handleMouseDown:(NSEvent*)event;
{
  [editedNode mouseDown:event inView:imageView viewFilterTransform:[cursorsVar.value viewEditTransform]];
}

- (void)handleMouseDragged:(NSEvent*)event;
{
  [editedNode mouseDragged:event inView:imageView viewFilterTransform:[cursorsVar.value viewEditTransform]];
}

- (void)handleMouseUp:(NSEvent*)event;
{
  [editedNode mouseUp:event inView:imageView viewFilterTransform:[cursorsVar.value viewEditTransform]];
}

@end

@implementation IFImageOrErrorViewController (Private)

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  if (context == IFViewedExpressionDidChange) {
    IFTreeNode* currViewedNode = [[cursorsVar.value viewMark] node];
    if (currViewedNode != viewedNode) {
      [self updateVariants];
      [self updateAnnotations];
      [self setViewedNode:currViewedNode];
    }
    [self updateExpression];
  } else if (context == IFEditedNodeDidChange) {
    [self updateAnnotations];

    editedNode = [[cursorsVar.value editMark] node];
  } else if (context == IFCanvasBoundsDidChange) {
    [self updateImageViewVisibleBounds];
  } else
    NSAssert1(NO, @"unexpected context %@", context);
}

- (void)setActiveView:(NSView*)newActiveView;
{
  activeView = newActiveView;
}

- (void)setErrorMessage:(NSString*)newErrorMessage;
{
  if (newErrorMessage == errorMessage)
    return;
  [errorMessage release];
  errorMessage = [newErrorMessage copy];
}

- (void)setViewedNode:(IFTreeNode*)newViewedNode;
{
  if (newViewedNode == viewedNode)
    return;
  [viewedNode release];
  viewedNode = [newViewedNode retain];
}

- (void)setExpression:(IFExpression*)newExpression;
{
  if (newExpression == expression)
    return;

  IFExpressionEvaluator* evaluator = [IFExpressionEvaluator sharedEvaluator];
  NSRect dirtyRect = (expression == nil || newExpression == nil)
    ? NSRectInfinite()
    : [[cursorsVar.value editViewTransform] transformRect:[evaluator deltaFromOld:expression toNew:newExpression]];

  [expression release];
  expression = [newExpression retain];

  IFConstantExpression* evaluatedExpr = [evaluator evaluateExpressionAsMaskedImage:expression
                                                                            cutout:[canvasBoundsVar.value rectValue]];

  if ([evaluatedExpr isError]) {
    [self setErrorMessage:[(IFErrorConstantExpression*)evaluatedExpr message]];
    [imageOrErrorTabView selectTabViewItemAtIndex:1];
    [self setActiveView:imageOrErrorTabView];
    [imageView setImage:nil dirtyRect:NSRectInfinite()];
    [self setMode:IFImageViewModeEdit];
  } else {
    [imageView setImage:[(IFImageConstantExpression*)evaluatedExpr image] dirtyRect:dirtyRect];
    [self setErrorMessage:nil];
    [imageOrErrorTabView selectTabViewItemAtIndex:0];
    [self setActiveView:imageView];
  }
}

- (void)updateImageViewVisibleBounds;
{
  NSRect realCanvasBounds = NSInsetRect([canvasBoundsVar.value rectValue], -20, -20);
  [imageView setVisibleBounds:realCanvasBounds];
  
  // HACK should avoid this, to prevent redrawing of the whole image!
  [self setExpression:[IFOperatorExpression nop]];
  [self updateExpression];
}

- (void)updateExpression;
{
  IFTreeNode* node = [[cursorsVar.value viewMark] node];
  IFExpression* expr = (node != nil ? [node expression] : [IFOperatorExpression nop]);
  if ([self activeVariant] != nil && ![[self activeVariant] isEqualToString:@""])
    expr = [node variantNamed:[self activeVariant] ofExpression:expr];
  [self setExpression:expr];
}

- (void)updateAnnotations;
{
  if (mode == IFImageViewModeView)
    [imageView setAnnotations:nil];
  else {
    IFTreeNode* nodeToEdit = [[cursorsVar.value editMark] node];
    [imageView setAnnotations:[nodeToEdit editingAnnotationsForView:imageView]];
  }
}

- (void)updateVariants;
{
  [self setVariants:(mode == IFImageViewModeView
                     ? [[[cursorsVar.value viewMark] node] variantNamesForViewing]
                     : [[[cursorsVar.value viewMark] node] variantNamesForEditing])];
}

@end
