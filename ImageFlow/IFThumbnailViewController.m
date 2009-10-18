//
//  IFThumbnailViewController.m
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFThumbnailViewController.h"

#import "IFExpression.h"

@interface IFThumbnailViewController (Private)
- (void)updateExpression;
@end

@implementation IFThumbnailViewController

const float thumbnailFactor = 4.0;

static NSString* IFExpressionDidChangeContext = @"IFExpressionDidChangeContext";

- (id)init;
{
  if (![super initWithNibName:@"IFThumbnailView" bundle:nil])
    return nil;
  cursors = nil;
  expression = nil;
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(expression);
  OBJC_RELEASE(cursors);
  [super dealloc];
}

- (void)setCursorPair:(IFTreeCursorPair*)newCursors;
{
  if (cursors != nil) {
    [cursors removeObserver:self forKeyPath:@"node.expression"];
    [cursors release];
  }
  if (newCursors != nil) {
    [newCursors addObserver:self forKeyPath:@"node.expression" options:0 context:IFExpressionDidChangeContext];
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

//  IFExpressionEvaluator* evaluator = [IFExpressionEvaluator sharedEvaluator];
//  NSRect dirtyRect = (expression == nil || newExpression == nil)
//    ? NSRectInfinite()
//    : [evaluator deltaFromOld:expression toNew:newExpression];
//  
//  [expression release];
//  expression = [newExpression retain];
//  
//  IFConstantExpression* evaluatedExpr = [evaluator evaluateExpressionAsImage:expression];
//  if ([evaluatedExpr isError])
//    [imageView setImage:nil dirtyRect:NSRectInfinite()];
//  else
//    [imageView setImage:[(IFImageConstantExpression*)evaluatedExpr image] dirtyRect:dirtyRect];
}

- (void)updateExpression;
{
  IFExpression* expr = cursors.node.expression;
  [self setExpression:(expr == nil
                       ? nil
                       : [IFExpression resample:expr by:(1.0/thumbnailFactor)])];  
}

// TODO
//- (void)mainImageViewDidScroll:(NSNotification*)notification;
//{
//  NSPoint o = [imageView visibleRect].origin;
//  [(NSClipView*)[thumbnailView superview] scrollToPoint:NSMakePoint(o.x / thumbnailFactor,o.y / thumbnailFactor)];
//}

@end
