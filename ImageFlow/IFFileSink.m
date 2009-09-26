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
#import "IFExpression.h"

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
  if (arity == 1) {
    return [NSArray arrayWithObject:[IFExpression lambdaWithBody:[IFExpression primitiveWithTag:IFPrimitiveTag_Save operands:nil]]];
  } else {
    return [NSArray array];
  }
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
