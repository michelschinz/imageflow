//
//  IFAppController.h
//  ImageFlow
//
//  Created by Michel Schinz on 21.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFPreferencesWindowController.h"
#import "IFInspectorWindowController.h"

extern NSString* IFCurrentDocumentDidChangeNotification;
extern NSString* IFNewDocumentKey;

@interface IFAppController : NSObject {
  IBOutlet NSMenu* templatesMenu;
  
  IFPreferencesWindowController* sharedPreferencesController;
  NSMutableSet* inspectorControllers;
}

- (IBAction)showPreferencesPanel:(id)sender;

- (IFInspectorWindowController*)newInspectorOfClass:(Class)class sender:(id)sender;

- (IBAction)newDocumentSettingsInspector:(id)sender;
- (IBAction)newImageInspector:(id)sender;
- (IBAction)newHistogramInspector:(id)sender;

@end
