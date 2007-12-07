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
- (id)initWithCollections:(NSSet*)theCollections;
- (void)setTemplates:(NSSet*)newTemplates;
- (NSSet*)computeTemplates;
@end

@implementation IFTreeTemplateManager

static BOOL createDirectoryAndParentsAtPath(NSString* path, NSDictionary* attributes);

static IFTreeTemplateManager* sharedManager;

+ (IFTreeTemplateManager*)sharedManager;
{
  if (sharedManager == nil) {
    NSSet* dirs = [[IFDirectoryManager sharedDirectoryManager] filterTemplatesDirectories];
    
    NSEnumerator* dirsEnum = [dirs objectEnumerator];
    NSString* dir;
    while (dir = [dirsEnum nextObject]) {
      NSFileManager* fileMgr = [NSFileManager defaultManager];
      if (![fileMgr fileExistsAtPath:dir]) {
        BOOL ok = createDirectoryAndParentsAtPath(dir, nil);
        NSAssert1(ok, @"unable to create directory %@",dir);
      }
    }

    sharedManager = [[IFTreeTemplateManager alloc] initWithCollections:[[IFTreeTemplateCollection collect] treeTemplateCollectionWithDirectory:[dirs each]]];
  }
  return sharedManager;
}

- (void)dealloc;
{
  loadFileTemplate = nil;
  defaultModifiableCollection = nil;
  OBJC_RELEASE(templates);
  OBJC_RELEASE(collections);
  [super dealloc];
}

- (NSSet*)collections;
{
  return collections;
}

- (IFTreeTemplateCollection*)collectionContainingTemplate:(IFTreeTemplate*)treeTemplate;
{
  NSEnumerator* collectionEnum = [collections objectEnumerator];
  IFTreeTemplateCollection* collection;
  while (collection = [collectionEnum nextObject]) {
    if ([collection containsTemplate:treeTemplate])
      return collection;
  }
  return nil;
}

- (NSSet*)templates;
{
  return templates;
}

- (void)addTemplate:(IFTreeTemplate*)treeTemplate;
{
  [defaultModifiableCollection addTemplate:treeTemplate];
  [self setTemplates:[self computeTemplates]];
}

- (BOOL)canMoveTemplate:(IFTreeTemplate*)treeTemplate toCollection:(IFTreeTemplateCollection*)targetCollection;
{
  return [[self collectionContainingTemplate:treeTemplate] isModifiable];
}

- (void)moveTemplate:(IFTreeTemplate*)treeTemplate toCollection:(IFTreeTemplateCollection*)targetCollection;
{
  NSAssert([self canMoveTemplate:treeTemplate toCollection:targetCollection], @"cannot move template");
  IFTreeTemplateCollection* sourceCollection = [self collectionContainingTemplate:treeTemplate];
  // TODO ideally, this should be done atomically
  [targetCollection addTemplate:treeTemplate];
  [sourceCollection removeTemplate:treeTemplate];
}

- (IFTreeTemplate*)loadFileTemplate;
{
  if (loadFileTemplate == nil) {
    NSEnumerator* templatesEnum = [templates objectEnumerator];
    IFTreeTemplate* template;
    while (template = [templatesEnum nextObject]) {
      if ([[template tag] isEqualToString:@"load"])
        loadFileTemplate = template; // not retained
    }
    NSAssert(loadFileTemplate != nil, @"no load template found");
  }
  return loadFileTemplate;
}

@end

static BOOL createDirectoryAndParentsAtPath(NSString* path, NSDictionary* attributes) {
  NSFileManager* fileMgr = [NSFileManager defaultManager];
  NSString* parentPath = [path stringByDeletingLastPathComponent];
  if (![fileMgr fileExistsAtPath:parentPath]) {
    if (!createDirectoryAndParentsAtPath(parentPath, attributes))
      return NO;
  }
  return [fileMgr createDirectoryAtPath:path attributes:attributes];
}


@implementation IFTreeTemplateManager (Private)

- (id)initWithCollections:(NSSet*)theCollections;
{
  if (![super init])
    return nil;
  collections = [theCollections retain];
  templates = [[self computeTemplates] retain];
  
  NSEnumerator* collectionsEnum = [collections objectEnumerator];
  IFTreeTemplateCollection* collection;
  while (collection = [collectionsEnum nextObject]) {
    if ([[collection directory] isEqualToString:[[IFDirectoryManager sharedDirectoryManager] userFilterTemplateDirectory]]) {
      defaultModifiableCollection = collection;
      break;
    }
  }
  NSAssert(defaultModifiableCollection != nil, @"cannot find default modifiable collection");
  
  return self;
}

- (void)setTemplates:(NSSet*)newTemplates;
{
  if (newTemplates == templates)
    return;
  [templates release];
  templates = [newTemplates retain];
}

- (NSSet*)computeTemplates;
{
  NSMutableSet* allTemplates = [[NSMutableSet set] retain];
  NSEnumerator* collectionsEnum = [collections objectEnumerator];
  IFTreeTemplateCollection* collection;
  while (collection = [collectionsEnum nextObject])
    [allTemplates unionSet:[collection templates]];
  return allTemplates;
}

@end
