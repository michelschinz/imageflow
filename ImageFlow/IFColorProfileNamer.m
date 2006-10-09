//
//  IFColorProfileNamer.m
//  ImageFlow
//
//  Created by Michel Schinz on 24.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFColorProfileNamer.h"


@implementation IFColorProfileNamer

static IFColorProfileNamer* sharedNamer = nil;
+ (IFColorProfileNamer*)sharedNamer;
{
  if (sharedNamer == nil)
    sharedNamer = [IFColorProfileNamer new];
  return sharedNamer;
}

- (id)init;
{
  if (![super init])
    return nil;
  namer = [IFObjectNamer new];
  allProfiles = [[IFColorProfile arrayOfAllProfiles] retain];
  for (int i = 0; i < [allProfiles count]; ++i) {
    IFColorProfile* profile = [allProfiles objectAtIndex:i];
    [namer registerObject:profile nameHint:[profile name]];
  }
  return self;
}

- (void) dealloc;
{
  [allProfiles release];
  allProfiles = nil;
  [namer release];
  namer = nil;
  [super dealloc];
}

- (NSArray*)uniqueNamesOfProfilesWithSpace:(OSType)space;
{
  NSMutableArray* names = [NSMutableArray array];
  for (int i = 0; i < [allProfiles count]; ++i) {
    IFColorProfile* profile = [allProfiles objectAtIndex:i];
    OSType pClass = [profile classType];
    
    if ([profile spaceType] == space && [profile description] && (pClass==cmDisplayClass || pClass==cmOutputClass))
      [names addObject:[namer uniqueNameForObject:profile]];
  }
  return names;
}

- (NSString*)pathForProfileWithUniqueName:(NSString*)name;
{
  IFColorProfile* profile = [namer objectForUniqueName:name];
  return [profile path];
}

- (NSString*)uniqueNameForProfileWithPath:(NSString*)path;
{
  for (int i = 0; i < [allProfiles count]; ++i) {
    IFColorProfile* profile = [allProfiles objectAtIndex:i];
    if ([[profile path] isEqualToString:path])
      return [namer uniqueNameForObject:profile];
  }
  NSAssert1(NO, @"invalid path %@",path);
  return nil;
}

@end
