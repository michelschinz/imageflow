//
//  IFBasicType.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFBasicType.h"

static NSArray* types = nil;

@interface IFBasicType()
- (IFBasicType*)initWithTag:(int)theTag;
+ (IFBasicType*)freshBasicTypeWithTag:(int)theTag;
@end

@implementation IFBasicType

+ (void)initialize;
{
  if (self != [IFBasicType class])
    return; // avoid repeated initialisation

  types = [[NSArray arrayWithObjects:
    [self freshBasicTypeWithTag:IFTypeTag_TColor_RGBA],
    [self freshBasicTypeWithTag:IFTypeTag_TRect],
    [self freshBasicTypeWithTag:IFTypeTag_TSize],
    [self freshBasicTypeWithTag:IFTypeTag_TPoint],
    [self freshBasicTypeWithTag:IFTypeTag_TString],
    [self freshBasicTypeWithTag:IFTypeTag_TFloat],
    [self freshBasicTypeWithTag:IFTypeTag_TInt],
    [self freshBasicTypeWithTag:IFTypeTag_TBool],
    [self freshBasicTypeWithTag:IFTypeTag_TAction],
    [self freshBasicTypeWithTag:IFTypeTag_TError],
    nil] retain];
}

+ (IFBasicType*)basicTypeWithTag:(int)theTag;
{
  return [types objectAtIndex:theTag];
}

@synthesize tag;

- (NSString*)description;
{
  switch (tag) {
    case IFTypeTag_TColor_RGBA:
      return @"Color_RGBA";
    case IFTypeTag_TRect:
      return @"Rect";
    case IFTypeTag_TSize:
      return @"Size";
    case IFTypeTag_TPoint:
      return @"Point";
    case IFTypeTag_TString:
      return @"String";
    case IFTypeTag_TFloat:
      return @"Float";
    case IFTypeTag_TInt:
      return @"Int";
    case IFTypeTag_TBool:
      return @"Bool";
    case IFTypeTag_TAction:
      return @"Action";
    case IFTypeTag_TError:
      return @"Error";
    default:
      NSAssert(NO, @"invalid tag");
      return nil;
  }
}

- (unsigned)arity;
{
  return 0;
}

// MARK: -
// MARK: PROTECTED

- (value)camlRepresentation;
{
  return Val_int(tag);
}

// MARK: -
// MARK: PRIVATE

+ (IFBasicType*)freshBasicTypeWithTag:(int)theTag;
{
  return [[[self alloc] initWithTag:theTag] autorelease];
}

- (IFBasicType*)initWithTag:(int)theTag;
{
  if (![super init])
    return nil;
  tag = theTag;
  return self;
}

@end
