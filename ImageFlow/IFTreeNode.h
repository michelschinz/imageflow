//
//  IFTreeNode.h
//  ImageFlow
//
//  Created by Michel Schinz on 20.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFFilter.h"
#import "IFType.h"

extern const unsigned int ID_NONE;

@interface IFTreeNode : NSObject {
  NSString* name;
  BOOL isFolded;
  BOOL inReconfiguration;
  IFFilter* filter;
  IFExpression* expression;

  NSMutableArray* parents;
  IFTreeNode* child; // not retained, to avoid cycles
}

+ (id)nodeWithFilter:(IFFilter*)theFilter;
- (id)initWithFilter:(IFFilter*)theFilter;
- (IFTreeNode*)cloneNode;
- (IFTreeNode*)cloneNodeAndAncestors;

// hierarchy
- (NSArray*)parents;
- (void)insertObject:(IFTreeNode*)parent inParentsAtIndex:(unsigned int)index;
- (void)removeObjectFromParentsAtIndex:(unsigned int)index;
- (void)replaceObjectInParentsAtIndex:(unsigned int)index withObject:(IFTreeNode*)newParent;
- (IFTreeNode*)child;
- (void)fixChildLinks;
- (NSArray*)dfsAncestors;
- (NSArray*)topologicallySortedAncestorsWithoutAliases;
- (BOOL)isParentOf:(IFTreeNode*)other;

// attributes
- (void)setName:(NSString*)newName;
- (NSString*)name;
- (void)setIsFolded:(BOOL)newIsFolded;
- (BOOL)isFolded;
- (BOOL)isGhost;
- (BOOL)isAlias;
- (IFTreeNode*)original;
- (IFFilter*)filter;
- (IFExpression*)expression;

- (int)inputArity;
- (int)outputArity;
- (NSArray*)potentialTypes;
- (void)beginReconfiguration;
- (void)endReconfigurationWithActiveTypeIndex:(int)typeIndex;

- (void)replaceByNode:(IFTreeNode*)replacement transformingMarks:(NSArray*)marks;

// protected
- (void)setExpression:(IFExpression*)newExpression;
- (void)updateExpression;

@end
