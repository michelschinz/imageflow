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
  BOOL inlineOnInsertion;
  IFTreeNodeReference* rootRef;
  NSMutableArray* parameterNames;
  NSArray* potentialTypes;
}

+ (id)nodeMacroWithRoot:(IFTreeNode*)theRoot inlineOnInsertion:(BOOL)theInlineOnInsertion;
- (id)initWithRoot:(IFTreeNode*)theRoot inlineOnInsertion:(BOOL)theInlineOnInsertion;

- (BOOL)inlineOnInsertion;
- (IFTreeNode*)root;

- (void)unlinkTree;

@end
