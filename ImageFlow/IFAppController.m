//
//  IFAppController.m
//  ImageFlow
//
//  Created by Michel Schinz on 21.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFAppController.h"
#import "IFDirectoryManager.h"

#import "IFDocumentInspectorWindowController.h"
#import "IFImageInspectorWindowController.h"
#import "IFHistogramInspectorWindowController.h"
#import "IFCacheInspectorWindowController.h"

#import "IFPercentValueTransformer.h"
#import "IFProfileNamePathValueTransformer.h"

#import "IFEmptyCIFilter.h"
#import "IFCropImageWithMaskCIFilter.h"
#import "IFEmptyCIFilter.h"
#import "IFMaskCIFilter.h"
#import "IFSetAlphaCIFilter.h"
#import "IFSingleColorCIFilter.h"
#import "IFThresholdCIFilter.h"
#import "IFCircleGeneratorCIFilter.h"

@implementation IFAppController

- (id)init;
{
  if (![super init])
    return nil;
  inspectorControllers = [NSMutableSet new];
  sharedPreferencesController = nil;
  return self;
}

- (void) dealloc {
  [inspectorControllers release];
  inspectorControllers = nil;
  [super dealloc];
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification;
{
  // Register value transformers
  [IFPercentValueTransformer class];
  [IFProfileNamePathValueTransformer class];
  
  // Register filters
  [IFEmptyCIFilter class];
  [IFCropImageWithMaskCIFilter class];
  [IFEmptyCIFilter class];
  [IFMaskCIFilter class];
  [IFSetAlphaCIFilter class];
  [IFSingleColorCIFilter class];
  [IFThresholdCIFilter class];
  [IFCircleGeneratorCIFilter class];
  
  NSFileManager* fileMgr = [NSFileManager defaultManager];
  IFDirectoryManager* dirMgr = [IFDirectoryManager sharedDirectoryManager];
  
  // Setup template directory, if needed
  NSString* templatesPath = [[IFDirectoryManager sharedDirectoryManager] templatesDirectory];
  if (![fileMgr fileExistsAtPath:templatesPath])
    [fileMgr copyPath:[dirMgr sourceTemplatesDirectory] toPath:templatesPath handler:nil];
  
  // Setup templates menu
  NSString* docTemplatesPath = [dirMgr documentTemplatesDirectory];
  NSArray* templateFiles = [fileMgr directoryContentsAtPath:docTemplatesPath];
  for (int i = 0; i < [templateFiles count]; ++i) {
    NSString* templateName = [templateFiles objectAtIndex:i];
    NSMenuItem* newItem = [templatesMenu addItemWithTitle:templateName action:@selector(newDocumentFromTemplate:) keyEquivalent:@""];
    [newItem setRepresentedObject:[docTemplatesPath stringByAppendingPathComponent:templateName]];
  }
  
  // Configure color wells
  [NSColor setIgnoresAlpha:NO];
}

- (IBAction)showPreferencesPanel:(id)sender;
{
  if (sharedPreferencesController == nil)
    sharedPreferencesController = [IFPreferencesWindowController new];
  [sharedPreferencesController showWindow:self];
}

- (void)newDocumentFromTemplate:(id)sender;
{
  NSDocumentController* documentController = [NSDocumentController sharedDocumentController];
  NSString* docType = [documentController defaultType];
  NSError* error;
  IFDocument* doc = [documentController openUntitledDocumentAndDisplay:YES error:&error];
  if (doc == nil) {
    [documentController presentError:error];
    return;
  }
  NSURL* docURL = [NSURL fileURLWithPath:[sender representedObject]];
  [doc readFromURL:docURL ofType:docType error:&error];
  if (error != nil) {
    [documentController presentError:error];
    return;
  }
  [[doc undoManager] removeAllActions];
}

- (IFInspectorWindowController*)newInspectorOfClass:(Class)class sender:(id)sender;
{
  IFInspectorWindowController* controller = [class new];
  [controller showWindow:sender];
  [inspectorControllers addObject:controller];
  [controller release];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inspectorWindowWillClose:) name:NSWindowWillCloseNotification object:[controller window]];
  
  return controller;
}

- (void)inspectorWindowWillClose:(NSNotification*)notification;
{
  NSWindow* window = [notification object];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:window];  
  NSAssert([inspectorControllers containsObject:[window windowController]], @"unexpected window");
  [inspectorControllers removeObject:[window windowController]];
}

- (IBAction)newDocumentSettingsInspector:(id)sender;
{
  [self newInspectorOfClass:[IFDocumentInspectorWindowController class] sender:sender];
}

- (IBAction)newImageInspector:(id)sender;
{
  [self newInspectorOfClass:[IFImageInspectorWindowController class] sender:sender];
}

- (IBAction)newHistogramInspector:(id)sender;
{
  [self newInspectorOfClass:[IFHistogramInspectorWindowController class] sender:sender];
}

- (IBAction)newCacheInspector:(id)sender;
{
  [self newInspectorOfClass:[IFCacheInspectorWindowController class] sender:sender];  
}

@end
