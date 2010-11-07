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
#import "IFAction.h"

#import <caml/memory.h>
#import <caml/alloc.h>
#import <caml/callback.h>

@interface IFDocument ()
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
  [tree addNode:[IFTreeNode ghostNode]];
  [self ensureGhostNodes];
  [tree setPropagateNewParentExpressions:YES];
  
  canvasBounds = NSMakeRect(0,0,800,600);
  [self setResolutionX:300];
  [self setResolutionY:300];
  
  layoutParameters = [IFLayoutParameters layoutParameters];
  
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(layoutParameters);
  OBJC_RELEASE(tree);
  OBJC_RELEASE(documentDescription);
  OBJC_RELEASE(authorName);
  OBJC_RELEASE(title);
  [super dealloc];
}

- (void)makeWindowControllers;
{
  [self addWindowController:[[[IFSingleWindowController alloc] init] autorelease]];
}

// MARK: Properties

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
@synthesize resolutionX, resolutionY;

@synthesize layoutParameters;

// MARK: Actions

- (IBAction)exportAllFiles:(id)sender;
{
  IFExpressionEvaluator* evaluator = [IFExpressionEvaluator sharedEvaluator];
  
  NSMutableArray* exportActions = [NSMutableArray array];
  for (IFTreeNode* root in self.roots) {
    // TODO: check that the action is of the right kind
    IFConstantExpression* rootExpression = [evaluator evaluateExpression:root.expression];
    if (rootExpression.isAction)
      [exportActions addObject:rootExpression.object];
  }

  for (IFAction* action in exportActions)
    [action execute];
}

// MARK: Tree navigation

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

// MARK: Tree manipulations

- (IFTreeNode*)addCloneOfTree:(IFTree*)newTree;
{
  NSArray* roots = [self roots];
  int i;
  for (i = [roots count] - 1;
       (i >= 0) && [[roots objectAtIndex:i] isGhost] && ([tree parentsCountOfNode:[roots objectAtIndex:i]] == 0);
       --i)
    ;
  
  [self beginTreeModification];
  IFTreeNode* newRoot = [tree addCloneOfTree:newTree asNewRootAtIndex:i+1];
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

- (BOOL)canCloneTree:(IFTree*)replacement toReplaceGhostNode:(IFTreeNode*)node;
{
  NSAssert([node isGhost], @"non-ghost node");
  return [tree canCloneTree:replacement toReplaceNode:node];
}

- (IFTreeNode*)cloneTree:(IFTree*)replacement toReplaceGhostNode:(IFTreeNode*)node;
{
  NSAssert([node isGhost], @"non-ghost node");
  [self beginTreeModification];
  IFTreeNode* newRoot = [tree cloneTree:replacement toReplaceNode:node];
  [self endTreeModification];
  return newRoot;
}

- (BOOL)canInsertCloneOfTree:(IFTree*)otherTree asChildOfNode:(IFTreeNode*)node;
{
  return [tree canInsertCloneOfTree:otherTree asChildOfNode:node];
}

- (IFTreeNode*)insertCloneOfTree:(IFTree*)otherTree asChildOfNode:(IFTreeNode*)node;
{
  [self beginTreeModification];
  IFTreeNode* newRoot = [tree insertCloneOfTree:otherTree asChildOfNode:node];
  [self endTreeModification];
  return newRoot;
}

- (BOOL)canInsertCloneOfTree:(IFTree*)otherTree asParentOfNode:(IFTreeNode*)node;
{
  return [tree canInsertCloneOfTree:otherTree asParentOfNode:node];
}

- (IFTreeNode*)insertCloneOfTree:(IFTree*)otherTree asParentOfNode:(IFTreeNode*)node;
{
  [self beginTreeModification];
  IFTreeNode* newRoot = [tree insertCloneOfTree:otherTree asParentOfNode:node];
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

// MARK: Loading and saving

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
  NSDictionary* encodedDocument = [[IFXMLCoder sharedCoder] encodeDocument:self];
  NSMutableDictionary* fileWrappers = [NSMutableDictionary dictionary];
  for (NSString* key in encodedDocument)
    [fileWrappers setObject:[[[NSFileWrapper alloc] initRegularFileWithContents:[encodedDocument objectForKey:key]] autorelease] forKey:key];

  return [[[NSFileWrapper alloc] initDirectoryWithFileWrappers:fileWrappers] autorelease];
}

- (BOOL)readFromFileWrapper:(NSFileWrapper*)dirWrapper ofType:(NSString*)typeName error:(NSError**)outError;
{
  NSAssert1([dirWrapper isDirectory], @"wrapper is not a directory: %@", dirWrapper);
  
  NSMutableDictionary* fileWrapperContents = [NSMutableDictionary dictionary];
  for (NSFileWrapper* fileWrapper in [[dirWrapper fileWrappers] objectEnumerator])
    [fileWrapperContents setObject:[fileWrapper regularFileContents] forKey:[fileWrapper filename]];

  [[IFXMLCoder sharedCoder] decodeDocument:fileWrapperContents into:self];
  [[self undoManager] removeAllActions];

  return YES;
}

// MARK: -
// MARK: PRIVATE

- (void)ensureGhostNodes;
{
  BOOL hasGhostColumn = NO;
  NSArray* roots = [self roots];
  for (unsigned int i = 0; i < [roots count]; i++) {
    IFTreeNode* root = [roots objectAtIndex:i];
    if (root.isGhost)
      hasGhostColumn |= ([tree parentsCountOfNode:root] == 0);
    else if (root.type.resultType.leafType.isSomeImageType)
      [tree insertCloneOfTree:[IFTree ghostTreeWithArity:1] asChildOfNode:root];
  }
  if (!hasGhostColumn)
    [tree addCloneOfTree:[IFTree ghostTreeWithArity:0] asNewRootAtIndex:[tree parentsCountOfNode:[tree root]]];
}

- (void)beginTreeModification;
{
  NSAssert([tree propagateNewParentExpressions], @"internal error");
  [tree setPropagateNewParentExpressions:NO];
}

- (void)endTreeModification;
{
  NSAssert(![tree propagateNewParentExpressions], @"internal error");
  [tree configureNodes];
  [self ensureGhostNodes];
  [tree configureNodes]; // TODO: ideally, only newly-added ghost nodes should be re-configured
  [tree setPropagateNewParentExpressions:YES];
  [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:IFTreeChangedNotification object:self] postingStyle:NSPostWhenIdle];  
}

@end
