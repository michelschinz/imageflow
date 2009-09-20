//  IFDocument.h
//  ImageFlow
//
//  Created by Michel Schinz on 15.06.05.
//  Copyright Michel Schinz 2005 . All rights reserved.

#import <Cocoa/Cocoa.h>

#import "IFTree.h"
#import "IFSubtree.h"
#import "IFTreeNode.h"
#import "IFTypeChecker.h"
#import "IFLayoutParameters.h"

extern NSString* IFTreeChangedNotification;

@interface IFDocument : NSDocument {
  IFTypeChecker* typeChecker;

  NSString* title;
  NSString* authorName;
  NSString* documentDescription;
  NSRect canvasBounds;
  float resolutionX, resolutionY; // in DPI

  IFTree* tree;
  
  IFLayoutParameters* layoutParameters;
}

// MARK: Properties
@property(retain) IFTree* tree;
@property(readonly) NSArray* roots;

@property(copy) NSString* title;
@property(copy) NSString* authorName;
@property(copy) NSString* documentDescription;

@property NSRect canvasBounds;
@property float resolutionX, resolutionY;

@property(readonly) IFLayoutParameters* layoutParameters;

// MARK: Tree navigation
- (NSSet*)allNodes;
- (NSSet*)ancestorsOfNode:(IFTreeNode*)node;
- (NSSet*)nodesOfTreeContainingNode:(IFTreeNode*)node;
- (IFTreeNode*)rootOfTreeContainingNode:(IFTreeNode*)node;
- (NSArray*)pathFromRootTo:(IFTreeNode*)node;

// MARK: Tree manipulations
- (IFTreeNode*)addCloneOfTree:(IFTree*)tree;

- (BOOL)canDeleteSubtree:(IFSubtree*)subtree;
- (IFTreeNode*)deleteSubtree:(IFSubtree*)subtree;

- (BOOL)canCloneTree:(IFTree*)replacement toReplaceGhostNode:(IFTreeNode*)node;
- (IFTreeNode*)cloneTree:(IFTree*)replacement toReplaceGhostNode:(IFTreeNode*)node;
- (BOOL)canInsertCloneOfTree:(IFTree*)tree asChildOfNode:(IFTreeNode*)node;
- (IFTreeNode*)insertCloneOfTree:(IFTree*)tree asChildOfNode:(IFTreeNode*)node;
- (BOOL)canInsertCloneOfTree:(IFTree*)tree asParentOfNode:(IFTreeNode*)node;
- (IFTreeNode*)insertCloneOfTree:(IFTree*)tree asParentOfNode:(IFTreeNode*)node;

- (BOOL)canMoveSubtree:(IFSubtree*)subtree toReplaceGhostNode:(IFTreeNode*)node;
- (void)moveSubtree:(IFSubtree*)subtree toReplaceGhostNode:(IFTreeNode*)node;
- (BOOL)canMoveSubtree:(IFSubtree*)subtree asChildOfNode:(IFTreeNode*)node;
- (void)moveSubtree:(IFSubtree*)subtree asChildOfNode:(IFTreeNode*)node;
- (BOOL)canMoveSubtree:(IFSubtree*)subtree asParentOfNode:(IFTreeNode*)node;
- (void)moveSubtree:(IFSubtree*)subtree asParentOfNode:(IFTreeNode*)node;

- (BOOL)canCreateAliasToNode:(IFTreeNode*)original toReplaceGhostNode:(IFTreeNode*)node;
- (void)createAliasToNode:(IFTreeNode*)original toReplaceGhostNode:(IFTreeNode*)node;

@end
