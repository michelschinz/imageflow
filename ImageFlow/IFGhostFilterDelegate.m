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
  // TODO handle arity
  static NSArray* types = nil;
  if (types == nil) {
    types = [[NSArray arrayWithObject:
      [IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObject:[IFTypeVar typeVarWithIndex:0]]
                               returnType:[IFTypeVar typeVarWithIndex:1]]] retain];
  }
  return types;
}

@end
