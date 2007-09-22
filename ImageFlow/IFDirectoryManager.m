//
//  IFDirectoryManager.m
//  ImageFlow
//
//  Created by Michel Schinz on 14.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFDirectoryManager.h"


@implementation IFDirectoryManager

static IFDirectoryManager* sharedDirectoryManager = nil;

+ (IFDirectoryManager*)sharedDirectoryManager;
{
  if (sharedDirectoryManager == nil)
    sharedDirectoryManager = [self new];
  return sharedDirectoryManager;
}

- (id)init;
{
  if (![super init])
    return nil;
  applicationSupportDirectory = nil;
  return self;
}

- (void) dealloc {
  OBJC_RELEASE(applicationSupportDirectory);
  [super dealloc];
}

- (NSString*)sourceTemplatesDirectory;
{
  return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Templates"];
}

- (NSString*)applicationSupportDirectory;
{
  if (applicationSupportDirectory == nil) {
    NSFileManager* fileMgr = [NSFileManager defaultManager];

    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,NSUserDomainMask,YES);
    NSAssert([paths count] == 1, @"unexpected number of paths");
    NSAssert([fileMgr fileExistsAtPath:[paths objectAtIndex:0]], @"no Application Support directory");
    applicationSupportDirectory = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageFlow"] copy];

    if (![fileMgr fileExistsAtPath:applicationSupportDirectory])
      [fileMgr createDirectoryAtPath:applicationSupportDirectory attributes:nil];
  }
  return applicationSupportDirectory;
}

- (NSString*)templatesDirectory;
{
  return [[self applicationSupportDirectory] stringByAppendingPathComponent:@"Templates"];
}

- (NSString*)filterTemplatesDirectory;
{
  return [[self templatesDirectory] stringByAppendingPathComponent:@"Filters"];
}

- (NSString*)documentTemplatesDirectory;
{
  return [[self templatesDirectory] stringByAppendingPathComponent:@"Documents"];
}

@end
