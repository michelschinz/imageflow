//
//  IFFilterMacro.h
//  ImageFlow
//
//  Created by Michel Schinz on 20.01.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFFilter.h"
#import "IFTreeNodeMacro.h"

@interface IFFilterMacro : IFFilter {
  IFTreeNode* macroRoot; // not retained
}

+ (id)filterWithMacroRoot:(IFTreeNode*)theMacroRoot;
- (id)initWithMacroRoot:(IFTreeNode*)theMacroRoot;

@end
