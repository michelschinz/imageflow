//
//  IFTreeTemplateManager.m
//  ImageFlow
//
//  Created by Michel Schinz on 26.10.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFTreeTemplateManager.h"
#import "IFDirectoryManager.h"
#import "IFXMLCoder.h"

@interface IFTreeTemplateManager (Private)
- (IFTreeTemplate*)templateFromXMLFileNamed:(NSString*)fileName;
- (IFTreeTemplate*)templateWithName:(NSString*)name;
@end

@implementation IFTreeTemplateManager

static IFTreeTemplateManager* sharedManager;

+ (IFTreeTemplateManager*)sharedManager;
{
  if (sharedManager == nil)
    sharedManager = [[IFTreeTemplateManager alloc] initWithDirectory:[[IFDirectoryManager sharedDirectoryManager] filterTemplatesDirectory]];
  return sharedManager;
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
    templates = [[[self collect] templateFromXMLFileNamed:[absFileNames each]] retain];
  }
  return templates;
}

- (IFTreeTemplate*)loadFileTemplate;
{
  IFTreeTemplate* template = [self templateWithName:@"Load file"];
  NSAssert(template != nil, @"no 'Load file' template found");
  return template;
}

@end

@implementation IFTreeTemplateManager (Private)

- (IFTreeTemplate*)templateFromXMLFileNamed:(NSString*)fileName;
{
  NSError* error;
  NSXMLDocument* xmlDoc = [[[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:fileName] options:NSXMLDocumentTidyXML error:&error] autorelease];
  NSAssert(xmlDoc != nil, @"I/O error");
  // TODO handle errors
  return [[IFXMLCoder sharedCoder] decodeTreeTemplate:[xmlDoc rootElement]];
}

- (IFTreeTemplate*)templateWithName:(NSString*)name;
{
  NSArray* allTemplates = [self templates];
  NSArray* filteredTemplates = [allTemplates selectWhereValueForKey:@"name" isEqual:name];
  return ([filteredTemplates count] > 0) ? [filteredTemplates objectAtIndex:0] : nil;
}

@end
