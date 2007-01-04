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
    [self basicTypeWithTag:IFTypeTag_TImage],
    [self basicTypeWithTag:IFTypeTag_TMask],
    [self basicTypeWithTag:IFTypeTag_TColor],
    [self basicTypeWithTag:IFTypeTag_TRect],
    [self basicTypeWithTag:IFTypeTag_TSize],
    [self basicTypeWithTag:IFTypeTag_TPoint],
    [self basicTypeWithTag:IFTypeTag_TString],
    [self basicTypeWithTag:IFTypeTag_TNum],
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

+ (IFBasicType*)imageType;
{
  return [types objectAtIndex:IFTypeTag_TImage];
}

+ (IFBasicType*)maskType;
{
  return [types objectAtIndex:IFTypeTag_TMask];
}

+ (IFBasicType*)colorType;
{
  return [types objectAtIndex:IFTypeTag_TColor];
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

+ (IFBasicType*)numType;
{
  return [types objectAtIndex:IFTypeTag_TNum];
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

- (value)camlRepresentation;
{
  return Val_int(tag);
}

@end
