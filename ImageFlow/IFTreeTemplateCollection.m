//
//  IFTreeTemplateCollection.m
//  ImageFlow
//
//  Created by Michel Schinz on 06.12.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFTreeTemplateCollection.h"
#import "IFXMLCoder.h"

static NSSet* templatesInDirectory(NSString* directory);
static NSString* uniqueDirName(NSString* dir, NSString* nameHint);

@implementation IFTreeTemplateCollection

+ (id)treeTemplateCollectionWithDirectory:(NSString*)theDirectory;
{
  return [[[self alloc] initWithDirectory:theDirectory] autorelease];
}

- (id)initWithDirectory:(NSString*)theDirectory;
{
  if (![super init])
    return nil;
  directory = [theDirectory retain];
  isModifiable = [[NSFileManager defaultManager] isWritableFileAtPath:directory];
  templates = [[NSMutableSet set] retain];
  [templates unionSet:templatesInDirectory(directory)];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(templates);
  OBJC_RELEASE(directory);
  [super dealloc];
}

@synthesize directory, templates, isModifiable;

- (void)addTemplate:(IFTreeTemplate*)treeTemplate;
{
  NSAssert(self.isModifiable, @"attempt to modify unmodifiable collection");
  NSFileManager* fileMgr = [NSFileManager defaultManager];
  IFXMLCoder* xmlCoder = [IFXMLCoder sharedCoder];

  NSString* path = treeTemplate.dirName;
  if (path == nil)
    path = uniqueDirName(directory, treeTemplate.name);

  NSDictionary* templateContents = [xmlCoder encodeTreeTemplate:treeTemplate];
  
  BOOL ok = [fileMgr createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil]; // TODO: attributes, error handling
  for (NSString* fileName in templateContents) {
    NSString* filePath = [path stringByAppendingPathComponent:fileName];
    ok &= [fileMgr createFileAtPath:filePath contents:[templateContents objectForKey:fileName] attributes:nil]; // TODO: attributes
  }

  if (ok)
    [templates addObject:treeTemplate];
  else
    NSBeep(); // TODO handle error
}

- (void)removeTemplate:(IFTreeTemplate*)treeTemplate;
{
  NSAssert([self isModifiable], @"attempt to modify unmodifiable collection");
  NSFileManager* fileMgr = [NSFileManager defaultManager];

  if ([fileMgr removeItemAtPath:treeTemplate.dirName error:nil]) // TODO: error handling
    [templates removeObject:treeTemplate];
  else
    NSBeep(); // TODO handle error
}

- (BOOL)containsTemplate:(IFTreeTemplate*)treeTemplate;
{
  return [templates containsObject:treeTemplate];
}

@end

static NSSet* templatesInDirectory(NSString* directory) {
  NSFileManager* fileMgr = [NSFileManager defaultManager];
  IFXMLCoder* xmlCoder = [IFXMLCoder sharedCoder];

  NSMutableSet* templates = [NSMutableSet set];
  NSArray* dirContents = [fileMgr contentsOfDirectoryAtPath:directory error:nil]; // TODO: error handling
  if (dirContents == nil)
    return templates;

  for (NSString* element in dirContents) {
    NSString* tDir = [directory stringByAppendingPathComponent:element];
    NSString* treePath = [tDir stringByAppendingPathComponent:@"tree.xml"];
    if (![fileMgr fileExistsAtPath:treePath])
      continue;

    NSArray* tDirContents = [fileMgr contentsOfDirectoryAtPath:tDir error:nil]; // TODO: error handling
    if (tDirContents == nil)
      continue;

    NSMutableDictionary* tDirData = [NSMutableDictionary dictionary];
    for (NSString* tDirElement in tDirContents)
      [tDirData setObject:[NSData dataWithContentsOfFile:[tDir stringByAppendingPathComponent:tDirElement] options:NSDataReadingUncached error:nil] forKey:tDirElement]; // TODO: error handling

    IFTreeTemplate* treeTemplate = [xmlCoder decodeTreeTemplate:tDirData];
    treeTemplate.dirName = element;
    [templates addObject:treeTemplate];
  }
  return templates;
}

static NSString* uniqueDirName(NSString* dir, NSString* nameHint) {
  NSFileManager* fileMgr = [NSFileManager defaultManager];
  
  // Sanitize name hint
  NSMutableString* saneNameHint = [NSMutableString string];
  for (int i = 0; i < [nameHint length]; ++i) {
    unichar c = [nameHint characterAtIndex:i];
    if (isalnum(c))
      [saneNameHint appendFormat:@"%C",c];
  }
  if ([saneNameHint length] == 0)
    [saneNameHint appendString:@"template"];

  // Generate non-existing name
  NSString* path = [dir stringByAppendingPathComponent:saneNameHint];
  NSString* uniquePart = @"";
  for (int i = 2; [fileMgr fileExistsAtPath:[NSString stringWithFormat:@"%@%@",path,uniquePart]]; ++i)
    uniquePart = [NSString stringWithFormat:@"_%d",i];

  return [NSString stringWithFormat:@"%@%@",path,uniquePart];
}
