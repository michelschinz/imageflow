//
//  IFProfileNamePathValueTransformer.m
//  ImageFlow
//
//  Created by Michel Schinz on 24.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFProfileNamePathValueTransformer.h"
#import "IFColorProfileNamer.h"

@implementation IFProfileNamePathValueTransformer

+ (void)initialize;
{
  [NSValueTransformer setValueTransformer:[[[self alloc] init] autorelease]
                                  forName:@"IFProfileNamePathTransformer"];
}

+ (Class)transformedValueClass;
{
  return [NSString class];
}

+ (BOOL)allowsReverseTransformation;
{
  return YES;   
}

- (id)transformedValue:(id)value;
{
  if (value == nil) return nil;
  return [[IFColorProfileNamer sharedNamer] uniqueNameForProfileWithPath:value];
}

- (id)reverseTransformedValue:(id)value;
{
  if (value == nil) return nil;
  return [[IFColorProfileNamer sharedNamer] pathForProfileWithUniqueName:value];
}

@end
