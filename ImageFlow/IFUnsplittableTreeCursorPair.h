//
//  IFUnsplittableTreeCursorPair.h
//  ImageFlow
//
//  Created by Michel Schinz on 06.11.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeCursorPair.h"
#import "IFArrayPath.h"

@interface IFUnsplittableTreeCursorPair : IFTreeCursorPair {
  IFTree* tree;
  IFTreeNode* node;
  IFArrayPath* path;
}

+ (IFUnsplittableTreeCursorPair*)unsplittableTreeCursorPair;

@end
