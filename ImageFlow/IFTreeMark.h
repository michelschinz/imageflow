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
  NSString* tag;
  IFTreeNode* node;
}

+ (id)markWithTag:(NSString*)theTag;
+ (id)markWithTag:(NSString*)theTag node:(IFTreeNode*)theNode;
- (id)initWithTag:(NSString*)theTag node:(IFTreeNode*)theNode;

- (BOOL)isSet;

- (NSString*)tag;

- (IFTreeNode*)node;
- (void)setNode:(IFTreeNode*)newNode;
- (void)setNode:(IFTreeNode*)newNode ifCurrentNodeIs:(IFTreeNode*)maybeCurrentNode;

- (void)setLikeMark:(IFTreeMark*)otherMark;
- (void)unset;

@end
