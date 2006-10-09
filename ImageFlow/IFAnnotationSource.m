//
//  IFAnnotationSource.m
//  ImageFlow
//
//  Created by Michel Schinz on 30.08.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFAnnotationSource.h"


@implementation IFAnnotationSource

- (id)value;
{
  return value;
}

- (void)updateValue:(id)newValue;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (void)setValue:(id)newValue;
{
  if (newValue == value)
    return;
  [value release];
  value = [newValue retain];
}

@end
