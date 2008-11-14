//
//  IFSubtree.h
//  ImageFlow
//
//  Created by Michel Schinz on 01.11.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTree.h"

@interface IFSubtree : NSObject<NSCoding> {
  IFTree* baseTree;
  NSSet* includedNodes;
}

+ (id)subtreeOf:(IFTree*)theBaseTree includingNodes:(NSSet*)theIncludedNodes;
- (id)initWithTree:(IFTree*)theBaseTree includingNodes:(NSSet*)theIncludedNodes;

@property(readonly) IFTree* baseTree;
@property(readonly) IFTreeNode* root;
@property(readonly) NSSet* includedNodes;

- (BOOL)containsNode:(IFTreeNode*)node;

- (IFTree*)extractTree;

@end
