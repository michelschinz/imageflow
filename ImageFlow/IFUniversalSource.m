//
//  IFUniversalSource.m
//  ImageFlow
//
//  Created by Michel Schinz on 23.11.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFUniversalSource.h"
#import "IFImageType.h"
#import "IFArrayType.h"
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
            [IFImageType imageRGBAType],
            [IFImageType maskType],
            [IFArrayType arrayTypeWithContentType:[IFImageType imageRGBAType]],
            [IFArrayType arrayTypeWithContentType:[IFImageType maskType]],
            nil];
  else
    return [NSArray array];
}

- (NSArray*)potentialRawExpressionsForArity:(unsigned)arity;
{
  if (arity == 0) {
    // TODO: use better images for masks and stacks
    unsigned fileNameIndex = [[settings valueForKey:@"index"] unsignedIntValue];
    NSString* fileName = [sourceFileNames objectAtIndex:(fileNameIndex % [sourceFileNames count])];
  
    IFExpression* rgbaImageExpression = [IFExpression primitiveWithTag:IFPrimitiveTag_Load operand:[IFConstantExpression expressionWithString:fileName]];
    IFExpression* maskImageExpression = [IFExpression primitiveWithTag:IFPrimitiveTag_ChannelToMask operands:rgbaImageExpression, [IFConstantExpression expressionWithInt:4], nil];
    
    return [NSArray arrayWithObjects:
            rgbaImageExpression,
            maskImageExpression,
            [IFExpression primitiveWithTag:IFPrimitiveTag_ArrayCreate operands:rgbaImageExpression, rgbaImageExpression, nil],
            [IFExpression primitiveWithTag:IFPrimitiveTag_ArrayCreate operands:maskImageExpression, maskImageExpression, nil],
            nil];
  } else
    return [NSArray array];
}

@end
