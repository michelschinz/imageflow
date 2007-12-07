//
//  IFDirectoryManager.m
//  ImageFlow
//
//  Created by Michel Schinz on 14.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFDirectoryManager.h"

@interface IFDirectoryManager (Private)
- (NSString*)filterTemplateSubdirectoryOf:(NSString*)directory;
- (NSString*)applicationSupportDirectory;
@end

@implementation IFDirectoryManager

static IFDirectoryManager* sharedDirectoryManager = nil;

+ (IFDirectoryManager*)sharedDirectoryManager;
{
  if (sharedDirectoryManager == nil)
    sharedDirectoryManager = [[IFDirectoryManager alloc] init];
  return sharedDirectoryManager;
}

- (NSString*)documentTemplatesDirectory;
{
  NSString* templateSubPath = [NSString pathWithComponents:[NSArray arrayWithObjects:@"Templates",@"Documents",nil]];
  return [[self applicationSupportDirectory] stringByAppendingPathComponent:templateSubPath];
}

- (NSString*)userFilterTemplateDirectory;
{
  return [self filterTemplateSubdirectoryOf:[self applicationSupportDirectory]];
}

- (NSSet*)filterTemplatesDirectories;
{
  return [NSSet setWithObjects:
    [self filterTemplateSubdirectoryOf:[[NSBundle mainBundle] resourcePath]],
    [self userFilterTemplateDirectory],
    nil];
}

@end

@implementation IFDirectoryManager (Private)

- (NSString*)filterTemplateSubdirectoryOf:(NSString*)directory;
{
  return [[directory stringByAppendingPathComponent:@"Templates"] stringByAppendingPathComponent:@"Filters"];
}

- (NSString*)applicationSupportDirectory;
{
  NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,NSUserDomainMask,YES);
  NSAssert([dirs count] == 1, @"unexpected number of directories");
  return [[dirs objectAtIndex:0] stringByAppendingPathComponent:@"ImageFlow"];
}

@end
