//
//  IFCacheInspectorWindowController.h
//  ImageFlow
//
//  Created by Michel Schinz on 15.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFInspectorWindowController.h"

@interface IFCacheInspectorWindowController : IFInspectorWindowController {
  IBOutlet NSObjectController* cacheObjectController;
}

@end
