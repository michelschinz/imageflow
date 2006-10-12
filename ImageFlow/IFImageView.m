//
//  IFImageView.m
//  ImageFlow
//
//  Created by Michel Schinz on 07.09.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFImageView.h"
#import "IFImageConstantExpression.h"
#import "IFOperatorExpression.h"
#import "IFUtilities.h"
#import "IFAnnotation.h"
#import "IFCursorRect.h"

typedef enum {
  IFImageViewDelegateHasHandleMouseDown    = (1<<0),
  IFImageViewDelegateHasHandleMouseDragged = (1<<1),
  IFImageViewDelegateHasHandleMouseUp      = (1<<2)
} IFImageViewDelegateCapabilities;

@interface IFImageView (Private)
- (IFImageConstantExpression*)evaluatedExpression;
- (void)setEvaluatedExpression:(IFImageConstantExpression*)newEvaluatedExpression;
- (NSRect)imageExtent;
- (void)updateFrameSize;
- (void)updateBoundsOrigin;
@end

@implementation IFImageView

static CIImage* emptyImage;

+ (void)initialize;
{
  CIFilter* emptyFilter = [CIFilter filterWithName:@"IFEmpty"];
  emptyImage = [[emptyFilter valueForKey:@"outputImage"] retain];
}

- (id)initWithFrame:(NSRect)frame;
{
  if (![super initWithFrame:frame])
    return nil;
  
  grabableViewMixin = [[IFGrabableViewMixin alloc] initWithView:self];
  
  CIFilter* backgroundFilter = [[CIFilter filterWithName:@"CICheckerboardGenerator" keysAndValues:
    @"inputCenter", [CIVector vectorWithX:0 Y:0],
    @"inputColor0", [CIColor colorWithRed:1 green:1 blue:1],
    @"inputColor1", [CIColor colorWithRed:0.8 green:0.8 blue:0.8],
    @"inputWidth", [NSNumber numberWithInt:40],
    @"inputSharpness", [NSNumber numberWithInt:1],
    nil] retain];
  backgroundImage = [[backgroundFilter valueForKey:@"outputImage"] retain];
  backgroundCompositingFilter = [[CIFilter filterWithName:@"CISourceOverCompositing" keysAndValues:
    @"inputBackgroundImage", backgroundImage,
    nil] retain];
  evaluator = nil;
  expression = nil;
  annotations = nil;
  delegate = nil;

  [self updateBoundsOrigin];
  [self updateFrameSize];
  return self;
}

- (void) dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  [self setEvaluator:nil];
  [self setEvaluatedExpression:nil];
  [self setAnnotations:nil];
  [expression release];
  expression = nil;
  [backgroundCompositingFilter release];
  backgroundCompositingFilter = nil;
  [backgroundImage release];
  backgroundImage = nil;
  
  [grabableViewMixin release];
  grabableViewMixin = nil;
  
  [super dealloc];
}

- (void)viewWillMoveToSuperview:(NSView *)newSuperview;
{
  if ([self superview] != nil)
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:[self superview]];
  if (newSuperview != nil)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enclosingFrameDidChange:) name:NSViewFrameDidChangeNotification object:newSuperview];
}

- (void)setEvaluator:(IFExpressionEvaluator*)newEvaluator;
{
  if (newEvaluator == evaluator)
    return;

  if (evaluator != nil) {
    [evaluator removeObserver:self forKeyPath:@"workingColorSpace"];
    [evaluator removeObserver:self forKeyPath:@"resolutionX"];
    [evaluator removeObserver:self forKeyPath:@"resolutionY"];
  }    
  evaluator = newEvaluator;
  if (evaluator != nil) {
    [evaluator addObserver:self forKeyPath:@"workingColorSpace" options:0 context:nil];
    [evaluator addObserver:self forKeyPath:@"resolutionX" options:0 context:nil];
    [evaluator addObserver:self forKeyPath:@"resolutionY" options:0 context:nil];
  }  
  [self setNeedsDisplay:YES];
}

- (void)setExpression:(IFExpression*)newExpression;
{
  if (newExpression == expression)
    return;
  
  NSRect dirtyRect = (expression == nil || newExpression == nil)
    ? NSRectInfinite()
    : [evaluator deltaFromOld:expression toNew:newExpression];
  
  [expression release];
  expression = [newExpression retain];
  
  [self setEvaluatedExpression:nil];
  if (![self inInfiniteBoundsMode]) {
    [self updateFrameSize];
    [self updateBoundsOrigin];
  }
  [self setNeedsDisplayInRect:dirtyRect];
}

- (void)setAnnotations:(NSArray*)newAnnotations;
{
  if (newAnnotations == annotations)
    return;
  [annotations release];
  annotations = [newAnnotations copy];
  
  [self setNeedsDisplay:YES];
  [[self window] invalidateCursorRectsForView:self];
}

- (void)setDelegate:(NSObject<IFImageViewDelegate>*)newDelegate;
{
  delegate = newDelegate;
  delegateCapabilities = 0
    | ([delegate respondsToSelector:@selector(handleMouseDown:)] ? IFImageViewDelegateHasHandleMouseDown : 0)
    | ([delegate respondsToSelector:@selector(handleMouseDragged:)] ? IFImageViewDelegateHasHandleMouseDragged : 0)
    | ([delegate respondsToSelector:@selector(handleMouseUp:)] ? IFImageViewDelegateHasHandleMouseUp : 0);
}

- (NSSize)idealSize;
{
  return [self imageExtent].size;
}

- (void)enterInfiniteBoundsMode;
{
  NSAssert(![self inInfiniteBoundsMode], @"already in infinite bounds mode");
  
  NSPoint visibleOrigin = [self visibleRect].origin;
  [self setFrameSize:NSMakeSize(1000000,1000000)];
  [self setBoundsOrigin:NSMakePoint(-500000,-500000)];
  [self scrollPoint:visibleOrigin];

  NSScrollView* scrollView = [self enclosingScrollView];
  [[scrollView horizontalScroller] setEnabled:NO];
  [[scrollView verticalScroller] setEnabled:NO];
  
  infiniteBoundsMode = YES;
}

- (void)leaveInfiniteBoundsMode;
{
  NSAssert([self inInfiniteBoundsMode], @"not in infinite bounds mode");
  
  NSScrollView* scrollView = [self enclosingScrollView];
  [[scrollView horizontalScroller] setEnabled:YES];
  [[scrollView verticalScroller] setEnabled:YES];
  
  NSPoint visibleOrigin = [self visibleRect].origin;
  [self updateFrameSize];
  [self updateBoundsOrigin];
  [self scrollPoint:visibleOrigin];
  
  infiniteBoundsMode = NO;  
}

- (BOOL)inInfiniteBoundsMode;
{
  return infiniteBoundsMode;
}

- (void)drawRect:(NSRect)dirtyRect;
{
  CGRect dirtyRectCG = CGRectFromNSRect(dirtyRect);
  IFImageConstantExpression* imageExpr = [self evaluatedExpression];
  CIImage* image = (imageExpr == nil || [imageExpr isError])
    ? emptyImage
    : [imageExpr imageValueCI];
  [backgroundCompositingFilter setValue:image forKey:@"inputImage"];
  CIImage* imageWithBackground = [backgroundCompositingFilter valueForKey:@"outputImage"];
  CIContext* ctx = [CIContext contextWithCGContext:[[NSGraphicsContext currentContext] graphicsPort]
                                           options:[NSDictionary dictionary]]; // TODO working color space
  [ctx drawImage:imageWithBackground atPoint:dirtyRectCG.origin fromRect:dirtyRectCG];
  
  // Draw annotations
  const int annotationsCount = [annotations count];
  for (int i = 0; i < annotationsCount; ++i)
    [[annotations objectAtIndex:i] drawForRect:dirtyRect];
}

- (void)resetCursorRects;
{
  NSRect visibleRect = [self visibleRect];
  for (int i = 0; i < [annotations count]; ++i) {
    NSArray* cursorRects = [[annotations objectAtIndex:i] cursorRects];
    for (int j = 0; j < [cursorRects count]; ++j) {
      IFCursorRect* cursorRect = [cursorRects objectAtIndex:j];
      [self addCursorRect:NSIntersectionRect(visibleRect,[cursorRect rect]) cursor:[cursorRect cursor]];
    }
  }  
}

- (BOOL)isOpaque;
{
  return YES;
}

- (BOOL)acceptsFirstResponder;
{
  return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
  [self setEvaluatedExpression:nil];
  [self setNeedsDisplay:YES];
}

- (void)setBoundsOrigin:(NSPoint)newOrigin;
{
  [super setBoundsOrigin:newOrigin];
  NSScrollView* scrollView = [self enclosingScrollView];
  if (scrollView != nil) {    
    [[scrollView horizontalRulerView] setOriginOffset:-newOrigin.x];
    [[scrollView verticalRulerView] setOriginOffset:-newOrigin.y];
  }
}

#pragma mark event handling

- (void)mouseDown:(NSEvent*)event;
{
  if ([grabableViewMixin handlesMouseDown:event])
    return;
  
  for (int i = 0; i < [annotations count]; ++i)
    if ([(IFAnnotation*)[annotations objectAtIndex:i] handleMouseDown:event])
      return;
  if (delegateCapabilities & IFImageViewDelegateHasHandleMouseDown)
    [delegate handleMouseDown:event];
}

- (void)mouseUp:(NSEvent*)event;
{
  if ([grabableViewMixin handlesMouseUp:event])
    return;

  for (int i = 0; i < [annotations count]; ++i)
    if ([(IFAnnotation*)[annotations objectAtIndex:i] handleMouseUp:event])
      break;
  if (delegateCapabilities & IFImageViewDelegateHasHandleMouseUp)
    [delegate handleMouseUp:event];
}

- (void)mouseDragged:(NSEvent*)event;
{
  if ([grabableViewMixin handlesMouseDragged:event])
    return;

  for (int i = 0; i < [annotations count]; ++i)
    if ([(IFAnnotation*)[annotations objectAtIndex:i] handleMouseDragged:event])
      break;
  if (delegateCapabilities & IFImageViewDelegateHasHandleMouseDragged)
    [delegate handleMouseDragged:event];
}

- (void)keyDown:(NSEvent*)event;
{
  if (![grabableViewMixin handlesKeyDown:event])
    [super keyDown:event];
}

- (void)keyUp:(NSEvent*)event;
{
  if (![grabableViewMixin handlesKeyUp:event])
    [super keyUp:event];
}

@end

@implementation IFImageView (Private)

- (IFImageConstantExpression*)evaluatedExpression;
{
  if (expression == nil)
    return nil;

  if (evaluatedExpression == nil)
    [self setEvaluatedExpression:(IFImageConstantExpression*)[evaluator evaluateExpression:expression]];
  return evaluatedExpression;
}

- (void)setEvaluatedExpression:(IFImageConstantExpression*)newEvaluatedExpression;
{
  if (newEvaluatedExpression == evaluatedExpression)
    return;
  [evaluatedExpression release];
  evaluatedExpression = [newEvaluatedExpression retain];
}

- (NSRect)imageExtent;
{
  IFImageConstantExpression* imageExpr = [self evaluatedExpression];
  return (imageExpr == nil || [imageExpr isError])
    ? NSZeroRect
    : [[evaluator evaluateExpression:[IFOperatorExpression extentOf:imageExpr]] rectValueNS];
}

- (void)enclosingFrameDidChange:(NSNotification*)notification;
{
  [self updateFrameSize];
}

- (void)updateFrameSize;
{
  NSSize enclosingSize = [[self superview] frame].size;
  NSSize idealSize = [self idealSize];
  NSSize newSize = NSMakeSize(fmax(enclosingSize.width, idealSize.width),
                              fmax(enclosingSize.height, idealSize.height));
  if (NSEqualSizes(newSize,[self frame].size))
    return;
  
  [self setFrameSize:newSize];
  [self setNeedsDisplay:YES]; // TODO redisplay only exposed parts, if any
}

- (void)updateBoundsOrigin;
{
  NSPoint visibleOrigin = [self visibleRect].origin;
  [self setBoundsOrigin:[self imageExtent].origin];
  [self scrollPoint:visibleOrigin];
}

@end
