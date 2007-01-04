//
//  IFTreeNode.h
//  ImageFlow
//
//  Created by Michel Schinz on 20.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFConfiguredFilter.h"
#import "IFType.h"

extern const unsigned int ID_NONE;

@interface IFTreeNode : NSObject {
  NSString* name;
  BOOL isFolded;
  IFConfiguredFilter* filter;
  IFExpression* expression;

  NSMutableArray* parents;
  IFTreeNode* child; // not retained, to avoid cycles
}

+ (id)nodeWithFilter:(IFConfiguredFilter*)theFilter;
- (id)initWithFilter:(IFConfiguredFilter*)theFilter;
- (IFTreeNode*)cloneNode;
- (IFTreeNode*)cloneNodeAndAncestors;

- (NSArray*)parents;
- (void)insertObject:(IFTreeNode*)parent inParentsAtIndex:(unsigned int)index;
- (void)removeObjectFromParentsAtIndex:(unsigned int)index;
- (void)replaceObjectInParentsAtIndex:(unsigned int)index withObject:(IFTreeNode*)newParent;
- (IFTreeNode*)child;

- (IFConfiguredFilter*)filter;
- (NSArray*)potentialTypes;
- (IFExpression*)expression;

- (void)setName:(NSString*)newName;
- (NSString*)name;

- (void)setIsFolded:(BOOL)newIsFolded;
- (BOOL)isFolded;

- (BOOL)isGhost;
- (BOOL)isAlias;
- (BOOL)acceptsParents:(int)inputCount;
- (BOOL)acceptsChildren:(int)outputCount;

- (NSSet*)ancestors;
- (BOOL)isParentOf:(IFTreeNode*)other;

- (void)replaceByNode:(IFTreeNode*)replacement transformingMarks:(NSArray*)marks;

// protected
- (void)setExpression:(IFExpression*)newExpression;
- (void)updateExpression;

- (void)setChild:(IFTreeNode*)newChild;

// debugging
- (void)debugCheckLinks;

@end
