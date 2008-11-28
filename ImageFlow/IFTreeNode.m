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
#import "IFType.h"

@interface IFTreeNode (Private)
- (id)initWithName:(NSString*)theName isFolded:(BOOL)theIsFolded;
@property(retain) NSString* label;
@property(retain) IFExpression* expression;
@end

@implementation IFTreeNode

+ (IFTreeNode*)ghostNode;
{
  return [IFTreeNodeFilter nodeWithFilterNamed:@"IFGhostFilter" settings:[IFEnvironment environment]];
}

+ (IFTreeNode*)universalSourceWithIndex:(unsigned)index;
{
  IFEnvironment* env = [IFEnvironment environment];
  [env setValue:[NSNumber numberWithUnsignedInt:index] forKey:@"index"];
  return [IFTreeNodeFilter nodeWithFilterNamed:@"IFUniversalSource" settings:env];
}

- (id)init;
{
  return [self initWithName:nil isFolded:NO];
}

- (void)dealloc;
{
  OBJC_RELEASE(expression);
  OBJC_RELEASE(name);
  [super dealloc];
}

// MARK: Properties

@synthesize name;
@synthesize isFolded;

- (BOOL)isGhost;
{
  return NO;
}

- (BOOL)isAlias;
{
  return NO;
}

- (BOOL)isHole;
{
  return NO;
}

- (IFTreeNode*)original;
{
  return self;
}

- (IFEnvironment*)settings;
{
  return [IFEnvironment environment];
}

- (IFExpression*)expression;
{
  if (expression == nil)
    [self updateExpression];
  return expression;
}

- (IFExpression*)expressionForSettings:(IFEnvironment*)altSettings parentExpressions:(NSDictionary*)altParentExpressions activeTypeIndex:(unsigned)altActiveTypeIndex;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (NSArray*)potentialTypesForArity:(unsigned)arity;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (void)setParentExpression:(IFExpression*)expression atIndex:(unsigned)index;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (void)setParentExpressions:(NSDictionary*)expressions activeTypeIndex:(unsigned)newActiveTypeIndex;
{
  [self doesNotRecognizeSelector:_cmd];
}

// MARK: Tree view support

- (NSString*)nameOfParentAtIndex:(int)index;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (NSString*)label;
{
  if (label == nil)
    [self updateLabel];
  return label;
}

- (NSString*)toolTip;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

// MARK: Image view support

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

// MARK: NSCoding protocol

- (id)initWithCoder:(NSCoder*)decoder;
{
  return [self initWithName:[decoder decodeObjectForKey:@"name"] isFolded:[decoder decodeBoolForKey:@"isFolded"]];
}

- (void)encodeWithCoder:(NSCoder*)encoder;
{
  [encoder encodeObject:name forKey:@"name"];
  [encoder encodeBool:isFolded forKey:@"isFolded"];
}

// MARK: (protected)

- (void)updateLabel;
{
  self.label = [self computeLabel];
}

- (NSString*)computeLabel;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (void)updateExpression;
{
  self.expression = [self computeExpression];
}

- (IFExpression*)computeExpression;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

@end

@implementation IFTreeNode (Private)

- (void)setLabel:(NSString*)newLabel;
{
  if (newLabel == label)
    return;
  [label release];
  label = [newLabel retain];
}

- (void)setExpression:(IFExpression*)newExpression;
{
  if (newExpression == expression)
    return;
  [expression release];
  expression = [newExpression retain];
}

- (id)initWithName:(NSString*)theName isFolded:(BOOL)theIsFolded;
{
  if (![super init])
    return nil;
  name = (theName == nil) ? nil : [theName retain];
  isFolded = theIsFolded;
  expression = nil;
  return self;
}

@end
