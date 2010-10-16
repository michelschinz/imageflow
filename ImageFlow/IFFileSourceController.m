//
//  IFFileSourceController.m
//  ImageFlow
//
//  Created by Michel Schinz on 24.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFFileSourceController.h"
#import "IFTreeNodeFilter.h"

@implementation IFFileSourceController

- (IBAction)browseFile:(id)sender;
{
  IFEnvironment* env = [settingsController content];
  NSOpenPanel* panel = [NSOpenPanel openPanel];

  [panel setCanChooseDirectories:NO];
  [panel setAllowsMultipleSelection:NO];
  [panel setDirectoryURL:[env valueForKey:@"fileURL"]];
  if ([panel runModal] == NSOKButton)
    [env setValue:[[panel URLs] objectAtIndex:0] forKey:@"fileURL"];
}

// MARK: NSPathControlDelegate methods

- (NSDragOperation)pathControl:(NSPathControl *)pathControl validateDrop:(id<NSDraggingInfo>)info;
{
  return NSDragOperationLink;
}

- (BOOL)pathControl:(NSPathControl *)pathControl acceptDrop:(id<NSDraggingInfo>)info;
{
	NSURL* url = [NSURL URLFromPasteboard:[info draggingPasteboard]];
	if (url != nil) {
		[pathControl setURL:url];
    return YES;
  } else {
    return NO;
  }
}

@end
