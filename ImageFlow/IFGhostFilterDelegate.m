//
//  IFGhostFilterDelegate.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFGhostFilterDelegate.h"

#import "IFEnvironment.h"
#import "IFFunType.h"
#import "IFTypeVar.h"

@implementation IFGhostFilterDelegate

- (NSArray*)potentialTypesWithEnvironment:(IFEnvironment*)env;
{
  int inputArity = [[env valueForKey:@"inputArity"] intValue];
  if (inputArity == 0)
    return [NSArray arrayWithObject:[IFTypeVar typeVarWithIndex:0]];
  else {
    NSMutableArray* argTypes = [NSMutableArray arrayWithCapacity:inputArity];
    for (int i = 1; i <= inputArity; ++i)
      [argTypes addObject:[IFTypeVar typeVarWithIndex:i]];
    return [NSArray arrayWithObject:[IFFunType funTypeWithArgumentTypes:argTypes returnType:[IFTypeVar typeVarWithIndex:0]]];
  }
}

@end
