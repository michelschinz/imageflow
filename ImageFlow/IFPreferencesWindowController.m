//
//  IFPreferencesWindowController.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFPreferencesWindowController.h"
#import "IFColorProfile.h"

@implementation IFPreferencesWindowController

- (id)init;
{
  if (![super initWithWindowNibName:@"IFPreferences"])
    return nil;
  return self;
}

- (void)windowDidLoad;
{
}

@end
