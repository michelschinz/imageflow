//
//  IFTreeMark.h
//  ImageFlow
//
//  Created by Michel Schinz on 17.07.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeNode.h"

@interface IFTreeMark : NSObject {
  IFTreeNode* node;
}

+ (id)mark;

- (BOOL)isSet;

- (IFTreeNode*)node;
- (void)setNode:(IFTreeNode*)newNode;
- (void)setNode:(IFTreeNode*)newNode ifCurrentNodeIs:(IFTreeNode*)maybeCurrentNode;

- (void)setLikeMark:(IFTreeMark*)otherMark;
- (void)unset;

@end
