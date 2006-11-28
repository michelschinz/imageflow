//
//  IFTreeCursorPair.h
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeMark.h"

@interface IFTreeCursorPair : NSObject {
  IFTreeMark* viewMark;
  IFTreeMark* editMark;
  BOOL isViewLocked;
}

+ (id)treeCursorPairWithEditMark:(IFTreeMark*)theEditMark viewMark:(IFTreeMark*)theViewMark;
- (id)initWithEditMark:(IFTreeMark*)theEditMark viewMark:(IFTreeMark*)theViewMark;

- (IFTreeMark*)viewMark;
- (IFTreeMark*)editMark;

- (void)moveToNode:(IFTreeNode*)newNode;

- (void)setIsViewLocked:(BOOL)newValue;
- (BOOL)isViewLocked;

- (IFTreeNode*)viewLockedNode;

@end
