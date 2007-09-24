//
//  IFBlendFilterAnnotationSource.m
//  ImageFlow
//
//  Created by Michel Schinz on 18.09.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFBlendFilterAnnotationSource.h"
#import "IFExpressionEvaluator.h"
#import "IFDocument.h"

static NSString* IFExpressionChangedContext = @"IFExpressionChangedContext";

@interface IFBlendFilterAnnotationSource (Private)
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
  [[[node filter] environment] setValue:[NSValue valueWithPoint:newTranslation] forKey:@"translation"];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  NSAssert(context == IFExpressionChangedContext, @"unexpected context");
  [super setValue:[NSValue valueWithRect:[self rect]]];
}

@end

@implementation IFBlendFilterAnnotationSource (Private)

- (NSRect)foregroundExtent;
{
  IFExpression* expression = [node expression];
  if (![expression isKindOfClass:[IFOperatorExpression class]])
    return NSZeroRect;
  
  IFExpressionEvaluator* evaluator = [(IFDocument*)[[[[NSApplication sharedApplication] mainWindow] windowController] document] evaluator];
  IFOperatorExpression* blendExpression = (IFOperatorExpression*)expression;
  NSAssert([blendExpression isKindOfClass:[IFOperatorExpression class]]
           && [blendExpression operator]  == [IFOperator operatorForName:@"blend"], @"unexpected operator");
    
  IFOperatorExpression* translateExpression = (IFOperatorExpression*)[[blendExpression operands] objectAtIndex:1];
  NSAssert([translateExpression isKindOfClass:[IFOperatorExpression class]]
           && [translateExpression operator]  == [IFOperator operatorForName:@"translate"], @"unexpected operator");
    
  IFConstantExpression* evaluatedExtent = [evaluator evaluateExpression:[IFOperatorExpression extentOf:[[translateExpression operands] objectAtIndex:0]]];
  
  return [evaluatedExtent isError] ? NSZeroRect : [evaluatedExtent rectValueNS];
}

- (NSRect)rect;
{
  NSPoint translation = [[[[node filter] environment] valueForKey:@"translation"] pointValue];
  return NSOffsetRect([self foregroundExtent],translation.x,translation.y);
}

@end
