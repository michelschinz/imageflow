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
  [NSValueTransformer setValueTransformer:[[[self alloc] init] autorelease] forName:@"IFPercentTransformer"];
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
  return (value == nil) ? nil : [NSNumber numberWithFloat:([value floatValue] * 100.0)];
}

- (id)reverseTransformedValue:(id)value;
{
  return (value == nil) ? nil : [NSNumber numberWithFloat:([value floatValue] / 100.0)];
}

@end
