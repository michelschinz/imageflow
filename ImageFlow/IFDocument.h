//  IFDocument.h
//  ImageFlow
//
//  Created by Michel Schinz on 15.06.05.
//  Copyright Michel Schinz 2005 . All rights reserved.

#import <Cocoa/Cocoa.h>

#import "IFTree.h"
#import "IFSubtree.h"
#import "IFTreeNode.h"
#import "IFTreeMark.h"
#import "IFColorProfile.h"
#import "IFExpressionEvaluator.h"
#import "IFTypeChecker.h"

extern NSString* IFTreeChangedNotification;

@interface IFDocument : NSDocument {
  IFTypeChecker* typeChecker;
  IFExpressionEvaluator* evaluator;

  NSString* title;
  NSString* authorName;
  NSString* documentDescription;
  NSRect canvasBounds;
  IFColorProfile* workingSpaceProfile;
  float resolutionX, resolutionY; // in DPI

  IFTree* tree;
}

- (IFExpressionEvaluator*)evaluator;

- (IFTree*)tree;
- (NSArray*)roots;

- (NSString*)title;
- (void)setTitle:(NSString*)newTitle;
- (NSString*)authorName;
- (void)setAuthorName:(NSString*)newAuthorName;
- (NSString*)documentDescription;
- (void)setDocumentDescription:(NSString*)newDocumentDescription;

- (NSRect)canvasBounds;
- (void)setCanvasBounds:(NSRect)newCanvasBounds;

- (IFColorProfile*)workingSpaceProfile;
- (void)setWorkingSpaceProfile:(IFColorProfile*)newProfile;

- (float)resolutionX;
- (void)setResolutionX:(float)newResolutionX;
- (float)resolutionY;
- (void)setResolutionY:(float)newResolutionY;

#pragma mark Tree navigation

- (NSSet*)allNodes;
- (NSSet*)ancestorsOfNode:(IFTreeNode*)node;
- (NSSet*)nodesOfTreeContainingNode:(IFTreeNode*)node;
- (IFTreeNode*)rootOfTreeContainingNode:(IFTreeNode*)node;
- (NSArray*)pathFromRootTo:(IFTreeNode*)node;

#pragma mark Tree manipulations

- (void)addCopyOfTree:(IFTree*)tree;
- (void)deleteSubtree:(IFSubtree*)subtree;
- (void)deleteNode:(IFTreeNode*)node;

- (BOOL)canCopyTree:(IFTree*)replacement toReplaceGhostNode:(IFTreeNode*)node;
- (void)copyTree:(IFTree*)replacement toReplaceGhostNode:(IFTreeNode*)node;
- (BOOL)canInsertCopyOfTree:(IFTree*)tree asChildOfNode:(IFTreeNode*)node;
- (void)insertCopyOfTree:(IFTree*)tree asChildOfNode:(IFTreeNode*)node;
- (BOOL)canInsertCopyOfTree:(IFTree*)tree asParentOfNode:(IFTreeNode*)node;
- (void)insertCopyOfTree:(IFTree*)tree asParentOfNode:(IFTreeNode*)node;

- (BOOL)canMoveSubtree:(IFSubtree*)subtree toReplaceGhostNode:(IFTreeNode*)node;
- (void)moveSubtree:(IFSubtree*)subtree toReplaceGhostNode:(IFTreeNode*)node;
- (BOOL)canMoveSubtree:(IFSubtree*)subtree asChildOfNode:(IFTreeNode*)node;
- (void)moveSubtree:(IFSubtree*)subtree asChildOfNode:(IFTreeNode*)node;
- (BOOL)canMoveSubtree:(IFSubtree*)subtree asParentOfNode:(IFTreeNode*)node;
- (void)moveSubtree:(IFSubtree*)subtree asParentOfNode:(IFTreeNode*)node;

- (BOOL)canCreateAliasToNode:(IFTreeNode*)original toReplaceGhostNode:(IFTreeNode*)node;
- (void)createAliasToNode:(IFTreeNode*)original toReplaceGhostNode:(IFTreeNode*)node;

@end
