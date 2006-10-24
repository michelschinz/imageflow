//
//  IFTreeNodeMacro.h
//  ImageFlow
//
//  Created by Michel Schinz on 13.01.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeNode.h"
#import "IFTreeNodeReference.h"

@interface IFTreeNodeMacro : IFTreeNode {
  IFTreeNodeReference* rootRef;
  NSMutableArray* parameterNames;
}

+ (id)nodeMacroWithRoot:(IFTreeNode*)theRoot;
- (id)initWithRoot:(IFTreeNode*)theRoot;

- (IFTreeNode*)root;

- (void)unlinkTree;

@end
