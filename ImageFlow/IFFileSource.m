//
//  IFFileSource.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFFileSource.h"

#import "IFEnvironment.h"
#import "IFType.h"
#import "IFExpression.h"

@implementation IFFileSource

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 0)
    return [NSArray arrayWithObject:[IFType imageRGBAType]];
  else
    return [NSArray array];
}

- (IFExpression*)potentialRawExpressionsForArity:(unsigned)arity typeIndex:(unsigned)typeIndex;
{
  NSAssert(arity == 0 && typeIndex == 0, @"invalid arity or type index");
  return [IFExpression primitiveWithTag:IFPrimitiveTag_Load operand:[IFConstantExpression expressionWithString:[settings valueForKey:@"fileName"]]];
}

- (NSString*)computeLabel;
{
  return [NSString stringWithFormat:@"load %@",[[settings valueForKey:@"fileName"] lastPathComponent]];
}

- (NSString*)toolTip;
{
  return [NSString stringWithFormat:@"load %@",[settings valueForKey:@"fileName"]];
}

@end
