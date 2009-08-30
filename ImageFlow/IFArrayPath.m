//
//  IFArrayPath.m
//  ImageFlow
//
//  Created by Michel Schinz on 29.08.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import "IFArrayPath.h"

#import "IFOperatorExpression.h"
#import "IFArrayType.h"

@interface IFArrayPath ()
- (IFArrayPath*)reversedOn:(IFArrayPath*)tail;
@end

static IFArrayPath* emptyPath = nil;

@implementation IFArrayPath

+ (void)initialize;
{
  if (self != [IFArrayPath class])
    return; // avoid repeated initialisation
  emptyPath = [[IFArrayPath alloc] initWithIndex:~0 next:nil];
}

+ (IFArrayPath*)emptyPath;
{
  return emptyPath;
}

+ (IFArrayPath*)leftmostPathForType:(IFType*)type;
{
  return [type isArrayType] ? [self pathElementWithIndex:0 next:[self leftmostPathForType:[(IFArrayType*)type contentType]]] : emptyPath;
}

+ (IFArrayPath*)pathElementWithIndex:(unsigned)theIndex next:(IFArrayPath*)theNext;
{
  return [[[self alloc] initWithIndex:theIndex next:theNext] autorelease];
}

- (IFArrayPath*)initWithIndex:(unsigned)theIndex next:(IFArrayPath*)theNext;
{
  if (![super init])
    return nil;
  index = theIndex;
  next = [theNext retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(next);
  [super dealloc];
}

@synthesize index, next;

- (IFArrayPath*)reversed;
{
  return [self reversedOn:emptyPath];
}

- (IFExpression*)accessorExpressionFor:(IFExpression*)arrayExpression;
{
  if (self == emptyPath)
    return arrayExpression;
  else
    return [IFOperatorExpression arrayGet:[next accessorExpressionFor:arrayExpression] index:index];
}

- (NSString*)description;
{
  if (self == emptyPath)
    return @"nil";
  else
    return [NSString stringWithFormat:@"%d:%@", index, [next description]];
}

// MARK: -
// MARK: PRIVATE

- (IFArrayPath*)reversedOn:(IFArrayPath*)tail;
{
  if (self == emptyPath)
    return tail;
  else
    return [next reversedOn:[IFArrayPath pathElementWithIndex:index next:tail]];
}

@end
