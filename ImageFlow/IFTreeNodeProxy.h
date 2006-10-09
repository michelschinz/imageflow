//
//  IFTreeNodeProxy.h
//  ImageFlow
//
//  Created by Michel Schinz on 29.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFDocument.h"
#import "IFTreeNode.h"

@interface IFTreeNodeProxy : NSObject<NSCoding> {
  IFDocument* document;
  IFTreeNode* node;
}

+ (id)proxyForNode:(IFTreeNode*)theNode ofDocument:(IFDocument*)theDocument;
- (id)initForNode:(IFTreeNode*)theNode ofDocument:(IFDocument*)theDocument;

- (IFDocument*)document;
- (IFTreeNode*)node;

@end
