//
//  IFTreeNodeReference.h
//  ImageFlow
//
//  Created by Michel Schinz on 23.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeNode.h"

@interface IFTreeNodeReference : NSObject {
  IFTreeNode* treeNode;
}

+ (id)referenceWithTreeNode:(IFTreeNode*)theTreeNode;
- (id)initWithTreeNode:(IFTreeNode*)theTreeNode;

- (IFTreeNode*)treeNode;

@end
