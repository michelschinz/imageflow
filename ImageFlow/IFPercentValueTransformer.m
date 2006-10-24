//
//  IFPercentValueTransformer.m
//  ImageFlow
//
//  Created by Michel Schinz on 18.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFPercentValueTransformer.h"


@implementation IFPercentValueTransformer

+ (void)initialize;
{
  if (self != [IFPercentValueTransformer class])
    return; // avoid repeated initialisation

  [NSValueTransformer setValueTransformer:[[[self alloc] init] autorelease]
                                  forName:@"IFPercentTransformer"];
}

+ (Class)transformedValueClass;
{
  return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation;
{
  return YES;   
}

- (id)transformedValue:(id)value;
{
  if (value == nil) return nil;
  return [NSNumber numberWithFloat:([value floatValue] * 100.0)];
}

- (id)reverseTransformedValue:(id)value;
{
  if (value == nil) return nil;
  return [NSNumber numberWithFloat:([value floatValue] / 100.0)];
}

@end
