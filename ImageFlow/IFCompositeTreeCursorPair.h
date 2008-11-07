//
//  IFCompositeTreeCursorPair.h
//  ImageFlow
//
//  Created by Michel Schinz on 06.11.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeCursorPair.h"

@interface IFCompositeTreeCursorPair : IFTreeCursorPair {
  IFTreeCursorPair* editCursor;
  IFTree* tree;
  IFTreeNode* node;

  IFTreeCursorPair* viewCursor;
  IFTree* viewLockedTree;
  IFTreeNode* viewLockedNode;
}

+ (IFCompositeTreeCursorPair*)compositeWithEditCursor:(IFTreeCursorPair*)theEditCursor viewCursor:(IFTreeCursorPair*)theViewCursor;
- (IFCompositeTreeCursorPair*)initWithEditCursor:(IFTreeCursorPair*)theEditCursor viewCursor:(IFTreeCursorPair*)theViewCursor;

@end
