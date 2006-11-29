//
//  IFPrintSinkController.h
//  ImageFlow
//
//  Created by Michel Schinz on 18.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IFPrintSinkController : NSObject {
  IBOutlet NSObjectController* filterController;
  IBOutlet NSArrayController* printersArrayController;
  IBOutlet NSArrayController* paperSizeArrayController;
}

- (IBAction)browseFile:(id)sender;
- (IBAction)managePrinters:(id)sender;

@end
