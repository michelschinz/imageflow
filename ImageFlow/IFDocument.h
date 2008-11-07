//  IFDocument.h
//  ImageFlow
//
//  Created by Michel Schinz on 15.06.05.
//  Copyright Michel Schinz 2005 . All rights reserved.

#import <Cocoa/Cocoa.h>

#import "IFTree.h"
#import "IFSubtree.h"
#import "IFTreeNode.h"
#import "IFColorProfile.h"
#import "IFTypeChecker.h"

extern NSString* IFTreeChangedNotification;

@interface IFDocument : NSDocument {
  IFTypeChecker* typeChecker;

  NSString* title;
  NSString* authorName;
  NSString* documentDescription;
  NSRect canvasBounds;
  IFColorProfile* workingSpaceProfile;
  float resolutionX, resolutionY; // in DPI

  IFTree* tree;
}

#pragma mark Properties

@property(retain) IFTree* tree;
@property(readonly) NSArray* roots;

@property(copy) NSString* title;
@property(copy) NSString* authorName;
@property(copy) NSString* documentDescription;

@property NSRect canvasBounds;
@property(retain) IFColorProfile* workingSpaceProfile;
@property float resolutionX, resolutionY;

#pragma mark Tree navigation

- (NSSet*)allNodes;
- (NSSet*)ancestorsOfNode:(IFTreeNode*)node;
- (NSSet*)nodesOfTreeContainingNode:(IFTreeNode*)node;
- (IFTreeNode*)rootOfTreeContainingNode:(IFTreeNode*)node;
- (NSArray*)pathFromRootTo:(IFTreeNode*)node;

#pragma mark Tree manipulations

- (IFTreeNode*)addCopyOfTree:(IFTree*)tree;

- (BOOL)canDeleteSubtree:(IFSubtree*)subtree;
- (void)deleteSubtree:(IFSubtree*)subtree;

- (BOOL)canCopyTree:(IFTree*)replacement toReplaceGhostNode:(IFTreeNode*)node;
- (IFTreeNode*)copyTree:(IFTree*)replacement toReplaceGhostNode:(IFTreeNode*)node;
- (BOOL)canInsertCopyOfTree:(IFTree*)tree asChildOfNode:(IFTreeNode*)node;
- (IFTreeNode*)insertCopyOfTree:(IFTree*)tree asChildOfNode:(IFTreeNode*)node;
- (BOOL)canInsertCopyOfTree:(IFTree*)tree asParentOfNode:(IFTreeNode*)node;
- (IFTreeNode*)insertCopyOfTree:(IFTree*)tree asParentOfNode:(IFTreeNode*)node;

- (BOOL)canMoveSubtree:(IFSubtree*)subtree toReplaceGhostNode:(IFTreeNode*)node;
- (void)moveSubtree:(IFSubtree*)subtree toReplaceGhostNode:(IFTreeNode*)node;
- (BOOL)canMoveSubtree:(IFSubtree*)subtree asChildOfNode:(IFTreeNode*)node;
- (void)moveSubtree:(IFSubtree*)subtree asChildOfNode:(IFTreeNode*)node;
- (BOOL)canMoveSubtree:(IFSubtree*)subtree asParentOfNode:(IFTreeNode*)node;
- (void)moveSubtree:(IFSubtree*)subtree asParentOfNode:(IFTreeNode*)node;

- (BOOL)canCreateAliasToNode:(IFTreeNode*)original toReplaceGhostNode:(IFTreeNode*)node;
- (void)createAliasToNode:(IFTreeNode*)original toReplaceGhostNode:(IFTreeNode*)node;

@end
