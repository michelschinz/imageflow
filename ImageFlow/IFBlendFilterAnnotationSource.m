//
//  IFBlendFilterAnnotationSource.m
//  ImageFlow
//
//  Created by Michel Schinz on 18.09.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFDocument.h"
#import "IFBlendFilterAnnotationSource.h"
#import "IFExpressionEvaluator.h"
#import "IFPrimitiveExpression.h"

static NSString* IFExpressionChangedContext = @"IFExpressionChangedContext";

@interface IFBlendFilterAnnotationSource ()
- (NSRect)foregroundExtent;
- (NSRect)rect;
@end

@implementation IFBlendFilterAnnotationSource

+ (id)blendAnnotationSourceForNode:(IFTreeNode*)theNode;
{
  return [[[self alloc] initWithNode:theNode] autorelease];
}

- (id)initWithNode:(IFTreeNode*)theNode;
{
  if (![super init])
    return nil;
  node = [theNode retain];
  [super setValue:[NSValue valueWithRect:[self rect]]];
  [node addObserver:self forKeyPath:@"expression" options:0 context:IFExpressionChangedContext];
  return self;
}

- (void)dealloc;
{
  [node removeObserver:self forKeyPath:@"expression"];
  OBJC_RELEASE(node);
  [super dealloc];
}

- (void)setValue:(id)newValue;
{
  NSPoint newOrigin = [(NSValue*)newValue rectValue].origin;
  NSPoint fgOrigin = [self foregroundExtent].origin;
  NSPoint newTranslation = NSMakePoint(newOrigin.x - fgOrigin.x,newOrigin.y - fgOrigin.y);
  [[node settings] setValue:[NSValue valueWithPoint:newTranslation] forKey:@"translation"];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  NSAssert(context == IFExpressionChangedContext, @"unexpected context");
  [super setValue:[NSValue valueWithRect:[self rect]]];
}

// MARK: -
// MARK: PRIVATE

- (NSRect)foregroundExtent;
{
  // FIXME: redo now that there are lambdas here...
  IFExpression* expression = [node expression];
  if (![expression isKindOfClass:[IFPrimitiveExpression class]])
    return NSZeroRect;
  
  IFExpressionEvaluator* evaluator = [IFExpressionEvaluator sharedEvaluator];
  IFPrimitiveExpression* blendExpression = (IFPrimitiveExpression*)expression;
  NSAssert([blendExpression isKindOfClass:[IFPrimitiveExpression class]] && blendExpression.tag == IFPrimitiveTag_Blend, @"unexpected operator");

  IFPrimitiveExpression* translateExpression = (IFPrimitiveExpression*)[[blendExpression operands] objectAtIndex:1];
  NSAssert([translateExpression isKindOfClass:[IFPrimitiveExpression class]] && translateExpression.tag  == IFPrimitiveTag_Translate, @"unexpected operator");

  IFConstantExpression* evaluatedExtent = [evaluator evaluateExpression:[IFExpression extentOf:[[translateExpression operands] objectAtIndex:0]]];
  
  return [evaluatedExtent isError] ? NSZeroRect : [evaluatedExtent rectValueNS];
}

- (NSRect)rect;
{
  NSPoint translation = [[[node settings] valueForKey:@"translation"] pointValue];
  return NSOffsetRect([self foregroundExtent],translation.x,translation.y);
}

@end
