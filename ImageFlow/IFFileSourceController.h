//
//  IFFileSourceController.h
//  ImageFlow
//
//  Created by Michel Schinz on 24.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IFFileSourceController : NSObject<NSPathControlDelegate> {
  IBOutlet NSObjectController* settingsController;
}

- (IBAction)browseFile:(id)sender;

@end
