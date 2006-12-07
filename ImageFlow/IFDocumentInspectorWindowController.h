//
//  IFDocumentInspectorWindowController.h
//  ImageFlow
//
//  Created by Michel Schinz on 03.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFInspectorWindowController.h"
#import "IFRectIVarController.h"

@interface IFDocumentInspectorWindowController : IFInspectorWindowController {
  IBOutlet NSObjectController* documentController;
  IBOutlet IFRectIVarController* canvasController;
  IBOutlet NSArrayController* rgbProfilesController;
}

- (IBAction)applySettings:(id)sender;

@end
