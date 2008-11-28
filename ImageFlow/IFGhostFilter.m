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
#import "IFParentExpression.h"
#import "IFOperatorExpression.h"

@implementation IFGhostFilter

- (BOOL)isGhost;
{
  return YES;
}

- (NSArray*)potentialTypesForArity:(unsigned)arity;
{
  if (arity == 0)
    return [NSArray arrayWithObject:[IFTypeVar typeVarWithIndex:0]];
  else {
    NSMutableArray* argTypes = [NSMutableArray arrayWithCapacity:arity];
    for (int i = 1; i <= arity; ++i)
      [argTypes addObject:[IFTypeVar typeVarWithIndex:i]];
    return [NSArray arrayWithObject:[IFFunType funTypeWithArgumentTypes:argTypes returnType:[IFTypeVar typeVarWithIndex:0]]];
  }
}

- (NSArray*)potentialRawExpressionsForArity:(unsigned)arity;
{
  NSMutableArray* operands = [NSMutableArray arrayWithCapacity:arity];
  for (unsigned i = 0; i < arity; ++i)
    [operands addObject:[IFParentExpression parentExpressionWithIndex:i]];
  return [NSArray arrayWithObject:[IFOperatorExpression expressionWithOperator:[IFOperator operatorForName:@"nop"] operands:operands]];
}

- (NSString*)computeLabel;
{
  return @"";
}

@end
