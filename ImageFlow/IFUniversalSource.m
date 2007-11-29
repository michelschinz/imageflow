//
//  IFUniversalSource.m
//  ImageFlow
//
//  Created by Michel Schinz on 23.11.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFUniversalSource.h"
#import "IFImageType.h"
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

- (NSArray*)potentialTypes;
{
  static NSArray* types = nil;
  if (types == nil)
    types = [[NSArray arrayWithObjects:[IFImageType imageRGBAType],[IFImageType maskType],nil] retain];
  return types;
}

- (NSArray*)potentialRawExpressions;
{
  // TODO use better images for masks
  unsigned fileNameIndex = [[settings valueForKey:@"index"] unsignedIntValue];
  NSString* fileName = [sourceFileNames objectAtIndex:(fileNameIndex % [sourceFileNames count])];
  
  IFExpression* loadExpression = [IFOperatorExpression expressionWithOperatorNamed:@"load" operands:
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
  
  return [NSArray arrayWithObjects:
    loadExpression,
    [IFOperatorExpression expressionWithOperatorNamed:@"channel-to-mask" operands:
      loadExpression,
      [IFConstantExpression expressionWithInt:4],
      nil],
    nil];
}

@end
