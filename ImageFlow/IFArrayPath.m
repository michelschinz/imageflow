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

- (BOOL)isEmpty;
{
  return self == emptyPath;
}

@synthesize index, next;

- (IFArrayPath*)reversed;
{
  return [self reversedOn:emptyPath];
}

- (IFExpression*)accessorExpressionFor:(IFExpression*)arrayExpression;
{
  if (self.isEmpty)
    return arrayExpression;
  else
    return [IFOperatorExpression arrayGet:[next accessorExpressionFor:arrayExpression] index:index];
}

- (NSUInteger)hash;
{
  return self.isEmpty ? 7 : (index ^ [next hash] << 3);
}

- (BOOL)isEqual:(id)otherO;
{
  if (self.isEmpty)
    return otherO == emptyPath;
  else if ([otherO isKindOfClass:[IFArrayPath class]]) {
    IFArrayPath* other = (IFArrayPath*)otherO;
    return (index == other.index) && [next isEqual:other.next];
  } else
    return NO;
}

- (NSString*)description;
{
  if (self.isEmpty)
    return @"nil";
  else
    return [NSString stringWithFormat:@"%d:%@", index, [next description]];
}

// MARK: -
// MARK: PRIVATE

- (IFArrayPath*)reversedOn:(IFArrayPath*)tail;
{
  if (self.isEmpty)
    return tail;
  else
    return [next reversedOn:[IFArrayPath pathElementWithIndex:index next:tail]];
}

@end
