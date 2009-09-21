//
//  IFGhostFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFGhostFilter.h"

#import "IFEnvironment.h"
#import "IFFunType.h"
#import "IFTypeVar.h"
#import "IFArgumentExpression.h"
#import "IFOperatorExpression.h"
#import "IFLambdaExpression.h"

@implementation IFGhostFilter

- (BOOL)isGhost;
{
  return YES;
}

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 0)
    return [NSArray arrayWithObject:[IFTypeVar typeVar]];
  else {
    NSMutableArray* argTypes = [NSMutableArray arrayWithCapacity:arity];
    for (int i = 1; i <= arity; ++i)
      [argTypes addObject:[IFTypeVar typeVar]];
    return [NSArray arrayWithObject:[IFFunType funTypeWithArgumentTypes:argTypes returnType:[IFTypeVar typeVar]]];
  }
}

- (NSArray*)potentialRawExpressionsForArity:(unsigned)arity;
{
  IFExpression* expr = [IFOperatorExpression fail];
  for (unsigned i = 0; i < arity; ++i)
    expr = [IFLambdaExpression lambdaExpressionWithBody:expr];
  return [NSArray arrayWithObject:expr];
}

- (NSString*)computeLabel;
{
  return @"";
}

@end
