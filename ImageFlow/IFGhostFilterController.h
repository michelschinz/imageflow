//
//  IFGhostFilterController.h
//  ImageFlow
//
//  Created by Michel Schinz on 24.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFFilterController.h"

@interface IFGhostFilterController : NSObject {
  IBOutlet IFFilterController* filterController;
  NSArrayController* arrayController;
}

- (NSArrayController*)arrayController;

@end
