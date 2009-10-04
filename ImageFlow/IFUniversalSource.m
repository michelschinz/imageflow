//
//  IFUniversalSource.m
//  ImageFlow
//
//  Created by Michel Schinz on 23.11.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFUniversalSource.h"
#import "IFType.h"
#import "IFExpression.h"

static NSArray* sourceFileNames;

@implementation IFUniversalSource

+ (void)initialize;
{
  if (self != [IFUniversalSource class])
    return; // avoid repeated initialisation

  NSMutableArray* fileNames = [NSMutableArray array];
  for (int i = 1; /*no condition*/; ++i) {
    NSString* maybePath = [[NSBundle mainBundle] pathForImageResource:[NSString stringWithFormat:@"surrogate_parent_%d",i]];
    if (maybePath == nil)
      break;
    [fileNames addObject:maybePath];
  }

  sourceFileNames = [fileNames retain];
}

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 0)
    return [NSArray arrayWithObjects:
            [IFType imageRGBAType],
            [IFType maskType],
            [IFType arrayTypeWithContentType:[IFType imageRGBAType]],
            [IFType arrayTypeWithContentType:[IFType maskType]],
            nil];
  else
    return [NSArray array];
}

- (IFExpression*)potentialRawExpressionsForArity:(unsigned)arity typeIndex:(unsigned)typeIndex;
{
  NSAssert(arity == 0 && typeIndex <= 3, @"invalid arity or type index");
  
  // TODO: use better images for masks and stacks
  unsigned fileNameIndex = [[settings valueForKey:@"index"] unsignedIntValue];
  NSString* fileName = [sourceFileNames objectAtIndex:(fileNameIndex % [sourceFileNames count])];
  
  IFExpression* rgbaImageExpression = [IFExpression primitiveWithTag:IFPrimitiveTag_Load operand:[IFConstantExpression expressionWithString:fileName]];
  IFExpression* maskImageExpression = [IFExpression primitiveWithTag:IFPrimitiveTag_ChannelToMask operands:rgbaImageExpression, [IFConstantExpression expressionWithInt:4], nil];
  
  switch (typeIndex) {
    case 0:
      return rgbaImageExpression;
    case 1:
      return maskImageExpression;
    case 2:
      return [IFExpression primitiveWithTag:IFPrimitiveTag_ArrayCreate operands:rgbaImageExpression, rgbaImageExpression, nil];
    case 3:
      return [IFExpression primitiveWithTag:IFPrimitiveTag_ArrayCreate operands:maskImageExpression, maskImageExpression, nil];
  }
}

@end
