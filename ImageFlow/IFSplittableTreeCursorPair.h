//
//  IFSplittableTreeCursorPair.h
//  ImageFlow
//
//  Created by Michel Schinz on 06.11.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFUnsplittableTreeCursorPair.h"

@interface IFSplittableTreeCursorPair : IFUnsplittableTreeCursorPair {
  IFTree* viewLockedTree;
  IFTreeNode* viewLockedNode;
  
  BOOL isViewLocked;
  NSAffineTransform* editViewTransform;
  NSAffineTransform* viewEditTransform;
}

+ (IFSplittableTreeCursorPair*)splittableTreeCursorPair;

@property BOOL isViewLocked;

@end
