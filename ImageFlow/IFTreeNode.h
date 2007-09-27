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
#import "IFGraph.h"

extern const unsigned int ID_NONE;

@interface IFTreeNode : NSObject {
  NSMutableArray* parents;
  IFTreeNode* child; // not retained, to avoid cycles

  NSString* name;
  BOOL isFolded;
  IFExpression* expression;
}

+ (id)ghostNodeWithInputArity:(int)inputArity;

- (IFTreeNode*)cloneNode;
- (IFTreeNode*)cloneNodeAndAncestors;

#pragma mark Hierarchy
- (NSArray*)parents;
- (void)insertObject:(IFTreeNode*)parent inParentsAtIndex:(unsigned int)index;
- (void)removeObjectFromParentsAtIndex:(unsigned int)index;
- (void)replaceObjectInParentsAtIndex:(unsigned int)index withObject:(IFTreeNode*)newParent;
- (IFTreeNode*)child;
- (void)fixChildLinks;
- (NSArray*)dfsAncestors;
- (BOOL)isParentOf:(IFTreeNode*)other;
- (void)replaceByNode:(IFTreeNode*)replacement transformingMarks:(NSArray*)marks;

- (IFGraph*)graph;

#pragma mark Attributes
- (void)setName:(NSString*)newName;
- (NSString*)name;
- (void)setIsFolded:(BOOL)newIsFolded;
- (BOOL)isFolded;
- (BOOL)isGhost;
- (BOOL)isRootOfGhostTree;
- (BOOL)isAlias;
- (IFTreeNode*)original;
- (IFFilter*)filter;
- (IFExpression*)expression;

- (int)inputArity;
- (int)outputArity;
- (NSArray*)potentialTypes;
- (void)beginReconfiguration;
- (void)endReconfigurationWithActiveTypeIndex:(int)typeIndex;

#pragma mark Tree view support
- (NSString*)nameOfParentAtIndex:(int)index;
- (NSString*)label;
- (NSString*)toolTip;

#pragma mark Image view support
- (NSArray*)editingAnnotationsForView:(NSView*)view;
- (void)mouseDown:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
- (void)mouseDragged:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
- (void)mouseUp:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
- (NSArray*)variantNamesForViewing;
- (NSArray*)variantNamesForEditing;
- (IFExpression*)variantNamed:(NSString*)variantName ofExpression:(IFExpression*)originalExpression;
- (NSAffineTransform*)transformForParentAtIndex:(int)index;

#pragma mark -
#pragma mark (protected)
- (void)setExpression:(IFExpression*)newExpression;
- (void)updateExpression;

@end
