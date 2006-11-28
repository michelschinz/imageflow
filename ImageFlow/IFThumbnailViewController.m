//
//  IFThumbnailViewController.m
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFThumbnailViewController.h"

@interface IFThumbnailViewController (Private)
- (void)updateExpression;
@end

@implementation IFThumbnailViewController

const float thumbnailFactor = 4.0;

static NSString* IFExpressionDidChangeContext = @"IFExpressionDidChangeContext";

- (id)init;
{
  if (![super initWithViewNibName:@"IFThumbnailView"])
    return nil;
  evaluator = nil;
  cursors = nil;
  expression = nil;
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(expression);
  OBJC_RELEASE(cursors);
  OBJC_RELEASE(evaluator);
  [super dealloc];
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
  if (cursors != nil) {
    [[cursors editMark] removeObserver:self forKeyPath:@"node.expression"];
    [cursors release];
  }
  if (newCursors != nil) {
    [[newCursors editMark] addObserver:self forKeyPath:@"node.expression" options:0 context:IFExpressionDidChangeContext];
    [newCursors retain];
  }
  cursors = newCursors;
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  if (context == IFExpressionDidChangeContext) {
    [self updateExpression];
  } else
    NSAssert1(NO, @"unexpected context %@", context);
}

@end

@implementation IFThumbnailViewController (Private)

- (void)setExpression:(IFExpression*)newExpression;
{
  if (newExpression == expression)
    return;
  
  NSRect dirtyRect = (expression == nil || newExpression == nil)
    ? NSRectInfinite()
    : [evaluator deltaFromOld:expression toNew:newExpression];
  
  [expression release];
  expression = [newExpression retain];
  
  IFConstantExpression* evaluatedExpr = [evaluator evaluateExpressionAsImage:expression];
  if ([evaluatedExpr isError])
    [imageView setImage:nil dirtyRect:NSRectInfinite()];
  else
    [imageView setImage:[(IFImageConstantExpression*)evaluatedExpr image] dirtyRect:dirtyRect];
}

- (void)updateExpression;
{
  IFExpression* expr = [[[cursors editMark] node] expression];
  [self setExpression:(expr == nil
                       ? nil
                       : [IFOperatorExpression resample:expr by:(1.0/thumbnailFactor)])];  
}

// TODO
//- (void)mainImageViewDidScroll:(NSNotification*)notification;
//{
//  NSPoint o = [imageView visibleRect].origin;
//  [(NSClipView*)[thumbnailView superview] scrollToPoint:NSMakePoint(o.x / thumbnailFactor,o.y / thumbnailFactor)];
//}

@end
