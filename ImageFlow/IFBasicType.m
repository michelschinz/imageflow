//
//  IFBasicType.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFBasicType.h"


@implementation IFBasicType

static NSArray* types = nil;

+ (void)initialize;
{
  if (self != [IFBasicType class])
    return; // avoid repeated initialisation

  types = [[NSArray arrayWithObjects:
    [self basicTypeWithTag:IFTypeTag_TColor_RGBA],
    [self basicTypeWithTag:IFTypeTag_TRect],
    [self basicTypeWithTag:IFTypeTag_TSize],
    [self basicTypeWithTag:IFTypeTag_TPoint],
    [self basicTypeWithTag:IFTypeTag_TString],
    [self basicTypeWithTag:IFTypeTag_TFloat],
    [self basicTypeWithTag:IFTypeTag_TInt],
    [self basicTypeWithTag:IFTypeTag_TBool],
    [self basicTypeWithTag:IFTypeTag_TAction],
    [self basicTypeWithTag:IFTypeTag_TError],
    nil] retain];
}

+ (IFBasicType*)basicTypeWithTag:(int)theTag;
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

+ (IFBasicType*)colorRGBAType;
{
  return [types objectAtIndex:IFTypeTag_TColor_RGBA];
}

+ (IFBasicType*)rectType;
{
  return [types objectAtIndex:IFTypeTag_TRect];
}

+ (IFBasicType*)sizeType;
{
  return [types objectAtIndex:IFTypeTag_TSize];
}

+ (IFBasicType*)pointType;
{
  return [types objectAtIndex:IFTypeTag_TPoint];
}

+ (IFBasicType*)stringType;
{
  return [types objectAtIndex:IFTypeTag_TString];
}

+ (IFBasicType*)floatType;
{
  return [types objectAtIndex:IFTypeTag_TFloat];
}

+ (IFBasicType*)intType;
{
  return [types objectAtIndex:IFTypeTag_TInt];
}

+ (IFBasicType*)boolType;
{
  return [types objectAtIndex:IFTypeTag_TBool];
}

+ (IFBasicType*)actionType;
{
  return [types objectAtIndex:IFTypeTag_TAction];
}

+ (IFBasicType*)errorType;
{
  return [types objectAtIndex:IFTypeTag_TError];
}

- (int)tag;
{
  return tag;
}

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

- (int)arity;
{
  return 0;
}

- (IFType*)typeByLimitingArityTo:(int)maxArity;
{
  return self;
}

- (value)camlRepresentation;
{
  return Val_int(tag);
}

@end
