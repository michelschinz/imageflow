//
//  IFGaussianBlurFilterDelegate.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFGaussianBlurFilterDelegate.h"

#import "IFEnvironment.h"
#import "IFFunType.h"
#import "IFBasicType.h"

@implementation IFGaussianBlurFilterDelegate

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

- (NSString*)labelWithEnvironment:(IFEnvironment*)env;
{
  return [NSString stringWithFormat:@"blur (%.1f gaussian)", [(NSNumber*)[env valueForKey:@"radius"] floatValue]];
}

@end
