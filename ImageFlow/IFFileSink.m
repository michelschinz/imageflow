//
//  IFFileSink.m
//  ImageFlow
//
//  Created by Michel Schinz on 03.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFFileSink.h"
#import "IFDocument.h"
#import "IFFunType.h"
#import "IFBasicType.h"
#import "IFImageType.h"
#import "IFOperatorExpression.h"

@implementation IFFileSink

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 1)
    return [NSArray arrayWithObject:
            [IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObject:[IFImageType imageRGBAType]]
                                     returnType:[IFBasicType actionType]]];
  else
    return [NSArray array];
}

- (NSArray*)potentialRawExpressionsForArity:(unsigned)arity;
{
  static NSArray* exprs = nil;
  if (exprs == nil) {
    exprs = [[NSArray arrayWithObject:[IFOperatorExpression expressionWithOperatorNamed:@"save" operands:nil]] retain];
  }
  return (arity == 1) ? exprs : [NSArray array];
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
