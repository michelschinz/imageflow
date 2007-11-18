//
//  IFTreeLayoutGhost.h
//  ImageFlow
//
//  Created by Michel Schinz on 14.07.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeLayoutSingle.h"
#import "IFTreeNodeFilter.h"

@interface IFTreeLayoutGhost : IFTreeLayoutSingle {
  BOOL activated;
  NSArrayController* arrayController;
  NSTextFieldCell* textCell;
}

+ (NSArrayController*)arrayControllerForNode:(IFTreeNode*)filter;

- (id)initWithNode:(IFTreeNode*)theNode containingView:(IFNodesView*)theContainingView;

@end
