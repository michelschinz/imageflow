//
//  IFTreeNodeAlias.m
//  ImageFlow
//
//  Created by Michel Schinz on 22.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFTreeNodeAlias.h"
#import "IFXMLCoder.h"
#import "IFType.h"

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

- (BOOL)isAlias;
{
  return YES;
}

- (IFTreeNode*)original;
{
  return original;
}

- (int)inputArity
{
  return 0;
}

// MARK: Tree view support

- (NSString*)nameOfParentAtIndex:(int)index;
{
  return [original nameOfParentAtIndex:index];
}

- (NSString*)toolTip;
{
  return [original toolTip];
}

// MARK: Image view support

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

// MARK: NSCoding protocol

- (id)initWithCoder:(NSCoder*)decoder;
{
  [super initWithCoder:decoder];
  original = [[decoder decodeObjectForKey:@"original"] retain];
  [original addObserver:self forKeyPath:@"expression" options:0 context:IFOriginalExpressionChangedContext];
  return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder;
{
  [super encodeWithCoder:encoder];
  [encoder encodeObject:original forKey:@"original"];
}

// MARK: -
// MARK: PROTECTED

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  NSAssert(context == IFOriginalExpressionChangedContext, @"unexpected context");
  [self updateLabel];
  [self updateExpression];
}

- (NSString*)computeLabel;
{
  return original.label;
}

- (IFExpression*)computeExpression;
{
  return original.expression;
}

@end
