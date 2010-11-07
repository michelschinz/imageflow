//
//  IFVariable.m
//  ImageFlow
//
//  Created by Michel Schinz on 07.12.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFVariable.h"

@implementation IFVariable

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString*)key;
{
  return ![key isEqualToString:@"value"];
}

+ (id)variable;
{
  return [[[self alloc] init] autorelease];
}

- (id)value;
{
  return value;
}

- (void)setValue:(id)newValue;
{
  if (newValue == value)
    return;

  [self willChangeValueForKey:@"value"];
  [value release];
  value = [newValue retain];
  [self didChangeValueForKey:@"value"];
}

@end
