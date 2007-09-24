//
//  IFTreeNodeAlias.m
//  ImageFlow
//
//  Created by Michel Schinz on 22.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFTreeNodeAlias.h"
#import "IFXMLCoder.h"

@implementation IFTreeNodeAlias

static NSString* IFOriginalExpressionChangedContext = @"IFOriginalExpressionChangedContext";

+ (id)nodeAliasWithOriginal:(IFTreeNode*)theOriginal;
{
  return [[[self alloc] initWithOriginal:theOriginal] autorelease];
}

- (id)initWithOriginal:(IFTreeNode*)theOriginal;
{
  if (![super init])
    return nil;
  IFTreeNode* realOriginal = theOriginal;
  while ([realOriginal isAlias])
    realOriginal = [(IFTreeNodeAlias*)realOriginal original];
  original = [realOriginal retain];
  [original addObserver:self forKeyPath:@"expression" options:0 context:IFOriginalExpressionChangedContext];
  return self;
}

- (void)dealloc;
{
  [original removeObserver:self forKeyPath:@"expression"];
  OBJC_RELEASE(original);
  [super dealloc];
}

- (IFTreeNode*)cloneNode;
{
  return [IFTreeNodeAlias nodeAliasWithOriginal:original];
}

- (BOOL)isAlias;
{
  return YES;
}

- (void)insertObject:(IFTreeNode*)parent inParentsAtIndex:(unsigned int)index;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (void)removeObjectFromParentsAtIndex:(unsigned int)index;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (void)replaceObjectInParentsAtIndex:(unsigned int)index withObject:(IFTreeNode*)newParent;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (IFTreeNode*)original;
{
  return original;
}

- (IFFilter*)filter;
{
  return [original filter];
}

- (int)inputArity
{
  return 0;
}

- (NSArray*)potentialTypes;
{
  NSArray* originalPTs = [original potentialTypes];
  NSMutableArray* potentialTypes = [NSMutableArray array];
  for (int i = 0, count = [originalPTs count]; i < count; ++i) {
    IFType* limitedType = [[originalPTs objectAtIndex:i] typeByLimitingArityTo:0];
    if (![potentialTypes containsObject:limitedType])
      [potentialTypes addObject:limitedType];
  }
  return potentialTypes;
}

#pragma mark Tree view support

- (NSString*)nameOfParentAtIndex:(int)index;
{
  return [original nameOfParentAtIndex:index];
}

- (NSString*)label;
{
  return [original label];
}

- (NSString*)toolTip;
{
  return [original toolTip];
}

#pragma mark Image view support

- (NSArray*)editingAnnotationsForView:(NSView*)view;
{
  return [original editingAnnotationsForView:view];
}

- (void)mouseDown:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
{
  return [original mouseDown:event inView:imageView viewFilterTransform:viewFilterTransform];
}

- (void)mouseDragged:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
{
  return [original mouseDragged:event inView:imageView viewFilterTransform:viewFilterTransform];
}

- (void)mouseUp:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
{
  return [original mouseUp:event inView:imageView viewFilterTransform:viewFilterTransform];
}

- (NSArray*)variantNamesForViewing;
{
  return [original variantNamesForViewing];
}

- (NSArray*)variantNamesForEditing;
{
  return [original variantNamesForEditing];
}

- (IFExpression*)variantNamed:(NSString*)variantName ofExpression:(IFExpression*)originalExpression;
{
  return [original variantNamed:variantName ofExpression:originalExpression];
}

#pragma mark -
#pragma mark (protected)

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  if (context == IFOriginalExpressionChangedContext)
    [self updateExpression];
}

- (void)updateExpression;
{
  [self setExpression:[original expression]];
}

@end
