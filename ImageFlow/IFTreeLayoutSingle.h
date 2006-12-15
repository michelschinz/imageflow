//
//  IFTreeLayoutSingle.h
//  ImageFlow
//
//  Created by Michel Schinz on 15.07.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeLayoutElement.h"

@interface IFTreeLayoutSingle : IFTreeLayoutElement {
  IFTreeNode* node; // not retained
  NSBezierPath* outlinePath;
}

+ (id)layoutSingleWithNode:(IFTreeNode*)theNode containingView:(IFNodesView*)containingView;
- (id)initWithNode:(IFTreeNode*)theNode containingView:(IFNodesView*)containingView;

- (void)setOutlinePath:(NSBezierPath*)newOutlinePath;
- (NSBezierPath*)outlinePath;

- (IFTreeLayoutElementKind)kind;

@end
