//
//  IFFileSinkController.h
//  ImageFlow
//
//  Created by Michel Schinz on 04.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFFilterController.h"

@interface IFFileSinkController : NSObject {
  IBOutlet IFFilterController* filterController;
  IBOutlet NSArrayController* fileTypesController;
  int fileTypeIndex;
  int optionTabIndex;
}

- (int)fileTypeIndex;
- (void)setFileTypeIndex:(int)newIndex;

- (int)optionTabIndex;

- (IBAction)browseFile:(id)sender;

// private
- (void)updateOptionTabIndex;

@end
