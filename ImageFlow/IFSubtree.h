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

- (IFTree*)baseTree;
- (IFTreeNode*)root;
- (NSSet*)includedNodes;

- (BOOL)containsNode:(IFTreeNode*)node;

- (unsigned)inputArity;
- (NSArray*)sortedParentsOfInputNodes;

- (IFTree*)extractTree;

@end
