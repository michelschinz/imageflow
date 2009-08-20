//
//  IFSplittableTreeCursorPair.h
//  ImageFlow
//
//  Created by Michel Schinz on 06.11.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFUnsplittableTreeCursorPair.h"

@interface IFSplittableTreeCursorPair : IFTreeCursorPair {
  IFTree* tree;
  IFTreeNode* node;
  unsigned index;
  
  IFTree* viewLockedTree;
  IFTreeNode* viewLockedNode;
  unsigned viewLockedIndex;
  
  BOOL isViewLocked;
  NSAffineTransform* editViewTransform;
  NSAffineTransform* viewEditTransform;
}

+ (IFSplittableTreeCursorPair*)splittableTreeCursorPair;

@property BOOL isViewLocked;

@end
