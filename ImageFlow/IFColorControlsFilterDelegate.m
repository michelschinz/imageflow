//
//  IFColorControlsFilterDelegate.m
//  ImageFlow
//
//  Created by Olivier Crameri on 19.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "IFColorControlsFilterDelegate.h"

#import "IFEnvironment.h"
#import "IFFunType.h"
#import "IFBasicType.h"

@implementation IFColorControlsFilterDelegate

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
  return [NSString stringWithFormat:@"Control colors"];
}

@end
