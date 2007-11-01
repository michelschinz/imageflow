//  IFDocument.m
//  ImageFlow
//
//  Created by Michel Schinz on 15.06.05.
//  Copyright Michel Schinz 2005 . All rights reserved.

#import "IFDocument.h"
#import "IFTreeIdentifier.h"
#import "IFXMLCoder.h"
#import "IFDocumentXMLEncoder.h"
#import "IFDocumentXMLDecoder.h"
#import "IFTreeViewWindowController.h"
#import "IFFilter.h"
#import "IFExpressionEvaluator.h"
#import "IFDirectoryManager.h"
#import "IFTreeNodeFilter.h"
#import "IFTreeNodeAlias.h"
#import "IFTypeChecker.h"
#import "IFTypeVar.h"
#import "IFFunType.h"
#import "IFGraph.h"
#import "IFGraphNode.h"

#import <caml/memory.h>
#import <caml/alloc.h>
#import <caml/callback.h>

@interface IFDocument (Private)
- (void)ensureGhostNodes;
- (void)replaceGhostNode:(IFTreeNode*)node usingNode:(IFTreeNode*)replacement inTree:(IFTree*)tree;
- (void)insertNode:(IFTreeNode*)parent asParentOf:(IFTreeNode*)child inTree:(IFTree*)targetTree;
- (void)insertNode:(IFTreeNode*)child asChildOf:(IFTreeNode*)parent inTree:(IFTree*)targetTree;
- (IFGraph*)graph;
- (void)finishTreeModification;
- (void)overwriteWith:(IFDocument*)other;
@end

@implementation IFDocument

NSString* IFTreeChangedNotification = @"IFTreeChanged";

- (id)init 
{
  if (![super init]) return nil;
  typeChecker = [IFTypeChecker sharedInstance];
  evaluator = [IFExpressionEvaluator new];

  tree = [[IFTree tree] retain];
  [tree addNode:[IFTreeNodeFilter nodeWithFilter:nil]];
  [self ensureGhostNodes];
  
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
  
  OBJC_RELEASE(evaluator);
  
  [super dealloc];
}

- (void)makeWindowControllers;
{
  [self addWindowController:[[[IFTreeViewWindowController alloc] init] autorelease]];
}

- (IFExpressionEvaluator*)evaluator;
{
  return evaluator;
}

- (IFTree*)tree;
{
  return tree;
}

- (NSArray*)roots;
{
  return [tree parentsOfNode:[tree root]];
}

#pragma mark meta-data

- (NSString*)title;
{
  return title;
}

- (void)setTitle:(NSString*)newTitle;
{
  if ([newTitle isEqualToString:title])
    return;
  [title release];
  title = [newTitle retain];
}

- (NSString*)authorName;
{
  return authorName;
}

- (void)setAuthorName:(NSString*)newAuthorName;
{
  if ([newAuthorName isEqualToString:authorName])
    return;
  [authorName release];
  authorName = [newAuthorName copy];
}

- (NSString*)documentDescription;
{
  return documentDescription;
}

- (void)setDocumentDescription:(NSString*)newDocumentDescription;
{
  if (newDocumentDescription == documentDescription)
    return;
  [documentDescription release];
  documentDescription = [newDocumentDescription copy];
}

#pragma mask canvas

- (NSRect)canvasBounds;
{
  return canvasBounds;
}

- (void)setCanvasBounds:(NSRect)newCanvasBounds;
{
  canvasBounds = newCanvasBounds;
}

#pragma mark color

- (IFColorProfile*)workingSpaceProfile;
{
  return workingSpaceProfile;
}

- (void)setWorkingSpaceProfile:(IFColorProfile*)newProfile;
{
  if (newProfile == workingSpaceProfile)
    return;
  [workingSpaceProfile release];
  workingSpaceProfile = [newProfile retain];
  
  [evaluator setWorkingColorSpace:[workingSpaceProfile colorspace]];
}

#pragma mark resolution

- (float)resolutionX;
{
  return resolutionX;
}

- (void)setResolutionX:(float)newResolutionX;
{
  resolutionX = newResolutionX;
  [evaluator setResolutionX:resolutionX];
}

- (float)resolutionY;
{
  return resolutionY;
}

- (void)setResolutionY:(float)newResolutionY;
{
  resolutionY = newResolutionY;
  [evaluator setResolutionY:resolutionY];
}

#pragma mark document manipulation

- (void)addTree:(IFTreeNode*)newNode;
{
  NSArray* roots = [self roots];
  int i;
  for (i = [roots count] - 1;
       (i >= 0) && [[roots objectAtIndex:i] isGhost] && ([tree parentsCountOfNode:[roots objectAtIndex:i]] == 0);
       --i)
    ;
  [tree addNode:newNode asNewRootAtIndex:i+1];

  [self finishTreeModification];
}

- (BOOL)canInsertNode:(IFTreeNode*)parent asParentOf:(IFTreeNode*)child;
{
  IFTree* testTree = [tree clone];
  [self insertNode:parent asParentOf:child inTree:testTree];
  return [testTree isTypeCorrect];
}

- (void)insertNode:(IFTreeNode*)parent asParentOf:(IFTreeNode*)child;
{
  NSAssert([self canInsertNode:parent asParentOf:child], @"internal error");

  [self insertNode:parent asParentOf:child inTree:tree];
  [self finishTreeModification];
}

- (BOOL)canInsertNode:(IFTreeNode*)child asChildOf:(IFTreeNode*)parent;
{
  IFTree* testTree = [tree clone];
  [self insertNode:child asChildOf:parent inTree:testTree];
  return [testTree isTypeCorrect];
}

- (void)insertNode:(IFTreeNode*)child asChildOf:(IFTreeNode*)parent;
{
  NSAssert([self canInsertNode:child asChildOf:parent], @"internal error");
  [self insertNode:child asChildOf:parent inTree:tree];
  [self finishTreeModification];
}

- (BOOL)canReplaceGhostNode:(IFTreeNode*)node usingNode:(IFTreeNode*)replacement;
{
  IFTree* testTree = [tree clone];
  [self replaceGhostNode:node usingNode:replacement inTree:testTree];
  return [testTree isTypeCorrect];
}

- (void)replaceGhostNode:(IFTreeNode*)node usingNode:(IFTreeNode*)replacement;
{
  NSAssert([self canReplaceGhostNode:node usingNode:replacement], @"internal error");
  [self replaceGhostNode:node usingNode:replacement inTree:tree];
  [self finishTreeModification];
}

- (void)deleteNode:(IFTreeNode*)node;
{
  [self deleteContiguousNodes:[NSSet setWithObject:node]];
}

- (void)deleteContiguousNodes:(NSSet*)contiguousNodes;
{
  NSAssert([contiguousNodes count] == 1, @"cannot delete more than 1 node (TODO)");

  IFTreeNode* nodeToDelete = [contiguousNodes anyObject];
  [tree replaceNode:nodeToDelete byNode:[IFTreeNode ghostNodeWithInputArity:[nodeToDelete inputArity]]];
  
  [self finishTreeModification];
}

- (NSSet*)allNodes;
{
  NSMutableSet* allNodes = [NSMutableSet setWithArray:[tree dfsAncestorsOfNode:[tree root]]];
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

// TODO move to IFTree ?
- (IFTreeNode*)rootOfTreeContainingNode:(IFTreeNode*)node;
{
  IFTreeNode* root = node;
  while (root != nil && [tree childOfNode:root] != [tree root])
    root = [tree childOfNode:root];
  NSAssert1(root != nil, @"cannot find root of tree containing %@",node);
  return root;  
}

// private
- (void)collectPathFromRootToNode:(IFTreeNode*)node inArray:(NSMutableArray*)result;
{
  if ([tree childOfNode:node] != [tree root])
    [self collectPathFromRootToNode:[tree childOfNode:node] inArray:result];
  [result addObject:node];
}

// TODO move to IFTree ?
- (NSArray*)pathFromRootTo:(IFTreeNode*)node;
{
  NSMutableArray* result = [NSMutableArray array];
  [self collectPathFromRootToNode:node inArray:result];
  return result;
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
  NSDictionary* identities = [[IFTreeIdentifier treeIdentifier] identifyTree:tree startingAt:[tree root] hints:[NSDictionary dictionary]];
  NSXMLDocument* xmlDoc = [[IFDocumentXMLEncoder encoder] documentToXML:self identities:identities];
  NSData* xmlData = [xmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
  return [[[NSFileWrapper alloc] initDirectoryWithFileWrappers:[NSDictionary dictionaryWithObjectsAndKeys:
    [[[NSFileWrapper alloc] initRegularFileWithContents:xmlData] autorelease], @"tree.xml",
    nil]] autorelease];
}

- (BOOL)readFromFileWrapper:(NSFileWrapper*)dirWrapper ofType:(NSString*)typeName error:(NSError**)outError;
{
  NSAssert1([dirWrapper isDirectory], @"wrapper is not a directory: %@", dirWrapper);
  
  NSDictionary* fileWrappers = [dirWrapper fileWrappers];
  NSEnumerator* fileEnum = [fileWrappers objectEnumerator];
  NSFileWrapper* fileWrapper;
  while (fileWrapper = [fileEnum nextObject]) {
    if ([[fileWrapper filename] isEqualToString:@"tree.xml"]) {
      NSXMLDocument* xmlDoc = [[[NSXMLDocument alloc] initWithData:[fileWrapper regularFileContents]
                                                           options:NSXMLDocumentTidyXML
                                                             error:outError] autorelease];
      if (xmlDoc == nil) return NO;
      [self overwriteWith:[[IFDocumentXMLDecoder decoder] documentFromXML:xmlDoc]];
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
      [tree insertNode:[IFTreeNode ghostNodeWithInputArity:1] asChildOf:root];
  }
  if (!hasGhostColumn)
    [tree addNode:[IFTreeNode ghostNodeWithInputArity:0] asNewRootAtIndex:[tree parentsCountOfNode:[tree root]]];
}

- (void)replaceGhostNode:(IFTreeNode*)node usingNode:(IFTreeNode*)replacement inTree:(IFTree*)theTree;
{
  [theTree removeAllRightGhostParentsOfNode:node];
  [theTree replaceNode:node byNode:replacement];
  [theTree addRightGhostParentsForNode:replacement];
}

- (void)insertNode:(IFTreeNode*)parent asParentOf:(IFTreeNode*)child inTree:(IFTree*)targetTree;
{
  [targetTree removeAllRightGhostParentsOfNode:child];
  [targetTree insertNode:parent asParentOf:child];
  [targetTree addRightGhostParentsForNode:parent];
  [targetTree addRightGhostParentsForNode:child];
}

- (void)insertNode:(IFTreeNode*)child asChildOf:(IFTreeNode*)parent inTree:(IFTree*)targetTree;
{
  [targetTree insertNode:child asChildOf:parent];
  [targetTree addRightGhostParentsForNode:child];
}

- (IFGraph*)graph;
{
  IFGraph* graph = [tree graphOfNode:[tree root]];
  [graph removeNode:[graph nodeWithData:[tree root]]];
  return graph;
}

- (void)configureFilters;
{
  IFGraph* graph = [self graph];
  NSDictionary* config = [graph resolveOverloading];
  NSArray* graphNodes = [graph topologicallySortedNodes];
  const int graphNodesCount = [graphNodes count];
  for (int i = 0; i < graphNodesCount; ++i)
    [[(IFGraphNode*)[graphNodes objectAtIndex:i] data] beginReconfiguration];
  for (int i = 0; i < graphNodesCount; ++i) {
    IFGraphNode* graphNode = [graphNodes objectAtIndex:i];
    [[graphNode data] endReconfigurationWithActiveTypeIndex:[[config objectForKey:graphNode] intValue]];
  }
}

- (void)finishTreeModification;
{
  [self ensureGhostNodes];
  [self configureFilters];
  [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:IFTreeChangedNotification object:self] postingStyle:NSPostWhenIdle];  
}

- (void)overwriteWith:(IFDocument*)other;
{
  // Copy everything from other document
  [self setAuthorName:[other authorName]];
  [self setDocumentDescription:[other documentDescription]];
  [self setWorkingSpaceProfile:[other workingSpaceProfile]];
  [self setResolutionX:[other resolutionX]];
  [self setResolutionY:[other resolutionY]];
  
  [tree release];
  tree = [other->tree retain]; // HACK

  // TODO copy marks
}

@end
