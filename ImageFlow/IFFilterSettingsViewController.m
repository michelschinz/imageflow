//
//  IFFilterSettingsViewController.m
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFFilterSettingsViewController.h"

#import "IFTreeNodeFilter.h"

@interface IFFilterSettingsViewController ()
- (void)updateSettingsView;
- (NSObjectController*)filterControllerForName:(NSString*)filterName;
@end

@implementation IFFilterSettingsViewController

static NSString* IFEditedNodeDidChangeContext = @"IFEditedNodeDidChangeContext";

- (id)init;
{
  if (![super initWithNibName:@"IFFilterSettingsView" bundle:nil])
    return nil;
  filterControllers = [NSMutableDictionary new];
  tabIndices = [NSMutableDictionary new];
  cursorsVar = nil;
  return self;
}

- (void)dealloc;
{
  NSAssert(cursorsVar != nil, @"post-initialization not done");
  [cursorsVar removeObserver:self forKeyPath:@"value.node"];
  OBJC_RELEASE(cursorsVar);
  OBJC_RELEASE(tabIndices);
  OBJC_RELEASE(filterControllers);  
  [super dealloc];
}

- (void)postInitWithCursorsVar:(IFVariable*)theCursorsVar;
{
  NSAssert(cursorsVar == nil, @"repeated post-initialization");
  cursorsVar = [theCursorsVar retain];
  [cursorsVar addObserver:self forKeyPath:@"value.node" options:0 context:IFEditedNodeDidChangeContext];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  if (context == IFEditedNodeDidChangeContext) {
    [self updateSettingsView];
  } else
    NSAssert1(NO, @"unexpected context %@", context);
}

// MARK: -
// MARK: PRIVATE

- (void)updateSettingsView;
{
  IFTreeNode* nodeToEdit = ((IFTreeCursorPair*)cursorsVar.value).node.original;
  if (nodeToEdit == nil)
    return;
  
  NSString* nodeToEditClassName = [nodeToEdit className];
  NSObjectController* filterController = [self filterControllerForName:nodeToEditClassName];
  [filterController setContent:nodeToEdit];
  
  // Select appropriate tab
  NSNumber* tabIndex = [tabIndices objectForKey:nodeToEditClassName];
  if (tabIndex == nil) {
    // TODO when should the nib objects be deallocated? before the filterControllers are deleted (in dealloc), otherwise they still observe the deallocated filter controllers (see error message in log).
    NSArray* nibObjects = [(IFTreeNodeFilter*)nodeToEdit instantiateSettingsNibWithOwner:filterController];
    if (nibObjects == nil)
      tabIndex = [NSNumber numberWithInt:0];
    else {
      NSView* nibView = nil;
      for (id nibObject in nibObjects) {
        if ([nibObject isKindOfClass:[NSView class]]) {
          NSAssert(nibView == nil, @"incorrect number of views in NIB file for filter %@", nodeToEditClassName);
          nibView = nibObject;
        }
      }
      NSAssert(nibView != nil, @"no view in NIB file for filter %@", nodeToEditClassName);
        
      NSTabViewItem* filterSettingsTabViewItem = [[[NSTabViewItem alloc] initWithIdentifier:nil] autorelease];
      [filterSettingsTabViewItem setView:nibView];
      tabIndex = [NSNumber numberWithInt:[tabView numberOfTabViewItems]];
      [tabView insertTabViewItem:filterSettingsTabViewItem atIndex:[tabIndex intValue]];
    }
    [tabIndices setObject:tabIndex forKey:nodeToEditClassName];
  }
  
  NSTabViewItem* item = [tabView tabViewItemAtIndex:[tabIndex intValue]];
  if (item != [tabView selectedTabViewItem]) {
    [tabView selectTabViewItem:item];
  }
}

- (NSObjectController*)filterControllerForName:(NSString*)name;
{
  NSObjectController* controller = [filterControllers objectForKey:name];
  if (controller == nil) {
    controller = [NSObjectController new];
    [filterControllers setObject:controller forKey:name];
    [controller release];
  }
  return controller;
}

@end
