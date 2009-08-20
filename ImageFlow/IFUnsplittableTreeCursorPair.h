//
//  IFUnsplittableTreeCursorPair.h
//  ImageFlow
//
//  Created by Michel Schinz on 06.11.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeCursorPair.h"

@interface IFUnsplittableTreeCursorPair : IFTreeCursorPair {
  IFTree* tree;
  IFTreeNode* node;
  unsigned index;
}

+ (IFUnsplittableTreeCursorPair*)unsplittableTreeCursorPair;

@end
