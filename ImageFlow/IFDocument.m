//  IFDocument.m
//  ImageFlow
//
//  Created by Michel Schinz on 15.06.05.
//  Copyright Michel Schinz 2005 . All rights reserved.

#import "IFDocument.h"
#import "IFXMLCoder.h"
#import "IFSingleWindowController.h"
#import "IFExpressionEvaluator.h"
#import "IFDirectoryManager.h"
#import "IFTreeNodeFilter.h"
#import "IFTreeNodeAlias.h"
#import "IFTypeChecker.h"
#import "IFTypeVar.h"
#import "IFFunType.h"

#import <caml/memory.h>
#import <caml/alloc.h>
#import <caml/callback.h>

@interface IFDocument (Private)
- (void)ensureGhostNodes;;
- (void)beginTreeModification;
- (void)endTreeModification;
@end

@implementation IFDocument

NSString* IFTreeChangedNotification = @"IFTreeChanged";

- (id)init 
{
  if (![super init]) return nil;
  typeChecker = [IFTypeChecker sharedInstance];

  tree = [[IFTree tree] retain];
  [tree addNode:[IFTreeNode ghostNodeWithInputArity:0]];
  [self ensureGhostNodes];
  [tree setPropagateNewParentExpressions:YES];
  
  canvasBounds = NSMakeRect(0,0,800,600);
  workingSpaceProfile = nil;
  [self setWorkingSpaceProfile:[IFColorProfile profileDefaultRGB]];
  [self setResolutionX:300];
  [self setResolutionY:300];
  
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(tree);
  OBJC_RELEASE(workingSpaceProfile);
  OBJC_RELEASE(documentDescription);
  OBJC_RELEASE(authorName);
  OBJC_RELEASE(title);
  [super dealloc];
}

- (void)makeWindowControllers;
{
  [self addWindowController:[[[IFSingleWindowController alloc] init] autorelease]];
}

#pragma mark Properties

- (IFTree*)tree;
{
  return tree;
}

- (void)setTree:(IFTree*)newTree;
{
  if (newTree == tree)
    return;

  [self beginTreeModification];
  [tree release];
  tree = [newTree retain];
  [self endTreeModification];
}

- (NSArray*)roots;
{
  return [tree parentsOfNode:[tree root]];
}

@synthesize title, authorName, documentDescription;
@synthesize canvasBounds;
@synthesize workingSpaceProfile;
@synthesize resolutionX, resolutionY;

#pragma mark Tree navigation

- (NSSet*)allNodes;
{
  NSMutableSet* allNodes = [NSMutableSet setWithSet:[tree nodes]];
  [allNodes removeObject:[tree root]];
  return allNodes;
}

- (NSSet*)ancestorsOfNode:(IFTreeNode*)node;
{
  return [NSSet setWithArray:[tree dfsAncestorsOfNode:node]];
}

- (NSSet*)nodesOfTreeContainingNode:(IFTreeNode*)node;
{
  return [NSSet setWithArray:[tree dfsAncestorsOfNode:[self rootOfTreeContainingNode:node]]];
}

- (IFTreeNode*)rootOfTreeContainingNode:(IFTreeNode*)node;
{
  IFTreeNode* grandChild = [tree childOfNode:[tree childOfNode:node]];
  while (grandChild != nil) {
    node = [tree childOfNode:node];
    grandChild = [tree childOfNode:grandChild];
  }
  return node;
}

- (NSArray*)pathFromRootTo:(IFTreeNode*)node;
{
  NSMutableArray* result = [NSMutableArray array];
  IFTreeNode* fakeRoot = [tree root];
  while (node != fakeRoot) {
    [result insertObject:node atIndex:0];
    node = [tree childOfNode:node];
  }
  return result;
}

#pragma mark Tree manipulations

- (IFTreeNode*)addCopyOfTree:(IFTree*)newTree;
{
  NSArray* roots = [self roots];
  int i;
  for (i = [roots count] - 1;
       (i >= 0) && [[roots objectAtIndex:i] isGhost] && ([tree parentsCountOfNode:[roots objectAtIndex:i]] == 0);
       --i)
    ;
  
  [self beginTreeModification];
  IFTreeNode* newRoot = [tree addCopyOfTree:newTree asNewRootAtIndex:i+1];
  [self endTreeModification];
  return newRoot;
}

- (BOOL)canDeleteSubtree:(IFSubtree*)subtree;
{
  return [tree canDeleteSubtree:subtree];
}

- (IFTreeNode*)deleteSubtree:(IFSubtree*)subtree;
{
  [self beginTreeModification];
  IFTreeNode* maybeGhost = [tree deleteSubtree:subtree];
  [self endTreeModification];
  return maybeGhost;
}

- (BOOL)canCopyTree:(IFTree*)replacement toReplaceGhostNode:(IFTreeNode*)node;
{
  NSAssert([node isGhost], @"non-ghost node");
  return [tree canCopyTree:replacement toReplaceNode:node];
}

- (IFTreeNode*)copyTree:(IFTree*)replacement toReplaceGhostNode:(IFTreeNode*)node;
{
  NSAssert([node isGhost], @"non-ghost node");
  [self beginTreeModification];
  IFTreeNode* newRoot = [tree copyTree:replacement toReplaceNode:node];
  [self endTreeModification];
  return newRoot;
}

- (BOOL)canInsertCopyOfTree:(IFTree*)otherTree asChildOfNode:(IFTreeNode*)node;
{
  return [tree canInsertCopyOfTree:otherTree asChildOfNode:node];
}

- (IFTreeNode*)insertCopyOfTree:(IFTree*)otherTree asChildOfNode:(IFTreeNode*)node;
{
  [self beginTreeModification];
  IFTreeNode* newRoot = [tree insertCopyOfTree:otherTree asChildOfNode:node];
  [self endTreeModification];
  return newRoot;
}

- (BOOL)canInsertCopyOfTree:(IFTree*)otherTree asParentOfNode:(IFTreeNode*)node;
{
  return [tree canInsertCopyOfTree:otherTree asParentOfNode:node];
}

- (IFTreeNode*)insertCopyOfTree:(IFTree*)otherTree asParentOfNode:(IFTreeNode*)node;
{
  [self beginTreeModification];
  IFTreeNode* newRoot = [tree insertCopyOfTree:otherTree asParentOfNode:node];
  [self endTreeModification];
  return newRoot;
}

- (BOOL)canMoveSubtree:(IFSubtree*)subtree toReplaceGhostNode:(IFTreeNode*)node;
{
  NSAssert([node isGhost], @"non-ghost node");
  return [tree canMoveSubtree:subtree toReplaceNode:node];
}

- (void)moveSubtree:(IFSubtree*)subtree toReplaceGhostNode:(IFTreeNode*)node;
{
  NSAssert([node isGhost], @"non-ghost node");
  [self beginTreeModification];
  [tree moveSubtree:subtree toReplaceNode:node];
  [self endTreeModification];
}

- (BOOL)canMoveSubtree:(IFSubtree*)subtree asChildOfNode:(IFTreeNode*)node;
{
  return [tree canMoveSubtree:subtree asChildOfNode:node];
}

- (void)moveSubtree:(IFSubtree*)subtree asChildOfNode:(IFTreeNode*)node;
{
  [self beginTreeModification];
  [tree moveSubtree:subtree asChildOfNode:node];
  [self endTreeModification];
}

- (BOOL)canMoveSubtree:(IFSubtree*)subtree asParentOfNode:(IFTreeNode*)node;
{
  return [tree canMoveSubtree:subtree asParentOfNode:node];
}

- (void)moveSubtree:(IFSubtree*)subtree asParentOfNode:(IFTreeNode*)node;
{
  [self beginTreeModification];
  [tree moveSubtree:subtree asParentOfNode:node];
  [self endTreeModification];
}

- (BOOL)canCreateAliasToNode:(IFTreeNode*)original toReplaceGhostNode:(IFTreeNode*)node;
{
  NSAssert([node isGhost], @"non-ghost node");
  return [tree canCreateAliasToNode:(IFTreeNode*)original toReplaceNode:node];
}

- (void)createAliasToNode:(IFTreeNode*)original toReplaceGhostNode:(IFTreeNode*)node;
{
  NSAssert([node isGhost], @"non-ghost node");
  [self beginTreeModification];
  [tree createAliasToNode:original toReplaceNode:node];
  [self endTreeModification];
}

#pragma mark loading and saving

- (BOOL)prepareSavePanel:(NSSavePanel*)savePanel;
{
  NSNib* nibFile = [[NSNib alloc] initWithNibNamed:@"IFSavePanelAccessoryView" bundle:nil];
  NSArray* topLevelObjects;
  [nibFile instantiateNibWithOwner:savePanel topLevelObjects:&topLevelObjects];
  for (int i = 0; i < [topLevelObjects count]; ++i)
    if ([[topLevelObjects objectAtIndex:i] isKindOfClass:[NSView class]])
      [savePanel setAccessoryView:[topLevelObjects objectAtIndex:i]];
  [nibFile release];
  return YES;
}

- (NSFileWrapper*)fileWrapperOfType:(NSString*)typeName error:(NSError**)outError;
{
  NSXMLDocument* xmlDoc = [[IFXMLCoder sharedCoder] encodeDocument:self];
  NSData* xmlData = [xmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
  return [[[NSFileWrapper alloc] initDirectoryWithFileWrappers:[NSDictionary dictionaryWithObjectsAndKeys:
    [[[NSFileWrapper alloc] initRegularFileWithContents:xmlData] autorelease], @"tree.xml",
    nil]] autorelease];
}

- (BOOL)readFromFileWrapper:(NSFileWrapper*)dirWrapper ofType:(NSString*)typeName error:(NSError**)outError;
{
  NSAssert1([dirWrapper isDirectory], @"wrapper is not a directory: %@", dirWrapper);
  
  for (NSFileWrapper* fileWrapper in [[dirWrapper fileWrappers] objectEnumerator]) {
    if ([[fileWrapper filename] isEqualToString:@"tree.xml"]) {
      NSXMLDocument* xmlDoc = [[[NSXMLDocument alloc] initWithData:[fileWrapper regularFileContents]
                                                           options:NSXMLDocumentTidyXML
                                                             error:outError] autorelease];
      if (xmlDoc == nil) return NO;
      [[IFXMLCoder sharedCoder] decodeDocument:xmlDoc into:self];
      [[self undoManager] removeAllActions];
    }
  }
  *outError = nil;
  return YES;
}

@end

@implementation IFDocument (Private)

- (void)ensureGhostNodes;
{
  BOOL hasGhostColumn = NO;
  NSArray* roots = [self roots];
  for (unsigned int i = 0; i < [roots count]; i++) {
    IFTreeNode* root = [roots objectAtIndex:i];
    if ([root isGhost])
      hasGhostColumn |= ([tree parentsCountOfNode:root] == 0);
    else if ([root outputArity] == 1)
      [tree insertCopyOfTree:[IFTree ghostTreeWithArity:1] asChildOfNode:root];
  }
  if (!hasGhostColumn)
    [tree addCopyOfTree:[IFTree ghostTreeWithArity:0] asNewRootAtIndex:[tree parentsCountOfNode:[tree root]]];
}

- (void)beginTreeModification;
{
  NSAssert([tree propagateNewParentExpressions], @"internal error");
  [tree setPropagateNewParentExpressions:NO];
}

- (void)endTreeModification;
{
  NSAssert(![tree propagateNewParentExpressions], @"internal error");
  [self ensureGhostNodes];
  [tree configureNodes];
  [tree setPropagateNewParentExpressions:YES];
  [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:IFTreeChangedNotification object:self] postingStyle:NSPostWhenIdle];  
}

@end
