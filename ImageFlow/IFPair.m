//
//  IFPair.m
//  ImageFlow
//
//  Created by Michel Schinz on 18.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFPair.h"


@implementation IFPair

+ (id)pairWithFst:(id)theFst snd:(id)theSnd;
{
  return [[[self alloc] initWithFst:theFst snd:theSnd] autorelease];
}

- (id)initWithFst:(id)theFst snd:(id)theSnd;
{
  if (![super init])
    return nil;
  fst = [theFst retain];
  snd = [theSnd retain];
  return self;
}

 - (void)dealloc;
{
  [fst release];
  fst = nil;
  [snd release];
  snd = nil;
  [super dealloc];
}

- (id)fst;
{
  return fst;
}

- (id)snd;
{
  return snd;
}

@end
