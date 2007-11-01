//
//  IFTreeNode.m
//  ImageFlow
//
//  Created by Michel Schinz on 20.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFTreeNode.h"
#import "IFTreeNodeFilter.h"
#import "IFExpressionPlugger.h"
#import "IFTreeMark.h"

@implementation IFTreeNode

+ (id)ghostNodeWithInputArity:(int)inputArity;
{
  IFEnvironment* env = [IFEnvironment environment];
  [env setValue:[NSNumber numberWithInt:inputArity] forKey:@"inputArity"];
  return [IFTreeNodeFilter nodeWithFilter:[IFFilter filterWithName:@"IFGhostFilter" environment:env]];
}

- (id)init;
{
  if (![super init]) return nil;
  name = nil;
  isFolded = NO;
  updateExpression = NO;
  expression = nil;
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(expression);
  OBJC_RELEASE(name);
  [super dealloc];
}

- (IFTreeNode*)cloneNode;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

#pragma mark Attributes

- (void)setName:(NSString*)newName;
{
  if (name == newName)
    return;
  [name release];
  name = [newName retain];
}

- (NSString*)name;
{
  return name;
}

- (void)setIsFolded:(BOOL)newIsFolded;
{
  isFolded = newIsFolded;
}

- (BOOL)isFolded;
{
  return isFolded;
}

- (BOOL)isGhost;
{
  return NO;
}

- (BOOL)isAlias;
{
  return NO;
}

- (IFTreeNode*)original;
{
  return self;
}

- (IFFilter*)filter;
{
  return nil;
}

- (IFExpression*)expression;
{
  if (expression == nil)
    [self updateExpression];
  return expression;
}

- (NSArray*)potentialTypes;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (void)stopUpdatingExpression;
{
  updateExpression = NO;
}

- (void)startUpdatingExpression;
{
  updateExpression = YES;
  [self maybeUpdateExpression];
}

- (void)setActiveTypeIndex:(unsigned)newIndex;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (void)setParentExpression:(IFExpression*)expression atIndex:(unsigned)index;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (int)inputArity;
{
  return [[[self potentialTypes] objectAtIndex:0] arity];
}

- (int)outputArity;
{
  // TODO
  return 1;
}

#pragma mark Tree view support

- (NSString*)nameOfParentAtIndex:(int)index;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (NSString*)label;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (NSString*)toolTip;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

#pragma mark Image view support

- (NSArray*)editingAnnotationsForView:(NSView*)view;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (void)mouseDown:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (void)mouseDragged:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (void)mouseUp:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (NSArray*)variantNamesForViewing;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (NSArray*)variantNamesForEditing;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (IFExpression*)variantNamed:(NSString*)variantName ofExpression:(IFExpression*)originalExpression;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (NSAffineTransform*)transformForParentAtIndex:(int)index;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

#pragma mark -
#pragma mark (protected)

- (void)maybeUpdateExpression;
{
  if (updateExpression)
    [self updateExpression];
}

- (void)updateExpression;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (void)setExpression:(IFExpression*)newExpression;
{
  if (newExpression == expression)
    return;
  [expression release];
  expression = [newExpression retain];
}

@end
