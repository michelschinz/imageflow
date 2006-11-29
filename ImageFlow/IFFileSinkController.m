//
//  IFFileSinkController.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFFileSinkController.h"
#import "IFConfiguredFilter.h"

@implementation IFFileSinkController

static NSArray* fileTypes = nil;
static NSArray* fileTypesNames = nil;
static NSDictionary* fileTypesOptions = nil;

+ (NSString*)imageIOLocalizedString:(NSString*)key;
{
  static NSBundle* b = nil;
  if (b == nil)
    b = [NSBundle bundleWithIdentifier:@"com.apple.ImageIO.framework"];
  return [b localizedStringForKey:key value:key table: @"CGImageSource"];
}

+ (void)initialize;
{
  if (self != [IFFileSinkController class])
    return; // avoid repeated initialisation

  fileTypes = (NSArray*)CGImageDestinationCopyTypeIdentifiers();
  fileTypesNames = [(NSArray*)[[self collect] imageIOLocalizedString:[fileTypes each]] retain];
  fileTypesOptions = [[NSDictionary dictionaryWithObjectsAndKeys:
    [NSNumber numberWithInt:1], kUTTypeJPEG,
    [NSNumber numberWithInt:1], kUTTypeJPEG2000,
    [NSNumber numberWithInt:2], kUTTypeTIFF,
    nil] retain];
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey {
  return ![theKey isEqualToString:@"fileTypeIndex"] && [super automaticallyNotifiesObserversForKey:theKey];
}

- (void)awakeFromNib;
{
  [fileTypesController setContent:fileTypesNames];
  [filterController addObserver:self forKeyPath:@"content.environment.fileType" options:0 context:nil];
}

- (void) dealloc;
{
  [filterController removeObserver:self forKeyPath:@"content.environment.fileType"];
  [super dealloc];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  IFEnvironment* env = [(IFConfiguredFilter*)[filterController content] environment];
  NSString* fileType = [env valueForKey:@"fileType"];
  [self willChangeValueForKey:@"fileTypeIndex"];
  fileTypeIndex = [fileTypes indexOfObject:fileType];
  [self didChangeValueForKey:@"fileTypeIndex"];

  [self updateOptionTabIndex];
  
  NSString* newExtension = [(NSString*)UTTypeCopyPreferredTagWithClass((CFStringRef)fileType,kUTTagClassFilenameExtension) autorelease];
  NSString* fileName = [env valueForKey:@"fileName"];
  [env setValue:[[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:newExtension] forKey:@"fileName"];
}

- (int)fileTypeIndex;
{
  return fileTypeIndex;
}

- (void)setFileTypeIndex:(int)newIndex;
{
  [[[filterController content] environment] setValue:[fileTypes objectAtIndex:newIndex] forKey:@"fileType"];
}

- (int)optionTabIndex;
{
  return optionTabIndex;
}

- (void)updateOptionTabIndex;
{
  IFEnvironment* env = [(IFConfiguredFilter*)[filterController content] environment];
  NSString* fileType = [env valueForKey:@"fileType"];
  [self willChangeValueForKey:@"optionTabIndex"];
  NSNumber* boxedOptionTabIndex = [fileTypesOptions objectForKey:fileType];
  optionTabIndex = (boxedOptionTabIndex == nil) ? 0 : [boxedOptionTabIndex intValue];
  [self didChangeValueForKey:@"optionTabIndex"];
}

- (IBAction)browseFile:(id)sender;
{
  IFEnvironment* env = [(IFConfiguredFilter*)[filterController content] environment];

  NSArray* fileNameComponents = [[env valueForKey:@"fileName"] pathComponents];
  NSString* dirName = [NSString pathWithComponents:[fileNameComponents subarrayWithRange:NSMakeRange(0,[fileNameComponents count] - 1)]];
  NSString* fileName = [fileNameComponents lastObject];

  NSSavePanel* panel = [NSSavePanel savePanel];
  [panel setCanCreateDirectories:YES];
  [panel runModalForDirectory:dirName file:fileName];
  
  [env setValue:[panel filename] forKey:@"fileName"];
}

@end
