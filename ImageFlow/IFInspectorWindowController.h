//
//  IFInspectorWindowController.h
//  ImageFlow
//
//  Created by Michel Schinz on 05.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFDocument.h"

@interface IFInspectorWindowController : NSWindowController {

}

- (void)documentDidChange:(IFDocument*)newDocument;

@end
