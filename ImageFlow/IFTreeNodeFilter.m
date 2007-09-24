//
//  IFTreeNodeFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 22.09.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFTreeNodeFilter.h"
#import "IFExpressionPlugger.h"

@implementation IFTreeNodeFilter

static NSString* IFFilterExpressionChangedContext = @"IFFilterExpressionChangedContext";

+ (id)nodeWithFilter:(IFFilter*)theFilter;
{
  return [[[IFTreeNodeFilter alloc] initWithFilter:theFilter] autorelease];
}

- (id)initWithFilter:(IFFilter*)theFilter;
{
  if (![super init]) return nil;
  filter = [theFilter retain];
  [filter addObserver:self forKeyPath:@"expression" options:0 context:IFFilterExpressionChangedContext];
  return self;
}

- (void)dealloc;
{
  [filter removeObserver:self forKeyPath:@"expression"];  
  OBJC_RELEASE(filter);
  [super dealloc];
}

- (IFTreeNode*)cloneNode;
{
  NSAssert([self class] == [IFTreeNodeFilter class], @"missing redefiniton of <clone> method");
  return [IFTreeNodeFilter nodeWithFilter:[filter clone]];
}

- (BOOL)isGhost;
{
  return [filter isGhost];
}

- (IFFilter*)filter;
{
  return filter;
}

- (NSArray*)potentialTypes;
{
  return [filter potentialTypes];
}

- (void)beginReconfiguration;
{
  NSAssert(!inReconfiguration, @"already in reconfiguration");
  inReconfiguration = YES;
}

- (void)endReconfigurationWithActiveTypeIndex:(int)typeIndex;
{
  NSAssert(inReconfiguration, @"not in reconfiguration");
  [filter setActiveTypeIndex:typeIndex];
  inReconfiguration = NO;
}

- (void)updateExpression;
{
  if (filter == nil)
    return;
  NSMutableDictionary* parentEnv = [NSMutableDictionary dictionary];
  for (int i = 0; i < [parents count]; ++i)
    [parentEnv setObject:[[parents objectAtIndex:i] expression] forKey:[NSNumber numberWithInt:i]];
  [self setExpression:[IFExpressionPlugger plugValuesInExpression:[filter expression] withValuesFromParentsEnvironment:parentEnv]];
}

#pragma mark Tree view support

- (NSString*)nameOfParentAtIndex:(int)index;
{
  return [filter nameOfParentAtIndex:index];
}

- (NSString*)label;
{
  return [filter label];
}

- (NSString*)toolTip;
{
  return [filter toolTip];
}

#pragma mark Image view support

- (NSArray*)editingAnnotationsForView:(NSView*)view;
{
  return [filter editingAnnotationsForNode:self view:view];
}

- (void)mouseDown:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
{
  return [filter mouseDown:event inView:imageView viewFilterTransform:viewFilterTransform];
}

- (void)mouseDragged:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
{
  return [filter mouseDragged:event inView:imageView viewFilterTransform:viewFilterTransform];
}

- (void)mouseUp:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
{
  return [filter mouseUp:event inView:imageView viewFilterTransform:viewFilterTransform];
}

- (NSArray*)variantNamesForViewing;
{
  return [filter variantNamesForViewing];
}

- (NSArray*)variantNamesForEditing;
{
  return [filter variantNamesForEditing];
}

- (IFExpression*)variantNamed:(NSString*)variantName ofExpression:(IFExpression*)originalExpression;
{
  return [filter variantNamed:variantName ofExpression:originalExpression];
}

- (NSAffineTransform*)transformForParentAtIndex:(int)index;
{
  return [filter transformForParentAtIndex:index];
}

#pragma mark -
#pragma mark (protected)

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  if (context == IFFilterExpressionChangedContext)
    [self updateExpression];
  else {
    if (!inReconfiguration)
      [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

@end
