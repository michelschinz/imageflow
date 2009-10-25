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
  NSOpenPanel* panel = [NSOpenPanel openPanel];
  [panel setCanChooseDirectories:NO];
  [panel setAllowsMultipleSelection:NO];
  IFEnvironment* env = [settingsController content];
  if ([panel runModalForDirectory:nil file:[env valueForKey:@"fileName"]] != NSOKButton)
    return;

  NSString* fileName = [[panel filenames] objectAtIndex:0];
  [env setValue:fileName forKey:@"fileName"];
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
