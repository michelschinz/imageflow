//
//  IFFilterSettingsViewController.h
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeCursorPair.h"
#import "IFVariable.h"

@interface IFFilterSettingsViewController : NSViewController {
  IBOutlet NSTabView* tabView;

  IFVariable* cursorsVar;
  NSMutableDictionary* filterControllers;
  NSMutableDictionary* tabIndices;
}

- (void)postInitWithCursorsVar:(IFVariable*)theCursorsVar;

@end
