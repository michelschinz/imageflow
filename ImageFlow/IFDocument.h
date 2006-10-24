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
  NSArray* marks;
}

+ (IFDocumentTemplateManager*)documentTemplateManager;

- (IFExpressionEvaluator*)evaluator;

- (NSArray*)roots;

- (NSArray*)marks;
- (IFTreeMark*)cursorMark;

- (NSString*)title;
- (void)setTitle:(NSString*)newTitle;
- (NSString*)authorName;
- (void)setAuthorName:(NSString*)newAuthorName;
- (NSString*)documentDescription;
- (void)setDocumentDescription:(NSString*)newDocumentDescription;
- (NSRect)canvasBounds;

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
- (BOOL)canReplaceNode:(IFTreeNode*)node usingNode:(IFTreeNode*)replacement;
- (void)replaceNode:(IFTreeNode*)node usingNode:(IFTreeNode*)replacement;
- (void)deleteNode:(IFTreeNode*)node;

- (IFTreeNodeMacro*)macroNodeByCopyingNodesOf:(NSSet*)nodes inlineOnInsertion:(BOOL)inlineOnInsertion;
- (void)replaceNodesIn:(NSSet*)nodes byMacroNode:(IFTreeNodeMacro*)macroNode;
- (void)inlineMacroNode:(IFTreeNodeMacro*)node;

- (NSSet*)ancestorsOfNode:(IFTreeNode*)node;
- (NSSet*)nodesOfTreeContainingNode:(IFTreeNode*)node;

@end
