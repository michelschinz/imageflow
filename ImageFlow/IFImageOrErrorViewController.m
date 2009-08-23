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

@interface IFImageOrErrorViewController ()
@property(assign) NSView* activeView;
@property(copy) NSString* errorMessage;
@property(retain) IFTreeNode* viewedNode;
@property(retain) IFExpression* expression;
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
  
  [cursorsVar addObserver:self forKeyPath:@"value.viewLockedNode.expression" options:0 context:IFViewedExpressionDidChange];
  [cursorsVar addObserver:self forKeyPath:@"value.node" options:0 context:IFEditedNodeDidChange];
  [canvasBoundsVar addObserver:self forKeyPath:@"value" options:0 context:IFCanvasBoundsDidChange];
  
  [imageView setCanvasBounds:canvasBoundsVar];
  
  [self updateImageViewVisibleBounds];
}

- (void)dealloc;
{
  NSAssert(cursorsVar != nil && canvasBoundsVar != nil, @"post-initialisation not done");
  [canvasBoundsVar removeObserver:self forKeyPath:@"value"];
  OBJC_RELEASE(canvasBoundsVar);
  [cursorsVar removeObserver:self forKeyPath:@"value.node"];
  [cursorsVar removeObserver:self forKeyPath:@"value.viewLockedNode.expression"];
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

@synthesize imageView, activeView;

@synthesize mode;
- (void)setMode:(IFImageViewMode)newMode;
{
  if (newMode == mode)
    return;

  mode = newMode;

  [self updateVariants];
  [self updateAnnotations];
}

@synthesize errorMessage;

@synthesize variants;
- (void)setVariants:(NSArray*)newVariants;
{
  if (newVariants == variants)
    return;

  if (![newVariants containsObject:[self activeVariant]])
    [self setActiveVariant:[newVariants objectAtIndex:0]];

  [variants release];
  variants = [newVariants copy];
}

@synthesize activeVariant;
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

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  if (context == IFViewedExpressionDidChange) {
    IFTreeNode* currViewedNode = ((IFTreeCursorPair*)cursorsVar.value).viewLockedNode;
    if (currViewedNode != viewedNode) {
      [self updateVariants];
      [self updateAnnotations];
      [self setViewedNode:currViewedNode];
    }
    [self updateExpression];
  } else if (context == IFEditedNodeDidChange) {
    [self updateAnnotations];

    editedNode = ((IFTreeCursorPair*)cursorsVar.value).node;
  } else if (context == IFCanvasBoundsDidChange) {
    [self updateImageViewVisibleBounds];
  } else
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

// MARK: -
// MARK: PRIVATE

@synthesize activeView;
@synthesize errorMessage;
@synthesize viewedNode;

@synthesize expression;
- (void)setExpression:(IFExpression*)newExpression;
{
  if (newExpression == expression)
    return;

  IFExpressionEvaluator* evaluator = [IFExpressionEvaluator sharedEvaluator];

  IFConstantExpression* evaluatedNewExpr = [evaluator evaluateExpression:newExpression];

  // TODO: make dirty rect. computation work in the presence of arrays. Old code:
//  NSRect dirtyRect = (expression == nil || newExpression == nil)
//  ? NSRectInfinite()
//  : [[cursorsVar.value editViewTransform] transformRect:[evaluator deltaFromOld:expression toNew:newExpression]];
  
  if ([evaluatedNewExpr isImage]) {
    [imageView setImage:[(IFImageConstantExpression*)[evaluator evaluateExpressionAsImage:evaluatedNewExpr] image] dirtyRect:NSRectInfinite()];
    [self setErrorMessage:nil];
    [imageOrErrorTabView selectTabViewItemAtIndex:0];
    [self setActiveView:imageView];
  } else if ([evaluatedNewExpr isArray]) {
    unsigned imageIndex = [((IFTreeCursorPair*)cursorsVar.value) viewLockedIndex];
    IFExpression* imageExpr = [[evaluatedNewExpr flatArrayValue] objectAtIndex:imageIndex];
    // TODO: compute the right dirty rect. in this case too
    [imageView setImage:[(IFImageConstantExpression*)[evaluator evaluateExpressionAsImage:imageExpr] image] dirtyRect:NSRectInfinite()];
    [self setErrorMessage:nil];
    [imageOrErrorTabView selectTabViewItemAtIndex:0];
    [self setActiveView:imageView];
  } else {
    NSAssert([evaluatedNewExpr isError], @"unexpected expression");
    [self setErrorMessage:[(IFErrorConstantExpression*)evaluatedNewExpr message]];
    [imageOrErrorTabView selectTabViewItemAtIndex:1];
    [self setActiveView:imageOrErrorTabView];
    [imageView setImage:nil dirtyRect:NSRectInfinite()];
    [self setMode:IFImageViewModeEdit];
  }

  [expression release];
  expression = [newExpression retain];  
}

- (void)updateImageViewVisibleBounds;
{
  NSRect realCanvasBounds = NSInsetRect([canvasBoundsVar.value rectValue], -20, -20);
  [imageView setVisibleBounds:realCanvasBounds];
  
  // FIXME: should avoid this, to prevent redrawing of the whole image!
  [self setExpression:[IFOperatorExpression nop]];
  [self updateExpression];
}

- (void)updateExpression;
{
  IFTreeNode* node = ((IFTreeCursorPair*)cursorsVar.value).viewLockedNode;
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
    IFTreeNode* nodeToEdit = ((IFTreeCursorPair*)cursorsVar.value).node;
    [imageView setAnnotations:[nodeToEdit editingAnnotationsForView:imageView]];
  }
}

- (void)updateVariants;
{
  [self setVariants:(mode == IFImageViewModeView
                     ? ((IFTreeCursorPair*)cursorsVar.value).viewLockedNode.variantNamesForViewing
                     : ((IFTreeCursorPair*)cursorsVar.value).viewLockedNode.variantNamesForEditing)];
}

@end
