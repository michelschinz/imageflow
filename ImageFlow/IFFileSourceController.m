//
//  IFFileSourceController.m
//  ImageFlow
//
//  Created by Michel Schinz on 24.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFFileSourceController.h"
#import "IFColorProfile.h"
#import "IFColorProfileNamer.h"
#import "IFTreeNodeFilter.h"

@interface IFFileSourceController (Private)
- (NSString*)profileFileNameKey;
- (void)updateSelectedProfileName;
- (void)updateResolutionTag;
- (void)reallySetResolutionTag:(int)newResolutionTag;
- (void)updateProperties;
- (void)flushProperties;
@end

@implementation IFFileSourceController

static NSString* kContextFileName = @"fileName";
static NSString* kContextProfileTag = @"defaultProfileFileName";
static NSString* kContextResolutionTag = @"resolutionTag";

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey {
  return ![theKey isEqualToString:@"resolutionTag"]
  && ![theKey isEqualToString:@"selectedProfileName"]
  && [super automaticallyNotifiesObserversForKey:theKey];
}

- (id)init;
{
  if (![super init])
    return nil;
  fileProperties = nil;
  selectedProfileName = nil;
  return self;
}

- (void)awakeFromNib;
{
  [self updateResolutionTag];
  [filterController addObserver:self forKeyPath:@"content.settings.fileName" options:0 context:kContextFileName];
  [filterController addObserver:self forKeyPath:@"content.settings.defaultRGBProfileFileName" options:0 context:kContextProfileTag];
  [filterController addObserver:self forKeyPath:@"content.settings.defaultGrayProfileFileName" options:0 context:kContextProfileTag];
  [filterController addObserver:self forKeyPath:@"content.settings.defaultCMYKProfileFileName" options:0 context:kContextProfileTag];
  [filterController addObserver:self forKeyPath:@"content.settings.useEmbeddedResolution" options:0 context:kContextResolutionTag];
  [filterController addObserver:self forKeyPath:@"content.settings.useDocumentResolutionAsDefault" options:0 context:kContextResolutionTag];
}

- (void) dealloc;
{
  [filterController removeObserver:self forKeyPath:@"content.settings.defaultCMYKProfileFileName"];
  [filterController removeObserver:self forKeyPath:@"content.settings.defaultGrayProfileFileName"];
  [filterController removeObserver:self forKeyPath:@"content.settings.defaultRGBProfileFileName"];
  [filterController removeObserver:self forKeyPath:@"content.settings.useDocumentResolutionAsDefault"];
  [filterController removeObserver:self forKeyPath:@"content.settings.useEmbeddedResolution"];
  [filterController removeObserver:self forKeyPath:@"content.settings.fileName"];
  [self flushProperties];
  [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
  if (context == kContextFileName) {
    [self flushProperties];
    [self updateSelectedProfileName];
  } else if (context == kContextProfileTag)
    [self updateSelectedProfileName];
  else if (context == kContextResolutionTag)
    [self updateResolutionTag];
  else
    NSAssert(NO, @"unexpected key path");
}

- (NSArray*)profileNames;
{
  int space;
  [self updateProperties];
  NSString* colorModel = [fileProperties objectForKey:(id)kCGImagePropertyColorModel];
  if (colorModel == nil)
    return [NSArray array];

  if ([colorModel isEqualToString:(id)kCGImagePropertyColorModelRGB])
    space = cmRGBData;
  else if ([colorModel isEqualToString:(id)kCGImagePropertyColorModelGray])
    space = cmGrayData;
  else if ([colorModel isEqualToString:(id)kCGImagePropertyColorModelCMYK])
    space = cmCMYKData;
  else {
    NSAssert(NO, @"unknown color model");
    space = -1;
  }
  return [[IFColorProfileNamer sharedNamer] uniqueNamesOfProfilesWithSpace:space];
}

- (void)setSelectedProfileName:(NSString*)newSelectedProfileName;
{
  NSString* key = [self profileFileNameKey];
  if (key == nil)
    return;
  IFEnvironment* env = [[filterController content] settings];
  [env setValue:[[IFColorProfileNamer sharedNamer] pathForProfileWithUniqueName:newSelectedProfileName] forKey:key];
}

- (NSString*)selectedProfileName;
{
  return selectedProfileName;
}

- (BOOL)hasEmbeddedProfile;
{
  [self updateProperties];
  return [fileProperties objectForKey:(id)kCGImagePropertyProfileName] != nil;
}

- (NSString*)useEmbeddedProfileTitle;
{
  [self updateProperties];
  
  NSString* maybeProfileName = [fileProperties objectForKey:(id)kCGImagePropertyProfileName];
  NSString* profileName = (maybeProfileName != nil)
    ? maybeProfileName
    : @"none";
  
  return [NSString stringWithFormat:@"Use embedded profile (%@)",profileName];
}

- (BOOL)hasEmbeddedResolution;
{
  [self updateProperties];
  return [fileProperties objectForKey:(id)kCGImagePropertyDPIWidth] != nil;
}

- (NSString*)useEmbeddedResolutionTitle;
{
  [self updateProperties];

  NSNumber* maybeResH = [fileProperties objectForKey:(id)kCGImagePropertyDPIWidth];
  NSNumber* maybeResV = [fileProperties objectForKey:(id)kCGImagePropertyDPIHeight];
  NSString* resolution = (maybeResH != nil && maybeResV != nil)
    ? [NSString stringWithFormat:@"%dx%d DPI",[maybeResH intValue], [maybeResV intValue]]
    : @"none";

  return [NSString stringWithFormat:@"Use embedded resolution (%@)",resolution];
}

- (void)setResolutionTag:(int)newTag;
{
  IFEnvironment* env = [[filterController content] settings];

  switch (newTag) {
    case 0:
      [env setValue:[NSNumber numberWithBool:NO] forKey:@"useDocumentResolutionAsDefault"];
      [env setValue:[NSNumber numberWithBool:NO] forKey:@"useEmbeddedResolution"];
      break;
    case 1:
      [env setValue:[NSNumber numberWithBool:YES] forKey:@"useDocumentResolutionAsDefault"];
      [env setValue:[NSNumber numberWithBool:NO] forKey:@"useEmbeddedResolution"];
      break;
    case 2:
      [env setValue:[NSNumber numberWithBool:YES] forKey:@"useEmbeddedResolution"];
      break;
    default:
      NSAssert(NO, @"unexpected tag");
      break;
  }
}

- (int)resolutionTag;
{
  return resolutionTag;
}

- (IBAction)browseFile:(id)sender;
{
  NSOpenPanel* panel = [NSOpenPanel openPanel];
  [panel setCanChooseDirectories:NO];
  [panel setAllowsMultipleSelection:NO];
  IFEnvironment* env = [[filterController content] settings];
  if ([panel runModalForDirectory:nil file:[env valueForKey:@"fileName"]] != NSOKButton)
    return;

  NSString* fileName = [[panel filenames] objectAtIndex:0];
  [env setValue:fileName forKey:@"fileName"];
}

@end

@implementation IFFileSourceController (Private)

- (NSString*)profileFileNameKey;
{
  [self updateProperties];
  NSString* colorModel = [fileProperties objectForKey:(id)kCGImagePropertyColorModel];
  if (colorModel == nil)
    return nil;
  
  if ([colorModel isEqualToString:(id)kCGImagePropertyColorModelRGB])
    return @"defaultRGBProfileFileName";
  else if ([colorModel isEqualToString:(id)kCGImagePropertyColorModelGray])
    return @"defaultGrayProfileFileName";
  else if ([colorModel isEqualToString:(id)kCGImagePropertyColorModelCMYK])
    return @"defaultCMYKProfileFileName";
  else {
    NSAssert(NO, @"unknown color model");
    return nil;
  }
}  

- (void)updateSelectedProfileName;
{
  NSString* key = [self profileFileNameKey];
  NSString* path;
  if (key == nil)
    path = nil;
  else {
    IFEnvironment* env = [[filterController content] settings];
    path = [env valueForKey:key];
  }

  [self willChangeValueForKey:@"selectedProfileName"];
  [selectedProfileName release];
  selectedProfileName = (path != nil)
    ? [[[IFColorProfileNamer sharedNamer] uniqueNameForProfileWithPath:path] retain]
    : nil;
  [self didChangeValueForKey:@"selectedProfileName"];
}

- (void)updateResolutionTag;
{
  IFEnvironment* env = [[filterController content] settings];
  if ([[env valueForKey:@"useEmbeddedResolution"] boolValue])
    [self reallySetResolutionTag:2];
  else if ([[env valueForKey:@"useDocumentResolutionAsDefault"] boolValue])
    [self reallySetResolutionTag:1];
  else
    [self reallySetResolutionTag:0];
}

- (void)reallySetResolutionTag:(int)newResolutionTag;
{
  if (newResolutionTag == resolutionTag)
    return;
  [self willChangeValueForKey:@"resolutionTag"];
  resolutionTag = newResolutionTag;
  [self didChangeValueForKey:@"resolutionTag"];
}

- (void)updateProperties;
{
  if (fileProperties != nil)
    return;
  
  IFEnvironment* env = [[filterController content] settings];
  NSString* fileName = [env valueForKey:@"fileName"];

  NSURL* url = [NSURL fileURLWithPath:(fileName == nil ? @"" : fileName)];
  CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)url, (CFDictionaryRef)[NSDictionary dictionary]);
  if (imageSource != NULL) {
    fileProperties = (NSDictionary*)CGImageSourceCopyPropertiesAtIndex(imageSource,0,NULL);
    CFRelease(imageSource);
  } else
    fileProperties = [[NSDictionary dictionary] retain];      
}

- (void)flushProperties;
{
  NSArray* keys = [NSArray arrayWithObjects:
    @"hasEmbeddedProfile", @"useEmbeddedProfileTitle",
    @"hasEmbeddedResolution", @"useEmbeddedResolutionTitle",
    @"profileNames", @"selectedProfileName",
    nil];
  for (NSString* key in keys)
    [self willChangeValueForKey:key];
  OBJC_RELEASE(fileProperties);
  selectedProfileName = nil;
  for (NSString* key in [keys reverseObjectEnumerator])
    [self didChangeValueForKey:key];
}

@end
