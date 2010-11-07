//
//  IFSplittableTreeCursorPair.h
//  ImageFlow
//
//  Created by Michel Schinz on 06.11.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFUnsplittableTreeCursorPair.h"
#import "IFArrayPath.h"

@interface IFSplittableTreeCursorPair : IFTreeCursorPair {
  IFTree* tree;
  IFTreeNode* node;
  IFArrayPath* path;

  IFTree* viewLockedTree;
  IFTreeNode* viewLockedNode;
  IFArrayPath* viewLockedPath;

  BOOL isViewLocked;
  NSAffineTransform* editViewTransform;
  NSAffineTransform* viewEditTransform;
}

+ (IFSplittableTreeCursorPair*)splittableTreeCursorPair;

@property(nonatomic) BOOL isViewLocked;

@end
