//  IFDocument.h
//  ImageFlow
//
//  Created by Michel Schinz on 15.06.05.
//  Copyright Michel Schinz 2005 . All rights reserved.

#import <Cocoa/Cocoa.h>

#import "IFTreeNode.h"
#import "IFTreeMark.h"
#import "IFColorProfile.h"
#import "IFExpressionEvaluator.h"
#import "IFTreeNodeMacro.h"

extern NSString* IFTreeChangedNotification;

@class IFDocumentTemplate;
@class IFDocumentTemplateManager;

@interface IFDocument : NSDocument {
  IFExpressionEvaluator* evaluator;

  NSString* title;
  NSString* authorName;
  NSString* documentDescription;
  NSRect canvasBounds;
  IFColorProfile* workingSpaceProfile;
  float resolutionX, resolutionY; // in DPI
  
  IFTreeNode* fakeRoot;
}

+ (IFDocumentTemplateManager*)documentTemplateManager;

- (IFExpressionEvaluator*)evaluator;

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
- (void)replaceGhostNode:(IFTreeNode*)node usingNode:(IFTreeNode*)replacement transformingMarks:(NSArray*)marks;
- (void)deleteNode:(IFTreeNode*)node transformingMarks:(NSArray*)marks;
- (void)deleteContiguousNodes:(NSSet*)contiguousNodes transformingMarks:(NSArray*)marks;

- (IFTreeNodeMacro*)macroNodeByCopyingNodesOf:(NSSet*)nodes inlineOnInsertion:(BOOL)inlineOnInsertion;
- (void)replaceNodesIn:(NSSet*)nodes byMacroNode:(IFTreeNodeMacro*)macroNode;
- (void)inlineMacroNode:(IFTreeNodeMacro*)macroNode transformingMarks:(NSArray*)marks;

- (NSSet*)allNodes;
- (NSSet*)ancestorsOfNode:(IFTreeNode*)node;
- (NSSet*)nodesOfTreeContainingNode:(IFTreeNode*)node;
- (IFTreeNode*)rootOfTreeContainingNode:(IFTreeNode*)node;
- (NSArray*)pathFromRootTo:(IFTreeNode*)node;
- (NSSet*)aliasesForNodes:(NSSet*)nodes;

@end
