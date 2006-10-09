//
//  IFTreeNodeAlias.h
//  ImageFlow
//
//  Created by Michel Schinz on 22.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeNode.h"

@interface IFTreeNodeAlias : IFTreeNode {
  IFTreeNode* original;
}

+ (id)nodeAliasWithOriginal:(IFTreeNode*)theOriginal;
- (id)initWithOriginal:(IFTreeNode*)theOriginal;

- (IFTreeNode*)original;

@end
