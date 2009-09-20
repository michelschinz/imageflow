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
static NSString* uniqueFileName(NSString* dir, NSString* nameHint);

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
  modifiable = [[NSFileManager defaultManager] isWritableFileAtPath:directory];
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

- (NSString*)directory;
{
  return directory;
}

- (NSSet*)templates;
{
  return templates;
}

- (BOOL)containsTemplate:(IFTreeTemplate*)treeTemplate;
{
  return [templates containsObject:treeTemplate];
}

- (BOOL)isModifiable;
{
  return modifiable;
}

- (void)addTemplate:(IFTreeTemplate*)treeTemplate;
{
  NSAssert([self isModifiable], @"attempt to modify unmodifiable collection");
  NSFileManager* fileMgr = [NSFileManager defaultManager];
  IFXMLCoder* xmlCoder = [IFXMLCoder sharedCoder];

  NSString* path = [treeTemplate fileName];
  if (path == nil)
    path = uniqueFileName(directory, [treeTemplate name]);
  
  NSXMLDocument* xmlTreeTemplate = [xmlCoder encodeTreeTemplate:treeTemplate];
  if ([fileMgr createFileAtPath:path contents:[xmlTreeTemplate XMLDataWithOptions:NSXMLNodePrettyPrint] attributes:nil]) // TODO attributes?
    [templates addObject:treeTemplate];
  else
    NSBeep(); // TODO handle error
}

- (void)removeTemplate:(IFTreeTemplate*)treeTemplate;
{
  NSAssert([self isModifiable], @"attempt to modify unmodifiable collection");
  NSFileManager* fileMgr = [NSFileManager defaultManager];

  if ([fileMgr removeFileAtPath:[treeTemplate fileName] handler:nil])
    [templates removeObject:treeTemplate];
  else
    NSBeep(); // TODO handle error
}

@end

static NSSet* templatesInDirectory(NSString* directory) {
  NSFileManager* fileMgr = [NSFileManager defaultManager];
  IFXMLCoder* xmlCoder = [IFXMLCoder sharedCoder];

  NSMutableSet* templates = [NSMutableSet set];
  NSArray* dirContents = [fileMgr directoryContentsAtPath:directory];
  if (dirContents != nil) {
    for (int i = 0; i < [dirContents count]; ++i) {
      NSString* path = [directory stringByAppendingPathComponent:[dirContents objectAtIndex:i]];
      if (![path hasSuffix:@".xml"] || ![fileMgr isReadableFileAtPath:path])
        continue;
      
      NSError* error;
      NSXMLDocument* xmlDoc = [[[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] options:NSXMLDocumentTidyXML error:&error] autorelease];
      // TODO handle errors
      IFTreeTemplate* treeTemplate = [xmlCoder decodeTreeTemplate:xmlDoc];
      [treeTemplate setFileName:path];
      [templates addObject:treeTemplate];
    }
  }
  return templates;
}

static NSString* uniqueFileName(NSString* dir, NSString* nameHint) {
  NSFileManager* fileMgr = [NSFileManager defaultManager];
  
  // Sanitize name hint
  NSMutableString* saneNameHint = [NSMutableString string];
  for (int i = 0; i < [nameHint length]; ++i) {
    unichar c = [nameHint characterAtIndex:i];
    if (isalnum(c))
      [saneNameHint appendFormat:@"%C",c];
  }
  if ([saneNameHint length] == 0)
    saneNameHint = [NSMutableString stringWithString:@"tree"];

  // Generate non-existing name
  NSString* pathFormat = [dir stringByAppendingPathComponent:[saneNameHint stringByAppendingString:@"%@.xml"]];
  NSString* uniquePart = @"";
  for (int i = 2; [fileMgr fileExistsAtPath:[NSString stringWithFormat:pathFormat,uniquePart]]; ++i)
    uniquePart = [NSString stringWithFormat:@"-%d",i];

  return [NSString stringWithFormat:pathFormat,uniquePart];
}
