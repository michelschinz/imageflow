//
//  IFFileSourceController.h
//  ImageFlow
//
//  Created by Michel Schinz on 24.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFFilterController.h"

@interface IFFileSourceController : NSObject {
  IBOutlet IFFilterController* filterController;
  IBOutlet NSArrayController* profilesController;
  NSString* selectedProfileName;
  int resolutionTag;
  NSDictionary* fileProperties;
}

- (NSArray*)profileNames;
- (void)setSelectedProfileName:(NSString*)newSelectedProfileName;
- (NSString*)selectedProfileName;

- (BOOL)hasEmbeddedProfile;
- (NSString*)useEmbeddedProfileTitle;

- (BOOL)hasEmbeddedResolution;
- (NSString*)useEmbeddedResolutionTitle;

- (int)resolutionTag;

- (IBAction)browseFile:(id)sender;

@end
