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

- (IFExpression*)rawExpressionForArity:(unsigned)arity typeIndex:(unsigned)typeIndex;
{
  NSAssert(arity == 1 && typeIndex == 0, @"invalid arity or type index");
  // TODO: use correct export rect (either canvas or explicit value from environment).
  return [IFExpression lambdaWithBody:
          [IFExpression primitiveWithTag:IFPrimitiveTag_PExportActionCreate operands:[IFConstantExpression expressionWithString:[[settings valueForKey:@"fileURL"] absoluteString]], [IFExpression argumentWithIndex:0], [IFConstantExpression expressionWithRectCG:CGRectMake(0, 0, 800, 600)], nil]];
}

- (NSString*)computeLabel;
{
  return [NSString stringWithFormat:@"%C%@", 0x2191, [[settings valueForKey:@"fileURL"] lastPathComponent]];
}

- (NSString*)toolTip;
{
  return [NSString stringWithFormat:@"export %@",[[settings valueForKey:@"fileURL"] path]];
}

@end
