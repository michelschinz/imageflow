//
//  IFImageViewController.m
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFImageViewController.h"

#import "NSAffineTransformIFAdditions.h"
#import "IFErrorConstantExpression.h"

typedef enum {
  IFFilterDelegateHasMouseDown    = 1<<0,
  IFFilterDelegateHasMouseDragged = 1<<1,
  IFFilterDelegateHasMouseUp      = 1<<2
} IFFilterDelegateCapabilities;

@interface IFImageViewController (Private)
- (void)setActiveView:(NSView*)newActiveView;
- (void)setErrorMessage:(NSString*)newErrorMessage;
- (void)setViewedNode:(IFTreeNode*)newViewedNode;
- (void)setExpression:(IFExpression*)newExpression;
- (void)updateExpression;
- (void)updateAnnotations;
- (void)updateVariants;
- (void)updateEditViewTransform;
@end

@implementation IFImageViewController

static NSString* IFViewedExpressionDidChange = @"IFViewedExpressionDidChange";
static NSString* IFEditedNodeDidChange = @"IFEditedNodeDidChange";

- (id)init;
{
  if (![super initWithViewNibName:@"IFImageView"])
    return nil;
  mode = IFImageViewModeView;
  evaluator = nil;
  expression = nil;
  errorMessage = nil;
  editViewTransform = [[NSAffineTransform transform] retain];
  viewEditTransform = [[NSAffineTransform transform] retain];
  variants = [[NSArray array] retain];
  activeVariant = nil;
  cursors = nil;
  viewedNode = nil;
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(viewedNode);
  [self setCursorPair:nil];
  OBJC_RELEASE(activeVariant);
  OBJC_RELEASE(variants);
  OBJC_RELEASE(viewEditTransform);
  OBJC_RELEASE(editViewTransform);
  OBJC_RELEASE(errorMessage);
  OBJC_RELEASE(expression);
  OBJC_RELEASE(evaluator);
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

  [imageView setDelegate:self];
  
  [self setActiveView:imageOrErrorTabView];
}

- (NSView*)activeView;
{
  return activeView;
}

- (void)setEvaluator:(IFExpressionEvaluator*)newEvaluator;
{
  if (newEvaluator == evaluator)
    return;
  [evaluator release];
  evaluator = [newEvaluator retain];
}

- (void)setCursorPair:(IFTreeCursorPair*)newCursors;
{
  if (newCursors == cursors)
    return;
  
  if (cursors != nil) {
    [[cursors viewMark] removeObserver:self forKeyPath:@"node.expression"];
    [[cursors editMark] removeObserver:self forKeyPath:@"node"];
    [cursors release];
  }
  if (newCursors != nil) {
    [[newCursors viewMark] addObserver:self forKeyPath:@"node.expression" options:0 context:IFViewedExpressionDidChange];
    [[newCursors editMark] addObserver:self forKeyPath:@"node" options:0 context:IFEditedNodeDidChange];
    [newCursors retain];
  }
  cursors = newCursors;
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

- (void)setCanvasBounds:(NSRect)newCanvasBounds;
{
  [imageView setCanvasBounds:newCanvasBounds];
}

- (NSString*)errorMessage;
{
  return errorMessage;
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
  if (filterDelegateCapabilities & IFFilterDelegateHasMouseDown)
    [filterDelegate mouseDown:event
                       inView:imageView
          viewFilterTransform:viewEditTransform
              withEnvironment:[[[[cursors editMark] node] filter] environment]];
}

- (void)handleMouseDragged:(NSEvent*)event;
{
  if (filterDelegateCapabilities & IFFilterDelegateHasMouseDragged)
    [filterDelegate mouseDragged:event
                          inView:imageView
             viewFilterTransform:viewEditTransform
                 withEnvironment:[[[[cursors editMark] node] filter] environment]];
}

- (void)handleMouseUp:(NSEvent*)event;
{
  if (filterDelegateCapabilities & IFFilterDelegateHasMouseUp)
    [filterDelegate mouseUp:event
                     inView:imageView
        viewFilterTransform:viewEditTransform
            withEnvironment:[[[[cursors editMark] node] filter] environment]];
}

@end

@implementation IFImageViewController (Private)

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  if (context == IFViewedExpressionDidChange) {
    if ([[cursors viewMark] node] != viewedNode) {
      [self updateVariants];
      [self updateEditViewTransform];
      [self updateAnnotations];
      [self setViewedNode:[[cursors viewMark] node]];
    }
    [self updateExpression];
  } else if (context == IFEditedNodeDidChange) {
    [self updateEditViewTransform];
    [self updateAnnotations];

    filterDelegate = [[[[[cursors editMark] node] filter] filter] delegate];
    filterDelegateCapabilities = 0
      | ([filterDelegate respondsToSelector:@selector(mouseDown:inView:viewFilterTransform:withEnvironment:)]
         ? IFFilterDelegateHasMouseDown : 0)
      | ([filterDelegate respondsToSelector:@selector(mouseDragged:inView:viewFilterTransform:withEnvironment:)]
         ? IFFilterDelegateHasMouseDragged : 0)
      | ([filterDelegate respondsToSelector:@selector(mouseUp:inView:viewFilterTransform:withEnvironment:)]
         ? IFFilterDelegateHasMouseUp : 0);
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

  NSRect dirtyRect = (expression == nil || newExpression == nil)
    ? NSRectInfinite()
    : [editViewTransform transformRect:[evaluator deltaFromOld:expression toNew:newExpression]];

  [expression release];
  expression = [newExpression retain];

  IFConstantExpression* evaluatedExpr = [evaluator evaluateExpressionAsImage:expression];

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

- (void)updateExpression;
{
  IFTreeNode* node = [[cursors viewMark] node];
  IFFilter* filter = [[node filter] filter];
  IFExpression* expr = (node != nil ? [node expression] : [IFOperatorExpression nop]);
  if ([self activeVariant] != nil && ![[self activeVariant] isEqualToString:@""])
    expr = [filter variantNamed:[self activeVariant] ofExpression:expression];
  [self setExpression:expr];
}

- (void)updateAnnotations;
{
  if (mode == IFImageViewModeView)
    [imageView setAnnotations:nil];
  else {
    IFTreeNode* nodeToEdit = [[cursors editMark] node];
    [imageView setAnnotations:[[[nodeToEdit filter] filter] editingAnnotationsForNode:nodeToEdit view:imageView]];
  }
}

- (void)updateVariants;
{
  IFFilter* filter = [[[[cursors viewMark] node] filter] filter];
  [self setVariants:(mode == IFImageViewModeView
                     ? [filter variantNamesForViewing]
                     : [filter variantNamesForEditing])];
}

- (void)updateEditViewTransform;
{
  NSAffineTransform* evTransform = [NSAffineTransform transform];
  [editViewTransform setToIdentity];
  [viewEditTransform setToIdentity];

  IFTreeNode* nodeToEdit = [[cursors editMark] node];
  if (nodeToEdit == nil) return;
  IFTreeNode* nodeToView = [[cursors viewMark] node];
  if (nodeToView == nil) return;
  
  for (IFTreeNode* node = nodeToEdit; node != nodeToView; node = [node child]) {
    if (node == nil) return;
    IFConfiguredFilter* cFilter = [[node child] filter];
    int parentIndex = [[[node child] parents] indexOfObject:node];
    [evTransform appendTransform:[[cFilter filter] transformForParentAtIndex:parentIndex withEnvironment:[cFilter environment]]];
  }

  [editViewTransform setTransformStruct:[evTransform transformStruct]];
  [viewEditTransform setTransformStruct:[evTransform transformStruct]];
  [viewEditTransform invert];
}

@end
