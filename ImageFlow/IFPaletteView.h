//
//  IFPaletteView.h
//  ImageFlow
//
//  Created by Michel Schinz on 08.12.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFNodesView.h"
#import "IFTreeLayoutParameters.h"

@interface IFPaletteView : IFNodesView {
  NSMutableArray* templates;
  NSArray* normalModeTrees;
}

- (IFTreeLayoutParameters*)layoutParameters;

@end
