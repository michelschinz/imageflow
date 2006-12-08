//
//  IFPaletteView.h
//  ImageFlow
//
//  Created by Michel Schinz on 08.12.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeLayoutParameters.h"

@interface IFPaletteView : NSView {
  IBOutlet IFTreeLayoutParameters* layoutParameters;

  NSArray* candidates;
}

@end
