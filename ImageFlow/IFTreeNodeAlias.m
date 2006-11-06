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
  if (![super initWithFilter:[theOriginal filter]])
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

- (BOOL)acceptsParents:(int)inputCount;
{
  return (inputCount == 0);
}

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
