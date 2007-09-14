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

@implementation IFGhostFilter

- (BOOL)isGhost;
{
  return YES;
}

- (NSArray*)potentialTypes;
{
  int inputArity = [[environment valueForKey:@"inputArity"] intValue];
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
  static NSArray* exprs = nil;
  if (exprs == nil) {
    exprs = [[NSArray arrayWithObject:[IFOperatorExpression nop]] retain];
  }
  return exprs;
}

@end
