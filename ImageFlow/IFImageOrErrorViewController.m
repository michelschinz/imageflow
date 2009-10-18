//
//  IFImageOrErrorViewController.m
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFImageOrErrorViewController.h"

#import "IFErrorConstantExpression.h"
#import "IFExpression.h"
#import "NSAffineTransformIFAdditions.h"
#import "IFBlendMode.h"
#import "IFArrayPath.h"

@interface IFImageOrErrorViewController ()
@property(assign) NSView* activeView;
@property(copy) NSString* errorMessage;
@property(retain) IFTreeNode* viewedNode;
@property(retain) IFExpression* displayedExpression;
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
  displayedExpression = nil;
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
  [cursorsVar addObserver:self forKeyPath:@"value.viewLockedIndex" options:0 context:IFViewedExpressionDidChange];
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
  [cursorsVar removeObserver:self forKeyPath:@"value.viewLockedIndex"];  
  [cursorsVar removeObserver:self forKeyPath:@"value.viewLockedNode.expression"];
  OBJC_RELEASE(cursorsVar);

  if (viewedNode != nil)
    OBJC_RELEASE(viewedNode);
  if (activeVariant != nil)
    OBJC_RELEASE(activeVariant);
  OBJC_RELEASE(variants);
  if (errorMessage != nil)
    OBJC_RELEASE(errorMessage);
  if (displayedExpression != nil)
    OBJC_RELEASE(displayedExpression);
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

@synthesize viewedNode;

@synthesize displayedExpression;
- (void)setDisplayedExpression:(IFExpression*)newDisplayedExpression;
{
  if (newDisplayedExpression == displayedExpression)
    return;
  
  IFExpressionEvaluator* evaluator = [IFExpressionEvaluator sharedEvaluator];
  IFConstantExpression* evaluatedNewExpr = [evaluator evaluateExpression:newDisplayedExpression];
  
  if ([evaluatedNewExpr isImage]) {
    NSRect dirtyRect = (displayedExpression == nil || newDisplayedExpression == nil)
    ? NSRectInfinite()
    : [[cursorsVar.value editViewTransform] transformRect:[evaluator deltaFromOld:displayedExpression toNew:newDisplayedExpression]];
    [imageView setImage:[(IFImageConstantExpression*)evaluatedNewExpr image] dirtyRect:dirtyRect];
    self.errorMessage = nil;
    [imageOrErrorTabView selectTabViewItemAtIndex:0];
    self.activeView = imageView;
  } else {
    NSAssert([evaluatedNewExpr isError], @"unexpected expression");
    [imageView setImage:nil dirtyRect:NSRectInfinite()];
    self.errorMessage = [(IFErrorConstantExpression*)evaluatedNewExpr message];
    [imageOrErrorTabView selectTabViewItemAtIndex:1];
    self.activeView = imageOrErrorTabView;
  }
  
  [displayedExpression release];
  displayedExpression = [newDisplayedExpression retain];
}

- (void)updateImageViewVisibleBounds;
{
  NSRect realCanvasBounds = NSInsetRect([canvasBoundsVar.value rectValue], -20, -20);
  [imageView setVisibleBounds:realCanvasBounds];
  
  // FIXME: should avoid this, to prevent redrawing of the whole image!
  self.displayedExpression = [IFExpression fail];
  [self updateExpression];
}

- (void)updateExpression;
{
  IFTreeCursorPair* cursors = (IFTreeCursorPair*)cursorsVar.value;
  IFTreeNode* node = cursors.viewLockedNode;
  
  if (node != nil) {
    IFType* exprType = node.type.resultType;

    if (exprType != nil && ([exprType isArrayType] || [exprType isImageRGBAType] || [exprType isMaskType])) {
      IFExpression* expr = node.expression; // TODO: re-introduce variants
      if ([exprType isArrayType]) {
        IFArrayPath* path = cursors.viewLockedPath;
        expr = [path accessorExpressionFor:expr];
        exprType = exprType.leafType;
      }
      
      if ([exprType isImageRGBAType]) {
        IFExpression* backgroundExpr = [IFExpression checkerboardCenteredAt:NSZeroPoint color0:[NSColor whiteColor] color1:[NSColor colorWithCalibratedRed:0.8 green:0.8 blue:0.8 alpha:1.0] width:40.0 sharpness:1.0];
        expr = [IFExpression blendBackground:backgroundExpr withForeground:expr inMode:[IFConstantExpression expressionWithInt:IFBlendMode_SourceOver]];
      } else if ([exprType isMaskType]) {
        expr = [IFExpression maskToImage:expr];
      } else {
        // TODO: also handle action previews
        expr = [IFExpression fail];
      }

      self.displayedExpression = expr;
    } else
      self.displayedExpression = [IFExpression fail];
  } else
    self.displayedExpression = [IFExpression fail];
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
