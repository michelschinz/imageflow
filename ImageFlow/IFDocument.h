//  IFDocument.h
//  ImageFlow
//
//  Created by Michel Schinz on 15.06.05.
//  Copyright Michel Schinz 2005 . All rights reserved.

#import <Cocoa/Cocoa.h>

#import "IFTree.h"
#import "IFTreeNode.h"
#import "IFTreeMark.h"
#import "IFColorProfile.h"
#import "IFExpressionEvaluator.h"
#import "IFTypeChecker.h"

extern NSString* IFTreeChangedNotification;

@class IFDocumentTemplate;
@class IFDocumentTemplateManager;

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

+ (IFDocumentTemplateManager*)documentTemplateManager;

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

// Tree manipulations
- (void)addTree:(IFTreeNode*)newRoot;
- (BOOL)canInsertNode:(IFTreeNode*)parent asParentOf:(IFTreeNode*)child;
- (void)insertNode:(IFTreeNode*)parent asParentOf:(IFTreeNode*)child;
- (BOOL)canInsertNode:(IFTreeNode*)child asChildOf:(IFTreeNode*)parent;
- (void)insertNode:(IFTreeNode*)child asChildOf:(IFTreeNode*)parent;
- (BOOL)canReplaceGhostNode:(IFTreeNode*)ghost usingNode:(IFTreeNode*)replacement;
- (void)replaceGhostNode:(IFTreeNode*)node usingNode:(IFTreeNode*)replacement;
- (void)deleteNode:(IFTreeNode*)node;
- (void)deleteContiguousNodes:(NSSet*)contiguousNodes;

- (NSSet*)allNodes;
- (NSSet*)ancestorsOfNode:(IFTreeNode*)node;
- (NSSet*)nodesOfTreeContainingNode:(IFTreeNode*)node;
- (IFTreeNode*)rootOfTreeContainingNode:(IFTreeNode*)node;
- (NSArray*)pathFromRootTo:(IFTreeNode*)node;

@end
