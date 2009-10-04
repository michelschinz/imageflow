//
//  IFFileSink.m
//  ImageFlow
//
//  Created by Michel Schinz on 03.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFFileSink.h"
#import "IFDocument.h"
#import "IFType.h"
#import "IFExpression.h"

@implementation IFFileSink

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 1)
    return [NSArray arrayWithObject:[IFType funTypeWithArgumentType:[IFType imageRGBAType] returnType:[IFType actionType]]];
  else
    return [NSArray array];
}

- (IFExpression*)potentialRawExpressionsForArity:(unsigned)arity typeIndex:(unsigned)typeIndex;
{
  NSAssert(arity == 1 && typeIndex == 0, @"invalid arity or type index");
  return [IFExpression lambdaWithBody:[IFExpression primitiveWithTag:IFPrimitiveTag_Save operands:nil]];
}

- (NSString*)exporterKind;
{
  return @"file";
}

// TODO: write export code

- (NSString*)computeLabel;
{
  return [NSString stringWithFormat:@"save %@",[[settings valueForKey:@"fileName"] lastPathComponent]];
}

- (NSString*)toolTip;
{
  return [NSString stringWithFormat:@"save %@",[settings valueForKey:@"fileName"]];
}

@end
