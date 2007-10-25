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
#import "IFDocumentTemplate.h"
#import "IFDocumentTemplateManager.h"
#import "IFTreeNodeFilter.h"
#import "IFTreeNodeParameter.h"
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
- (void)replaceNode:(IFTreeNode*)toReplace byNode:(IFTreeNode*)replacement;
- (void)ensureGhostNodes;
- (void)addRightGhostParentsForNode:(IFTreeNode*)node;
- (void)removeAllRightGhostParentsOfNode:(IFTreeNode*)node;
- (void)addRightGhostPredecessorsForNode:(IFGraphNode*)node inGraph:(IFGraph*)graph;
- (void)removeAllRightGhostPredecessorsOfNode:(IFGraphNode*)node inGraph:(IFGraph*)graph;
- (IFGraph*)graph;
- (void)finishTreeModification;
- (void)overwriteWith:(IFDocument*)other;
@end

@implementation IFDocument

NSString* IFTreeChangedNotification = @"IFTreeChanged";

static IFDocumentTemplateManager* templateManager;

+ (IFDocumentTemplateManager*)documentTemplateManager;
{
  if (templateManager == nil)
    templateManager = [[IFDocumentTemplateManager alloc] initWithDirectory:[[IFDirectoryManager sharedDirectoryManager] filterTemplatesDirectory]];
  return templateManager;
}

- (id)init 
{
  if (![super init]) return nil;
  typeChecker = [IFTypeChecker sharedInstance];
  evaluator = [IFExpressionEvaluator new];

  tree = [[IFTree tree] retain];
  fakeRoot = [[IFTreeNodeFilter nodeWithFilter:nil] retain];
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
  OBJC_RELEASE(fakeRoot);
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
  return [tree parentsOfNode:fakeRoot];
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

- (void)addTree:(IFTreeNode*)newRoot;
{
  NSArray* roots = [self roots];
  int i;
  for (i = [roots count] - 1;
       (i >= 0) && [[roots objectAtIndex:i] isGhost] && ([tree parentsCountOfNode:[roots objectAtIndex:i]] == 0);
       --i)
    ;
  [tree insertObject:newRoot inParentsOfNode:fakeRoot atIndex:i+1];
  [self finishTreeModification];
}

- (BOOL)canInsertNode:(IFTreeNode*)parent asParentOf:(IFTreeNode*)child;
{
  IFGraph* graph = [self graph];
  IFGraphNode* graphChild = [graph nodeWithData:[child original]];
  [self removeAllRightGhostPredecessorsOfNode:graphChild inGraph:graph];

  IFGraphNode* graphParent = [IFGraphNode graphNodeWithTypes:[parent potentialTypes] data:parent];
  [graph addNode:graphParent];
  [graphParent setPredecessors:[graphChild predecessors]];
  [self addRightGhostPredecessorsForNode:graphParent inGraph:graph];

  [graphChild setPredecessors:[NSArray arrayWithObject:graphParent]];
  [self addRightGhostPredecessorsForNode:graphChild inGraph:graph];

  return [graph isTypeable];  
}

- (void)insertNode:(IFTreeNode*)parent asParentOf:(IFTreeNode*)child;
{
  NSAssert([self canInsertNode:parent asParentOf:child], @"internal error");

  [self removeAllRightGhostParentsOfNode:child];
  int parentsCount = [tree parentsCountOfNode:child];
  for (int i = 0; i < parentsCount; ++i) {
    IFTreeNode* p = [[[[tree parentsOfNode:child] objectAtIndex:0] retain] autorelease];
    [tree removeObjectFromParentsOfNode:child atIndex:0];
    [tree insertObject:p inParentsOfNode:parent atIndex:i];
  }
  [self addRightGhostParentsForNode:parent];

  [tree insertObject:parent inParentsOfNode:child atIndex:0];
  [self addRightGhostParentsForNode:child];

  [self finishTreeModification];
}

- (BOOL)canInsertNode:(IFTreeNode*)child asChildOf:(IFTreeNode*)parent;
{
  IFGraph* graph = [self graph];
  IFGraphNode* graphParent = [graph nodeWithData:[parent original]];
  IFGraphNode* graphChild = [IFGraphNode graphNodeWithTypes:[child potentialTypes] data:child];
  [graph addNode:graphChild];
  [[[graph nodes] do] replacePredecessor:graphParent byNode:graphChild];
  [graphChild setPredecessors:[NSArray arrayWithObject:graphParent]];
  [self addRightGhostPredecessorsForNode:graphChild inGraph:graph];
  return [graph isTypeable];
}

- (void)insertNode:(IFTreeNode*)child asChildOf:(IFTreeNode*)parent;
{
  NSAssert([self canInsertNode:child asChildOf:parent], @"internal error");

  IFTreeNode* originalChild = [tree childOfNode:parent];
  int parentIndex = [[tree parentsOfNode:originalChild] indexOfObject:parent];
  [tree replaceObjectInParentsOfNode:originalChild atIndex:parentIndex withObject:child];
  [tree insertObject:parent inParentsOfNode:child atIndex:0];
  [self addRightGhostParentsForNode:child];

  [self finishTreeModification];
}

- (BOOL)canReplaceGhostNode:(IFTreeNode*)ghost usingNode:(IFTreeNode*)replacement;
{
  IFGraph* graph = [self graph];
  IFGraphNode* graphGhost = [graph nodeWithData:[ghost original]];
  [self removeAllRightGhostPredecessorsOfNode:graphGhost inGraph:graph];
  IFGraphNode* graphReplacement = [IFGraphNode graphNodeWithTypes:[replacement potentialTypes] data:replacement];
  [graphReplacement setPredecessors:[graphGhost predecessors]];
  [[[graph nodes] do] replacePredecessor:graphGhost byNode:graphReplacement];
  [graph removeNode:graphGhost];
  [graph addNode:graphReplacement];
  [self addRightGhostPredecessorsForNode:graphReplacement inGraph:graph];
  return [graph isTypeable];
}

- (void)replaceGhostNode:(IFTreeNode*)node usingNode:(IFTreeNode*)replacement transformingMarks:(NSArray*)marks;
{
  NSAssert([self canReplaceGhostNode:node usingNode:replacement], @"internal error");
  
  [self removeAllRightGhostParentsOfNode:node];
  [self replaceNode:node byNode:replacement];
  [self addRightGhostParentsForNode:replacement];

  [self finishTreeModification];
}

// private
- (void)deleteSingleNode:(IFTreeNode*)node transformingMarks:(NSArray*)marks;
{
  // TODO handle case where node to delete has aliases
  [self removeAllRightGhostParentsOfNode:node]; // TODO marks

  IFGraph* graph = [self graph];
  IFGraphNode* graphNode = [graph nodeWithData:node];
  BOOL ghostNeeded;
  if ([[graphNode predecessors] count] == 1) {
    [[[graph nodes] do] replacePredecessor:graphNode byNode:[[graphNode predecessors] lastObject]];
    [graph removeNode:graphNode];
    ghostNeeded = ![graph isTypeable];
  } else
    ghostNeeded = YES;

  if (ghostNeeded) {
    IFTreeNode* ghost = [IFTreeNode ghostNodeWithInputArity:[node inputArity]];
    [self replaceNode:node byNode:ghost];
  } else {
    IFTreeNode* child = [tree childOfNode:node];
    [tree replaceObjectInParentsOfNode:child atIndex:[[tree parentsOfNode:child] indexOfObject:node] withObject:[[tree parentsOfNode:node] objectAtIndex:0]];
  }
  [self finishTreeModification];
}

- (void)deleteNode:(IFTreeNode*)node transformingMarks:(NSArray*)marks;
{
  [self deleteContiguousNodes:[NSSet setWithObject:node] transformingMarks:marks];
}

- (void)deleteContiguousNodes:(NSSet*)contiguousNodes transformingMarks:(NSArray*)marks;
{
  // Delete aliases of nodes we're about to delete
  NSMutableSet* aliases = [NSMutableSet setWithSet:[self aliasesForNodes:contiguousNodes]];
  [aliases minusSet:contiguousNodes];
  [[self do] deleteSingleNode:[aliases each] transformingMarks:marks];

  // Delete the nodes themselves
  IFTreeNode* nodeToDelete;
  NSAssert([contiguousNodes count] == 1, @"cannot delete more than 1 node (TODO)");
  nodeToDelete = [contiguousNodes anyObject];
  [self deleteSingleNode:nodeToDelete transformingMarks:marks];
}

- (NSSet*)allNodes;
{
  NSMutableSet* allNodes = [NSMutableSet setWithArray:[tree dfsAncestorsOfNode:fakeRoot]];
  [allNodes removeObject:fakeRoot];
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
  IFTreeNode* root = node;
  while (root != nil && [tree childOfNode:root] != fakeRoot)
    root = [tree childOfNode:root];
  NSAssert1(root != nil, @"cannot find root of tree containing %@",node);
  return root;  
}

// private
- (void)collectPathFromRootToNode:(IFTreeNode*)node inArray:(NSMutableArray*)result;
{
  if ([tree childOfNode:node] != fakeRoot)
    [self collectPathFromRootToNode:[tree childOfNode:node] inArray:result];
  [result addObject:node];
}

- (NSArray*)pathFromRootTo:(IFTreeNode*)node;
{
  NSMutableArray* result = [NSMutableArray array];
  [self collectPathFromRootToNode:node inArray:result];
  return result;
}

// private
- (void)collectAliasesForNodes:(NSSet*)nodes startingAt:(IFTreeNode*)root inSet:(NSMutableSet*)resultSet;
{
  NSArray* parents = [tree parentsOfNode:root];
  if ([parents count] == 0) {
    if ([root isKindOfClass:[IFTreeNodeAlias class]] && [nodes containsObject:[(IFTreeNodeAlias*)root original]])
      [resultSet addObject:root];
  } else
    [[self do] collectAliasesForNodes:nodes startingAt:[parents each] inSet:resultSet];
}

- (NSSet*)aliasesForNodes:(NSSet*)nodes;
{
  NSMutableSet* aliases = [NSMutableSet set];
  [self collectAliasesForNodes:nodes startingAt:fakeRoot inSet:aliases];
  return aliases;
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
  NSDictionary* identities = [[IFTreeIdentifier treeIdentifier] identifyTree:tree startingAt:fakeRoot hints:[NSDictionary dictionary]];
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

- (void)replaceNode:(IFTreeNode*)toReplace byNode:(IFTreeNode*)replacement;
{
  NSArray* parentsCopy = [[tree parentsOfNode:toReplace] copy];
  for (int i = 0; i < [parentsCopy count]; i++) {
    IFTreeNode* ghost = [IFTreeNode ghostNodeWithInputArity:0];
    [tree replaceObjectInParentsOfNode:toReplace atIndex:i withObject:ghost];
    IFTreeNode* parent = [parentsCopy objectAtIndex:i];
    [tree insertObject:parent inParentsOfNode:replacement atIndex:i];
  }
  [parentsCopy release];
  
  IFTreeNode* child = [tree childOfNode:toReplace];
  [tree replaceObjectInParentsOfNode:child atIndex:[[tree parentsOfNode:child] indexOfObject:toReplace] withObject:replacement];
}

- (void)ensureGhostNodes;
{
  BOOL hasGhostColumn = NO;
  NSArray* roots = [self roots];
  for (unsigned int i = 0; i < [roots count]; i++) {
    IFTreeNode* root = [roots objectAtIndex:i];
    if ([root isGhost])
      hasGhostColumn |= ([tree parentsCountOfNode:root] == 0);
    else if ([root outputArity] == 1) {
      [[root retain] autorelease];
      IFTreeNode* newRoot = [IFTreeNode ghostNodeWithInputArity:1];
      [tree replaceObjectInParentsOfNode:fakeRoot atIndex:i withObject:newRoot];
      [tree insertObject:root inParentsOfNode:newRoot atIndex:0];
    }
  }
  if (!hasGhostColumn)
    [tree insertObject:[IFTreeNode ghostNodeWithInputArity:0] inParentsOfNode:fakeRoot atIndex:[tree parentsCountOfNode:fakeRoot]];
}

// TODO move to some other class
- (void)addRightGhostParentsForNode:(IFTreeNode*)node;
{
  for (int i = [tree parentsCountOfNode:node]; i < [node inputArity]; ++i)
    [tree insertObject:[IFTreeNode ghostNodeWithInputArity:0] inParentsOfNode:node atIndex:i];
}

- (void)removeAllRightGhostParentsOfNode:(IFTreeNode*)node;
{
  for (;;) {
    IFTreeNode* lastParent = [[tree parentsOfNode:node] lastObject];
    if (lastParent == nil || ![tree isGhostSubtreeRoot:lastParent])
      break;
    [tree removeObjectFromParentsOfNode:node atIndex:[tree parentsCountOfNode:node]-1];
  }
}

// TODO move to some other class
- (void)addRightGhostPredecessorsForNode:(IFGraphNode*)node inGraph:(IFGraph*)graph;
{
  NSArray* ghostTypes = [[IFTreeNode ghostNodeWithInputArity:0] potentialTypes];
  int predsToAdd = [[node data] inputArity] - [[node predecessors] count];
  while (predsToAdd-- > 0) {
    IFGraphNode* newPred = [IFGraphNode graphNodeWithTypes:ghostTypes];
    [graph addNode:newPred];
    [node addPredecessor:newPred];
  }
}

// TODO move to some other class
- (void)removeAllRightGhostPredecessorsOfNode:(IFGraphNode*)node inGraph:(IFGraph*)graph;
{
  for (;;) {
    IFGraphNode* lastPred = [[node predecessors] lastObject];
    NSAssert(lastPred == nil || [lastPred data] != nil, @"no tree node attached to graph node");
    if (lastPred == nil || ![tree isGhostSubtreeRoot:[lastPred data]])
      break;
    [node removeLastPredecessor];
    [graph removeNode:lastPred];
  }
}

- (IFGraph*)graph;
{
  IFGraph* graph = [tree graphOfNode:fakeRoot];
  [graph removeNode:[graph nodeWithData:fakeRoot]];
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
  // Destroy all current contents
  while ([[tree parentsOfNode:fakeRoot] count] > 0)
    [tree removeObjectFromParentsOfNode:fakeRoot atIndex:0];

  // Copy everything from other document
  [self setAuthorName:[other authorName]];
  [self setDocumentDescription:[other documentDescription]];
  [self setWorkingSpaceProfile:[other workingSpaceProfile]];
  [self setResolutionX:[other resolutionX]];
  [self setResolutionY:[other resolutionY]];
  
  IFTree* otherTree = other->tree; // HACK
  IFTreeNode* otherFakeRoot = other->fakeRoot; // HACK
  NSArray* otherRoots = [[otherTree parentsOfNode:otherFakeRoot] copy];
  for (int i = 0; i < [otherRoots count]; ++i) {
    IFTreeNode* otherRoot = [[otherRoots objectAtIndex:i] retain];
    [otherTree removeObjectFromParentsOfNode:otherFakeRoot atIndex:0];
    [tree insertObject:otherRoot inParentsOfNode:fakeRoot atIndex:i];
    [otherRoot release];
  }
  [otherRoots release];

  // TODO copy marks
}

@end
