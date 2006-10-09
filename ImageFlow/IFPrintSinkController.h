//
//  IFPrintSinkController.h
//  ImageFlow
//
//  Created by Michel Schinz on 18.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFFilterController.h"

@interface IFPrintSinkController : NSObject {
  IBOutlet IFFilterController* filterController;
  IBOutlet NSArrayController* printersArrayController;
  IBOutlet NSArrayController* paperSizeArrayController;
}

- (IBAction)browseFile:(id)sender;
- (IBAction)managePrinters:(id)sender;

@end
