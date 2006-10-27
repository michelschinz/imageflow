//
//  IFImageVariant.m
//  ImageFlow
//
//  Created by Michel Schinz on 07.09.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFImageVariant.h"


@implementation IFImageVariant

+ (id)variantWithMark:(IFTreeMark*)theMark name:(NSString*)theName;
{
  return [[[self alloc] initWithMark:theMark name:theName] autorelease];
}

- (id)initWithMark:(IFTreeMark*)theMark name:(NSString*)theName;
{
  if (![super init])
    return nil;
  mark = [theMark retain];
  name = [theName copy];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(mark);
  OBJC_RELEASE(name);
  [super dealloc];
}

- (NSString*)description;
{
  NSString* realName = [name isEqualToString:@""] ? @"output" : name;
  return [[mark tag] isEqualToString:@"c"] ? realName : [NSString stringWithFormat:@"#%@: %@",[mark tag],realName];
}

- (IFTreeMark*)mark;
{
  return mark;
}

- (NSString*)name;
{
  return name;
}

- (BOOL)isEqual:(id)other;
{
  return [other isKindOfClass:[self class]] && [self isEqualToImageVariant:other];
}

- (BOOL)isEqualToImageVariant:(IFImageVariant*)other;
{
  return [[self mark] isEqual:[other mark]] && [[self name] isEqualToString:[other name]];
}

- (unsigned)hash;
{
  return [mark hash] ^ [name hash];
}

@end
