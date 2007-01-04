//
//  IFDropShadowFilterDelegate.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFDropShadowFilterDelegate.h"

#import "IFEnvironment.h"
#import "IFFunType.h"
#import "IFBasicType.h"

@implementation IFDropShadowFilterDelegate

- (NSArray*)potentialTypesWithEnvironment:(IFEnvironment*)env;
{
  static NSArray* types = nil;
  if (types == nil) {
    types = [[NSArray arrayWithObject:
      [IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObject:[IFBasicType imageType]]
                               returnType:[IFBasicType imageType]]] retain];
  }
  return types;
}

@end
