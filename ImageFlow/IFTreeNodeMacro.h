//
//  IFTreeNodeMacro.h
//  ImageFlow
//
//  Created by Michel Schinz on 13.01.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeNode.h"

@interface IFTreeNodeMacro : IFTreeNode {
  IFTreeNode* root;
  NSMutableArray* parameterNames;
}

+ (id)nodeMacroForExistingNodes:(NSSet*)nodes root:(IFTreeNode*)root;
+ (id)nodeMacroWithRoot:(IFTreeNode*)theRoot;
- (id)initWithRoot:(IFTreeNode*)theRoot;

- (IFTreeNode*)root;

@end
