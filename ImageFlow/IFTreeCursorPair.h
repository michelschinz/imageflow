//
//  IFTreeCursorPair.h
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTree.h"
#import "IFTreeMark.h"

@interface IFTreeCursorPair : NSObject {
  IFTree* tree;
  IFTreeMark* viewMark;
  IFTreeMark* editMark;
  BOOL isViewLocked;
  NSAffineTransform* editViewTransform;
  NSAffineTransform* viewEditTransform;
}

+ (IFTreeCursorPair*)treeCursorPairWithTree:(IFTree*)theTree editMark:(IFTreeMark*)theEditMark viewMark:(IFTreeMark*)theViewMark;
- (IFTreeCursorPair*)initWithTree:(IFTree*)theTree editMark:(IFTreeMark*)theEditMark viewMark:(IFTreeMark*)theViewMark;

- (IFTreeMark*)viewMark;
- (IFTreeMark*)editMark;

- (void)moveToNode:(IFTreeNode*)newNode;

- (void)setIsViewLocked:(BOOL)newValue;
- (BOOL)isViewLocked;

- (IFTreeNode*)viewLockedNode;

- (NSAffineTransform*)editViewTransform;
- (NSAffineTransform*)viewEditTransform;

@end
