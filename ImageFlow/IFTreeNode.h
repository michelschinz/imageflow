//
//  IFTreeNode.h
//  ImageFlow
//
//  Created by Michel Schinz on 20.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpression.h"
#import "IFImageView.h"

@interface IFTreeNode : NSObject<NSCoding> {
  NSString* name;
  NSString* label;
  BOOL isFolded;
  NSArray* cachedTypes;
  unsigned cachedTypesArity;
  IFExpression* expression;
}

+ (IFTreeNode*)ghostNode;
+ (IFTreeNode*)universalSourceWithIndex:(unsigned)index;

// MARK: Properties

@property(retain) NSString* name;
@property BOOL isFolded;
@property(readonly) BOOL isGhost;
@property(readonly) BOOL isAlias;
@property(readonly) BOOL isHole;

@property(readonly) IFTreeNode* original;
@property(readonly) IFEnvironment* settings;
@property(readonly, retain) IFExpression* expression;
- (IFExpression*)expressionForSettings:(IFEnvironment*)altSettings parentExpressions:(NSDictionary*)altParentExpressions activeTypeIndex:(unsigned)altActiveTypeIndex;

- (NSArray*)potentialTypesForArity:(unsigned)arity;

- (void)setParentExpression:(IFExpression*)expression atIndex:(unsigned)index;
- (void)setParentExpressions:(NSDictionary*)expressions activeTypeIndex:(unsigned)newActiveTypeIndex;

// MARK: Tree view support

- (NSString*)nameOfParentAtIndex:(int)index;
@property(readonly, retain) NSString* label;
@property(readonly) NSString* toolTip;

// MARK: Image view support

- (NSArray*)editingAnnotationsForView:(NSView*)view;
- (void)mouseDown:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
- (void)mouseDragged:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
- (void)mouseUp:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
- (NSArray*)variantNamesForViewing;
- (NSArray*)variantNamesForEditing;
- (IFExpression*)variantNamed:(NSString*)variantName ofExpression:(IFExpression*)originalExpression;
- (NSAffineTransform*)transformForParentAtIndex:(int)index;

// MARK: -
// MARK: PROTECTED

- (void)updateLabel;
- (NSString*)computeLabel; // abstract
- (void)clearPotentialTypesCache;
- (NSArray*)computePotentialTypesForArity:(unsigned)arity; // abstract
- (void)updateExpression;
- (IFExpression*)computeExpression; // abstract

@end
