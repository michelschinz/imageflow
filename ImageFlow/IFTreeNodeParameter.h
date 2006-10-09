//
//  IFTreeNodeParameter.h
//  ImageFlow
//
//  Created by Michel Schinz on 03.02.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeNode.h"

@interface IFTreeNodeParameter : IFTreeNode {
  int index;
}

+ (id)nodeParameterWithIndex:(int)index;
- (id)initWithIndex:(int)index;

- (void)setIndex:(int)newIndex;
- (int)index;

@end
