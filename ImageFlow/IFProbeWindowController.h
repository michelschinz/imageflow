//
//  IFProbeWindowController.h
//  ImageFlow
//
//  Created by Michel Schinz on 19.08.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFProbe.h"
#import "IFInspectorWindowController.h"

@interface IFProbeWindowController : IFInspectorWindowController {
  IFProbe* probe;
  NSArray* marks;
  int markIndex, previousMarkIndex;
  NSTimeInterval keyDownEventTimeStamp;
}

- (void)stickToBookmarkIndex:(int)index;
- (IBAction)stickToBookmark:(id)sender;

- (NSArray*)marks;

@end
