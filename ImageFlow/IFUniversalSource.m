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
#import "IFOperatorExpression.h"

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

- (NSArray*)potentialTypesForArity:(unsigned)arity;
{
  static NSArray* types = nil;
  if (types == nil)
    types = [[NSArray arrayWithObjects:
              [IFImageType imageRGBAType],
              [IFImageType maskType],
              [IFArrayType arrayTypeWithContentType:[IFImageType imageRGBAType]],
              [IFArrayType arrayTypeWithContentType:[IFImageType maskType]],
              nil] retain];
  return (arity == 0) ? types : [NSArray array];
}

- (NSArray*)potentialRawExpressionsForArity:(unsigned)arity;
{
  if (arity == 0) {
    // TODO: use better images for masks and stacks
    unsigned fileNameIndex = [[settings valueForKey:@"index"] unsignedIntValue];
    NSString* fileName = [sourceFileNames objectAtIndex:(fileNameIndex % [sourceFileNames count])];
  
    IFExpression* rgbaImageExpression = [IFOperatorExpression expressionWithOperatorNamed:@"load" operands:
                                         [IFConstantExpression expressionWithString:fileName],
                                         [IFConstantExpression expressionWithInt:YES],
                                         [IFConstantExpression expressionWithString:@""],
                                         [IFConstantExpression expressionWithString:@""],
                                         [IFConstantExpression expressionWithString:@""],
                                         [IFConstantExpression expressionWithInt:NO],
                                         [IFConstantExpression expressionWithInt:YES],
                                         [IFConstantExpression expressionWithInt:1],
                                         [IFConstantExpression expressionWithInt:1],
                                         nil];
    
    IFExpression* maskImageExpression = [IFOperatorExpression expressionWithOperatorNamed:@"channel-to-mask" operands:rgbaImageExpression, [IFConstantExpression expressionWithInt:4], nil];
    
    return [NSArray arrayWithObjects:
            rgbaImageExpression,
            maskImageExpression,
            [IFOperatorExpression expressionWithOperatorNamed:@"array" operands:rgbaImageExpression, rgbaImageExpression, nil],
            [IFOperatorExpression expressionWithOperatorNamed:@"array" operands:maskImageExpression, maskImageExpression, nil],
            nil];
  } else
    return [NSArray array];
}

@end
