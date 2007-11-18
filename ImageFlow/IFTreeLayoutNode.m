//
//  IFTreeLayoutNode.m
//  ImageFlow
//
//  Created by Michel Schinz on 20.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFTreeLayoutNode.h"
#import "IFNodesView.h"
#import "IFErrorConstantExpression.h"
#import "IFOperatorExpression.h"

@interface IFTreeLayoutNode (Private)
- (void)updateInternalLayout;
- (void)setEvaluatedExpression:(IFConstantExpression*)newExpression;
- (void)updateExpression;
- (void)updateImageForContext:(CGContextRef)cgContext;
- (void)setThumbnailAspectRatio:(float)newThumbnailAspectRatio;
- (void)setImageLayer:(CGLayerRef)newImageLayer;
@end

@implementation IFTreeLayoutNode

static NSString* IFExpressionChangedContext = @"IFExpressionChangedContext";
static NSString* IFLayoutChangedContext = @"IFLayoutChangedContext";

static const int foldsCount = 3;
static const float foldHeight = 2.0;

static NSImage* errorImage = nil;
static NSImage* maskImage = nil;
static NSImage* aliasImage = nil;
static NSImage* lockedViewImage = nil;

+ (void)initialize;
{
  if (self != [IFTreeLayoutNode class])
    return; // avoid repeated initialisation
  errorImage = [NSImage imageNamed:@"warning-sign"];
  maskImage = [NSImage imageNamed:@"mask_tag"];
  aliasImage = [NSImage imageNamed:@"alias_arrow"];
  lockedViewImage = [NSImage imageNamed:@"locked_view"];
}

+ (id)layoutNodeWithNode:(IFTreeNode*)theNode containingView:(IFNodesView*)theContainingView;
{
  return [[[self alloc] initWithNode:theNode containingView:theContainingView] autorelease];
}

- (id)initWithNode:(IFTreeNode*)theNode containingView:(IFNodesView*)theContainingView;
{
  if (![super initWithNode:theNode containingView:theContainingView]) return nil;
  evaluator = [[theContainingView document] evaluator];
  isViewLocked = isUnreachable = isMask = NO;
  [self updateExpression];
  [self updateInternalLayout];

  [node addObserver:self forKeyPath:@"expression" options:0 context:IFExpressionChangedContext];
  [evaluator addObserver:self forKeyPath:@"workingColorSpace" options:0 context:IFExpressionChangedContext];
  [[containingView layoutParameters] addObserver:self forKeyPath:@"columnWidth" options:0 context:IFLayoutChangedContext];
  [node addObserver:self forKeyPath:@"isFolded" options:0 context:IFLayoutChangedContext];
  return self;
}

- (void)dealloc;
{
  [node removeObserver:self forKeyPath:@"isFolded"];
  [[containingView layoutParameters] removeObserver:self forKeyPath:@"columnWidth"];
  [evaluator removeObserver:self forKeyPath:@"workingColorSpace"];
  [node removeObserver:self forKeyPath:@"expression"];
  node = nil;
  [self setEvaluatedExpression:nil];
  [self setImageLayer:NULL];
  [super dealloc];
}

- (void)setIsViewLocked:(BOOL)newValue;
{
  if (newValue == isViewLocked)
    return;
  isViewLocked = newValue;

  [self setImageLayer:NULL];
  [self setNeedsDisplay];
}

- (void)toggleIsViewLocked;
{
  [self setIsViewLocked:!isViewLocked];
}

- (BOOL)isViewLocked;
{
  return isViewLocked;
}

- (void)setIsUnreachable:(BOOL)newValue;
{
  if (newValue == isUnreachable)
    return;
  isUnreachable = newValue;

  [self setNeedsDisplay];
}

- (void)toggleIsUnreachable;
{
  [self setIsUnreachable:!isUnreachable];
}

- (BOOL)isUnreachable;
{
  return isUnreachable;
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  if (context == IFLayoutChangedContext)
    [self updateInternalLayout];
  else if (context == IFExpressionChangedContext) {
    [self updateExpression];
    [self setNeedsDisplay];
  } else
    NSAssert(NO, @"unexpected context");
}

- (IFTreeLayoutElementKind)kind;
{
  return IFTreeLayoutElementKindNode;
}

static int countAncestors(IFTree* tree, IFTreeNode* node) {
  NSArray* parents = [tree parentsOfNode:node];
  int count = [parents count];
  for (int i = 0; i < [parents count]; ++i)
    count += countAncestors(tree, [parents objectAtIndex:i]);
  return count;
}

- (void)drawForLocalRect:(NSRect)rect;
{
  CGContextRef currCtx = [[NSGraphicsContext currentContext] graphicsPort];
  if (imageLayer == NULL)
    [self updateImageForContext:currCtx];

  if (isUnreachable) {
    CGContextSaveGState(currCtx);
    CGContextSetAlpha(currCtx, 0.2);
  }
  CGContextDrawLayerInRect(currCtx, CGRectFromNSRect([self bounds]), imageLayer);
  if (isUnreachable)
    CGContextRestoreGState(currCtx);
}

- (void)setBounds:(NSRect)newBounds;
{
  [super setBounds:newBounds];
  [self updateExpression];
}

@end

@implementation IFTreeLayoutNode (Private)

- (void)updateInternalLayout;
{
  const float margin = [[containingView layoutParameters] nodeInternalMargin];
  const float externalWidth = [[containingView layoutParameters] columnWidth];
  const float internalWidth = externalWidth - 2.0 * margin;
  NSRect internalFrame = NSZeroRect;
  
  float x = margin, y = margin;

  if ([node name] != nil) {
    nameFrame = NSMakeRect(x,y,internalWidth,[[containingView layoutParameters] labelFontHeight]);
    internalFrame = NSUnionRect(internalFrame,nameFrame);
    y += NSHeight(nameFrame) + margin;
  } else
    nameFrame = NSZeroRect;

  if (showsErrorSign) {
    NSSize imageSize = [errorImage size];
    thumbnailFrame = NSMakeRect(x + (internalWidth - imageSize.width) / 2.0,y,imageSize.width,imageSize.height);
    internalFrame = NSUnionRect(internalFrame,thumbnailFrame);
    y += NSHeight(thumbnailFrame) + margin;
  } else if (thumbnailAspectRatio != 0.0) {
    thumbnailFrame = (thumbnailAspectRatio <= 1.0)
    ? NSMakeRect(x + round(internalWidth * (1 - thumbnailAspectRatio) / 2.0),y,floor(internalWidth * thumbnailAspectRatio),internalWidth)
    : NSMakeRect(x,y,internalWidth,floor(internalWidth / thumbnailAspectRatio));
    internalFrame = NSUnionRect(internalFrame,thumbnailFrame);
    y += NSHeight(thumbnailFrame) + margin;
  } else
    thumbnailFrame = NSZeroRect;

  labelFrame = NSMakeRect(x,y,internalWidth,[[containingView layoutParameters] labelFontHeight]);
  y += NSHeight(labelFrame);
  internalFrame = NSUnionRect(internalFrame,labelFrame);
  
  BOOL isFolded = [node isFolded], isSource = isFolded || ([node inputArity] == 0), isSink = ([node outputArity] == 0);
  if (isFolded) {
    foldingFrame = NSMakeRect(x,y + margin,internalWidth,2 * foldsCount * foldHeight - margin);
    internalFrame = NSUnionRect(internalFrame,foldingFrame);
  } else
    foldingFrame = NSZeroRect;

  NSRect externalFrame = NSInsetRect(internalFrame,-margin,-margin);
  NSAssert(fabs(NSWidth(externalFrame) - [[containingView layoutParameters] columnWidth]) < 0.001, @"invalid external frame");
  
  NSBezierPath* outline = [NSBezierPath bezierPath];
  if (isSink) {
    [outline moveToPoint:NSZeroPoint];
    [outline lineToPoint:NSMakePoint(NSMaxX(externalFrame),NSMinY(externalFrame))];
  } else {
    [outline appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(internalFrame),NSMinY(internalFrame))
                                        radius:margin
                                    startAngle:180
                                      endAngle:-90];
    [outline appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(internalFrame),NSMinY(internalFrame))
                                        radius:margin
                                    startAngle:-90
                                      endAngle:0];
  }
  if (isSource) {
    [outline lineToPoint:NSMakePoint(NSMaxX(externalFrame),NSMaxY(externalFrame))];
    [outline lineToPoint:NSMakePoint(NSMinX(externalFrame),NSMaxY(externalFrame))];
  } else {
    [outline appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(internalFrame),NSMaxY(internalFrame))
                                        radius:margin
                                    startAngle:0
                                      endAngle:90];
    [outline appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(internalFrame),NSMaxY(internalFrame))
                                        radius:margin
                                    startAngle:90
                                      endAngle:180];
  }
  [outline closePath];
  [self setOutlinePath:outline];
  [self setImageLayer:NULL];
}

- (void)updateImageForContext:(CGContextRef)cgContext;
{
  NSSize size = [self bounds].size;
  [self setImageLayer:CGLayerCreateWithContext(cgContext,CGSizeMake(size.width,size.height),NULL)];
  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:CGLayerGetContext(imageLayer) flipped:NO]];
  
  // Draw background rectangle
  NSBezierPath* backgroundPath = [self outlinePath];
  [[NSColor whiteColor] set];
  [backgroundPath fill];

  // Draw folds, if any
  if (!NSIsEmptyRect(foldingFrame)) {
    [[NSColor colorWithCalibratedWhite:0.5 alpha:1.0] set];
    for (int i = 0; i < foldsCount; ++i)
      NSRectFill(NSMakeRect(0,NSMinY(foldingFrame) + 2*i*foldHeight,NSWidth([self bounds]),foldHeight));
  }
  
  // Draw view locking icon, if needed
  NSRect labelTextFrame;
  if (isViewLocked) {
    NSSize imageSize = [lockedViewImage size];
    NSPoint p = NSMakePoint(NSMinX(labelFrame),
                            floor(NSMinY(labelFrame) + (NSHeight(labelFrame) - imageSize.height) / 2.0));
    [lockedViewImage compositeToPoint:p operation:NSCompositeSourceOver];
    labelTextFrame = NSMakeRect(NSMinX(labelFrame) + (imageSize.width + 1.0),
                                NSMinY(labelFrame),
                                NSWidth(labelFrame) - (imageSize.width + 1.0),
                                NSHeight(labelFrame));
  } else
    labelTextFrame = labelFrame;
  
  // Draw label
  NSFont* labelFont = [[containingView layoutParameters] labelFont];
  NSMutableParagraphStyle* parStyle = [NSMutableParagraphStyle new];
  [parStyle setAlignment:NSCenterTextAlignment];
  NSString* labelStr = [node isFolded]
    ? [NSString stringWithFormat:@"(%d nodes)",1 + countAncestors([containingView tree], node)]
    : [node label];
  NSAttributedString* label = [[[NSAttributedString alloc] initWithString:labelStr
                                                               attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 parStyle, NSParagraphStyleAttributeName,
                                                                 labelFont, NSFontAttributeName,
                                                                 [NSColor blackColor], NSForegroundColorAttributeName,
                                                                 nil]] autorelease];
  [label drawWithRect:NSOffsetRect(labelTextFrame,0,-[labelFont descender]) options:0];
  
  // Draw thumbnail, if any
  if (showsErrorSign)
    [errorImage compositeToPoint:thumbnailFrame.origin operation:NSCompositeSourceOver];
  else if (!NSIsEmptyRect(thumbnailFrame) && ![evaluatedExpression isError]) {
    CIImage* image = [(IFImageConstantExpression*)evaluatedExpression imageValueCI];
    CIContext* ctx = [CIContext contextWithCGContext:[[NSGraphicsContext currentContext] graphicsPort]
                                             options:[NSDictionary dictionary]]; // TODO working color space
    NSRect targetRect = thumbnailFrame;
    NSRect sourceRect = expressionExtent;
    float resizing = fmax(NSWidth(targetRect) / NSWidth(sourceRect), NSHeight(targetRect) / NSHeight(sourceRect));
    sourceRect.size.width = floor(NSWidth(targetRect) / resizing);
    sourceRect.size.height = floor(NSHeight(targetRect) / resizing);
    [ctx drawImage:image inRect:CGRectFromNSRect(targetRect) fromRect:CGRectFromNSRect(sourceRect)];

    // Draw tag, if needed
    if (isMask) {
      NSPoint maskOrigin = NSMakePoint(NSMaxX(thumbnailFrame) - [maskImage size].width, NSMinY(thumbnailFrame));
      [maskImage compositeToPoint:maskOrigin operation:NSCompositeSourceOver];
    }    
  }

  // Draw alias arrow, if necessary
  if ([node isAlias])
    [aliasImage compositeToPoint:thumbnailFrame.origin operation:NSCompositeSourceOver];

  // Draw name, if any
  if (!NSIsEmptyRect(nameFrame)) {
    NSAttributedString* name = [[[NSAttributedString alloc] initWithString:@"name" // TODO
                                                                attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  parStyle, NSParagraphStyleAttributeName,
                                                                  labelFont, NSFontAttributeName,
                                                                  [NSColor blackColor], NSForegroundColorAttributeName,
                                                                  nil]] autorelease];
    [[NSColor yellowColor] set];
    [[NSBezierPath bezierPathWithRect:nameFrame] fill];
    [name drawWithRect:NSOffsetRect(nameFrame,0,-[labelFont descender]) options:0];
  }
  
  [NSGraphicsContext restoreGraphicsState];
}

- (void)setEvaluatedExpression:(IFConstantExpression*)newExpression;
{
  if (newExpression == evaluatedExpression)
    return;
  [evaluatedExpression release];
  evaluatedExpression = [newExpression retain];
}

- (void)updateExpression;
{
  const float margin = [[containingView layoutParameters] nodeInternalMargin];

  if (evaluatedExpression != nil)
    OBJC_RELEASE(evaluatedExpression);
  [self setImageLayer:NULL];
  
  IFExpression* nodeExpression = [node expression];
  if (nodeExpression == nil)
    return;
  IFConstantExpression* extentExpr = [evaluator evaluateExpression:[IFOperatorExpression extentOf:nodeExpression]];
  if (![extentExpr isError]) {
    NSRect extent = [extentExpr rectValueNS];
    NSRect canvasBounds = [[containingView document] canvasBounds]; // TODO observe
    NSRect croppedExtent = NSIntersectionRect(extent, canvasBounds);
    float maxSide = [[containingView layoutParameters] columnWidth] - 2.0 * margin;
    float scaling = maxSide / fmax(NSWidth(croppedExtent), NSHeight(croppedExtent));
    IFConstantExpression* basicExpression = [evaluator evaluateExpression:nodeExpression];
    isMask = ![basicExpression isError] && ([[(IFImageConstantExpression*)basicExpression image] kind] == IFImageKindMask);
    IFExpression* imageExpression = [evaluator evaluateExpressionAsImage:basicExpression];
    IFExpression* croppedExpression = NSContainsRect(canvasBounds, extent)
      ? imageExpression
      : [IFOperatorExpression crop:imageExpression along:canvasBounds];
    IFExpression* scaledCroppedExpression = [IFOperatorExpression resample:croppedExpression by:scaling];
    [self setEvaluatedExpression:[evaluator evaluateExpression:scaledCroppedExpression]];
    expressionExtent = NSRectScale(croppedExtent, scaling);
    showsErrorSign = NO;
    [self setThumbnailAspectRatio:NSIsEmptyRect(croppedExtent) ? 0.0 : NSWidth(croppedExtent) / NSHeight(croppedExtent)];
  } else {
    IFErrorConstantExpression* errorExpr = (IFErrorConstantExpression*)[evaluator evaluateExpression:nodeExpression];
    NSAssert1([errorExpr isError], @"error expected, got %@",errorExpr);
    [self setEvaluatedExpression:errorExpr];
    showsErrorSign = ([errorExpr message] != nil);
    [self setThumbnailAspectRatio:0.0];
  }
}

- (void)setThumbnailAspectRatio:(float)newThumbnailAspectRatio;
{
  float delta = fabs(newThumbnailAspectRatio - thumbnailAspectRatio);
  thumbnailAspectRatio = newThumbnailAspectRatio;
  if (delta < 0.00001)
    return;
  [self updateInternalLayout];
  [containingView invalidateLayout];
}

- (void)setImageLayer:(CGLayerRef)newImageLayer;
{
  if (newImageLayer == imageLayer)
    return;
  CGLayerRelease(imageLayer);
  imageLayer = CGLayerRetain(newImageLayer);
}

@end
