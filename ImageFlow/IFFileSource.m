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

- (NSArray*)potentialRawExpressionsForArity:(unsigned)arity;
{
  if (arity == 0) {
    return [NSArray arrayWithObject:
            [IFExpression primitiveWithTag:IFPrimitiveTag_Load operand:[IFConstantExpression expressionWithString:[settings valueForKey:@"fileName"]]]];
  } else {
    return [NSArray array];
  }
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
