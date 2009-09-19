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
  IFEnvironment* env = [[filterController content] settings];
  if ([panel runModalForDirectory:nil file:[env valueForKey:@"fileName"]] != NSOKButton)
    return;

  NSString* fileName = [[panel filenames] objectAtIndex:0];
  [env setValue:fileName forKey:@"fileName"];
}

@end
