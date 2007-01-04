//
//  IFUnsharpMaskFilterDelegate.m
//  ImageFlow
//
//  Created by Renault John on 19.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "IFUnsharpMaskFilterDelegate.h"

#import "IFEnvironment.h"
#import "IFFunType.h"
#import "IFBasicType.h"

@implementation IFUnsharpMaskFilterDelegate

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
  return [NSString stringWithFormat:@"USM (%.1f int, %.1f rad)", [(NSNumber*)[env valueForKey:@"intensity"] floatValue], [(NSNumber*)[env valueForKey:@"radius"] floatValue]];
}

@end
