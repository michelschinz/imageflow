//
//  IFDocumentTemplateManager.m
//  ImageFlow
//
//  Created by Michel Schinz on 14.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFDocumentTemplateManager.h"
#import "IFDocumentTemplate.h"

@implementation IFDocumentTemplateManager

+ (id)managerWithDirectory:(NSString*)theDirectory;
{
  return [[[self alloc] initWithDirectory:theDirectory] autorelease];
}

- (id)initWithDirectory:(NSString*)theDirectory;
{
  if (![super init])
    return nil;
  directory = [theDirectory copy];
  templates = nil;
  return self;
}

- (void) dealloc {
  OBJC_RELEASE(directory);
  OBJC_RELEASE(templates);
  [super dealloc];
}

- (NSArray*)templates;
{
  if (templates == nil) {
    NSArray* relFileNames = [[NSFileManager defaultManager] directoryContentsAtPath:directory];
    NSArray* absFileNames = (NSArray*)[[directory collect] stringByAppendingPathComponent:[relFileNames each]];
    templates = [[[IFDocumentTemplate collect] templateWithFileName:[absFileNames each]] retain];
  }
  return templates;
}

- (IFDocumentTemplate*)templateWithName:(NSString*)name;
{
  NSArray* allTemplates = [self templates];
  NSArray* filteredTemplates = [allTemplates selectWhereValueForKey:@"name" isEqual:name];
  return ([filteredTemplates count] > 0) ? [filteredTemplates objectAtIndex:0] : nil;
}

- (IFDocumentTemplate*)loadFileTemplate;
{
  IFDocumentTemplate* template = [self templateWithName:@"Load file"];
  NSAssert(template != nil, @"no 'Load file' template found");
  return template;
}

@end
