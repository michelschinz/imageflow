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

@implementation IFGhostFilter

- (BOOL)isGhost;
{
  return YES;
}

- (NSArray*)potentialTypes;
{
  unsigned inputArity = [[environment valueForKey:@"inputArity"] unsignedIntValue];
  if (inputArity == 0)
    return [NSArray arrayWithObject:[IFTypeVar typeVarWithIndex:0]];
  else {
    NSMutableArray* argTypes = [NSMutableArray arrayWithCapacity:inputArity];
    for (int i = 1; i <= inputArity; ++i)
      [argTypes addObject:[IFTypeVar typeVarWithIndex:i]];
    return [NSArray arrayWithObject:[IFFunType funTypeWithArgumentTypes:argTypes returnType:[IFTypeVar typeVarWithIndex:0]]];
  }
}

- (NSArray*)potentialRawExpressions;
{
  unsigned inputArity = [[environment valueForKey:@"inputArity"] unsignedIntValue];
  NSMutableArray* operands = [NSMutableArray arrayWithCapacity:inputArity];
  for (unsigned i = 0; i < inputArity; ++i)
    [operands addObject:[IFParentExpression parentExpressionWithIndex:i]];
  return [NSArray arrayWithObject:[IFOperatorExpression expressionWithOperator:[IFOperator operatorForName:@"nop"] operands:operands]];
}

@end
