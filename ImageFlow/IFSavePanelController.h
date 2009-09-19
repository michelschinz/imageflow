//
//  IFSavePanelController.h
//  ImageFlow
//
//  Created by Michel Schinz on 14.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IFSavePanelController : NSObject<NSOpenSavePanelDelegate> {
  IBOutlet NSObject* savePanel;
  IBOutlet NSMatrix* directoryMatrix;
  int directoryIndex;
}

- (int)directoryIndex;
- (void)setDirectoryIndex:(int)newIndex;

@end
