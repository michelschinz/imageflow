//
//  IFNodesView.h
//  ImageFlow
//
//  Created by Michel Schinz on 08.12.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFGrabableViewMixin.h"
#import "IFTreeLayoutParameters.h"
#import "IFDocument.h"

@interface IFNodesView : NSControl {
  IFGrabableViewMixin* grabableViewMixin;

  IBOutlet IFTreeLayoutParameters* layoutParameters;

  IFDocument* document;  
}

- (void)setDocument:(IFDocument*)document;
- (IFDocument*)document;

- (IFTreeLayoutParameters*)layoutParameters;

@end
