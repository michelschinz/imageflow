//
//  IFTreeCursorPair.h
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTree.h"

@interface IFTreeCursorPair : NSObject {
}

- (void)setTree:(IFTree*)newTree node:(IFTreeNode*)newNode index:(unsigned)newIndex;
@property(readonly, retain) IFTree* tree;
@property(readonly, retain) IFTreeNode* node;
@property(readonly) unsigned index;

@property(readonly, retain) IFTree* viewLockedTree;
@property(readonly, retain) IFTreeNode* viewLockedNode;
@property(readonly) unsigned viewLockedIndex;

@property(readonly) BOOL isViewLocked;

@property(readonly) NSAffineTransform* editViewTransform;
@property(readonly) NSAffineTransform* viewEditTransform;

@end
