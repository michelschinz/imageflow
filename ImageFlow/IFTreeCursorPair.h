//
//  IFTreeCursorPair.h
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTree.h"
#import "IFArrayPath.h"

@interface IFTreeCursorPair : NSObject {
}

- (void)setTree:(IFTree*)newTree node:(IFTreeNode*)newNode path:(IFArrayPath*)newPath;
@property(readonly, retain) IFTree* tree;
@property(readonly, retain) IFTreeNode* node;
@property(readonly, retain) IFArrayPath* path;

@property(readonly, retain) IFTree* viewLockedTree;
@property(readonly, retain) IFTreeNode* viewLockedNode;
@property(readonly, retain) IFArrayPath* viewLockedPath;

@property(readonly, nonatomic) BOOL isViewLocked;

@property(readonly) NSAffineTransform* editViewTransform;
@property(readonly) NSAffineTransform* viewEditTransform;

@end
