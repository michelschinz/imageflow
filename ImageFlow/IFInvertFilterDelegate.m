//
//  IFInvertFilterDelegate.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFInvertFilterDelegate.h"

#import "IFEnvironment.h"
#import "IFFunType.h"
#import "IFBasicType.h"

@implementation IFInvertFilterDelegate

- (NSArray*)potentialTypesWithEnvironment:(IFEnvironment*)env;
{
  static NSArray* types = nil;
  if (types == nil) {
    // TODO add Mask=>Mask
    types = [[NSArray arrayWithObject:
      [IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObject:[IFBasicType imageType]]
                               returnType:[IFBasicType imageType]]] retain];
  }
  return types;
}

@end
