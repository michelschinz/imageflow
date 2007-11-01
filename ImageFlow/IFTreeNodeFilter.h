//
//  IFTreeNodeFilter.h
//  ImageFlow
//
//  Created by Michel Schinz on 22.09.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeNode.h"
#import "IFFilter.h"

@interface IFTreeNodeFilter : IFTreeNode {
  BOOL inReconfiguration;
  NSMutableDictionary* parentExpressions;
  IFFilter* filter;
}

+ (id)nodeWithFilter:(IFFilter*)theFilter;
- (id)initWithFilter:(IFFilter*)theFilter;

@end
