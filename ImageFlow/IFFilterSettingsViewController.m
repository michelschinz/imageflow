//
//  IFFilterSettingsViewController.m
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFFilterSettingsViewController.h"

#import "IFTreeNodeFilter.h"

@interface IFFilterSettingsViewController (Private)
- (void)updateSettingsView;
- (NSObjectController*)filterControllerForName:(NSString*)filterName;
@end

@implementation IFFilterSettingsViewController

static NSString* IFEditedNodeDidChangeContext = @"IFEditedNodeDidChangeContext";

- (id)init;
{
  if (![super initWithNibName:@"IFFilterSettingsView" bundle:nil])
    return nil;
  filterName = @"";
  filterControllers = [NSMutableDictionary new];
  tabIndices = [NSMutableDictionary new];
  panelSizes = [NSMutableDictionary new];  
  cursors = nil;
  return self;
}

- (void)dealloc;
{
  [self setCursorPair:nil];
  OBJC_RELEASE(panelSizes);
  OBJC_RELEASE(tabIndices);
  OBJC_RELEASE(filterControllers);  
  OBJC_RELEASE(filterName);
  [super dealloc];
}

- (void)setCursorPair:(IFTreeCursorPair*)newCursors;
{
  if (cursors != nil) {
    [cursors removeObserver:self forKeyPath:@"node"];
    [cursors release];
  }
  if (newCursors != nil) {
    [newCursors addObserver:self forKeyPath:@"node" options:0 context:IFEditedNodeDidChangeContext];
    [newCursors retain];
  }
  cursors = newCursors;
}

- (NSTabView*)tabView;
{
  return tabView;
}

- (NSString*)filterName;
{
  return filterName;
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  if (context == IFEditedNodeDidChangeContext) {
    [self updateSettingsView];
  } else
    NSAssert1(NO, @"unexpected context %@", context);
}

@end

@implementation IFFilterSettingsViewController (Private)

- (void)setFilterName:(NSString*)newFilterName;
{
  if (newFilterName == filterName)
    return;
  [filterName release];
  filterName = [newFilterName copy];
}

- (void)updateSettingsView;
{
  IFTreeNode* nodeToEdit = cursors.node.original;
  if (nodeToEdit == nil)
    return;
  
  [self setFilterName:[nodeToEdit label]];
  
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
        
      [panelSizes setObject:[NSValue valueWithSize:[nibView bounds].size] forKey:nodeToEditClassName];
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
    [self.view setFrameSize:[[panelSizes objectForKey:nodeToEditClassName] sizeValue]];
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
