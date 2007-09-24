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

#import <caml/memory.h>
#import <caml/alloc.h>
#import <caml/callback.h>

@interface IFDocument (Private)
- (void)maybeInlineNode:(IFTreeNode*)node transformingMarks:(NSArray*)marks;
- (void)ensureGhostNodes;
- (void)finishTreeModification;
- (NSArray*)topologicallySortedNodes;
- (void)overwriteWith:(IFDocument*)other;
- (void)insertNodes:(NSArray*)parents intoParentsOfNode:(IFTreeNode*)node atIndices:(NSIndexSet*)indices;
- (void)removeParentsOfNode:(IFTreeNode*)node atIndices:(NSIndexSet*)indices;
- (void)replaceParentsOfNode:(IFTreeNode*)node byNodes:(NSArray*)newParents atIndices:(NSIndexSet*)indices;
- (void)setValue:(id)value forKey:(NSString*)key inEnvironment:(IFEnvironment*)env;
- (void)startObservingTree:(IFTreeNode*)root;
- (void)startObservingTreesIn:(NSArray*)nodes;
- (void)stopObservingTree:(IFTreeNode*)root;
- (void)stopObservingTreesIn:(NSArray*)nodes;
- (void)startObservingEnvironment:(IFEnvironment*)env;
- (void)stopObservingEnvironment:(IFEnvironment*)env;
- (void)startObservingKeys:(NSSet*)keys ofEnvironment:(IFEnvironment*)env;
- (void)stopObservingKeys:(NSSet*)keys ofEnvironment:(IFEnvironment*)env;
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

  fakeRoot = [[IFTreeNodeFilter nodeWithFilter:nil] retain];
  [self ensureGhostNodes];
  [self startObservingTree:fakeRoot];
  
  canvasBounds = NSMakeRect(0,0,800,600);
  workingSpaceProfile = nil;
  [self setWorkingSpaceProfile:[IFColorProfile profileDefaultRGB]];
  [self setResolutionX:300];
  [self setResolutionY:300];
  
  return self;
}

- (void)dealloc;
{
  [self stopObservingTree:fakeRoot];
  OBJC_RELEASE(fakeRoot);

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

- (NSArray*)roots;
{
  return [fakeRoot parents];
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
       (i >= 0) && [[roots objectAtIndex:i] isGhost] && ([[[roots objectAtIndex:i] parents] count] == 0);
       --i)
    ;
  [fakeRoot insertObject:newRoot inParentsAtIndex:i+1];
  [self finishTreeModification];
}

- (BOOL)canInsertNode:(IFTreeNode*)parent asParentOf:(IFTreeNode*)child;
{
  // TODO add ghost nodes if required (and if we want it)
  NSArray* sortedNodes = [self topologicallySortedNodes];
  
  const int newCount = [sortedNodes count]+1;
  const int oldChildIndex = [sortedNodes indexOfObject:child];
  const int newParentIndex = oldChildIndex;
  NSMutableArray* potentialTypes = [NSMutableArray arrayWithCapacity:newCount];
  NSMutableArray* dag = [NSMutableArray arrayWithCapacity:newCount];
  // First add all nodes above child (excluded), without modification...
  for (int i = 0; i < oldChildIndex; ++i) {
    IFTreeNode* node = [sortedNodes objectAtIndex:i];
    [potentialTypes addObject:[node potentialTypes]];
    [dag addObject:[typeChecker predecessorIndexesOfNode:node inArray:sortedNodes]];
  }
  // ...then add new parent and child, with proper parent(s)...
  [potentialTypes addObject:[parent potentialTypes]];
  [dag addObject:[typeChecker predecessorIndexesOfNode:child inArray:sortedNodes]];
  [potentialTypes addObject:[child potentialTypes]];
  [dag addObject:[NSArray arrayWithObject:[NSNumber numberWithInt:newParentIndex]]];
  // ...finally add remaining nodes, with adjusted predecessor indexes.
  for (int i = oldChildIndex + 1; i < newCount - 1; ++i) {
    IFTreeNode* node = [sortedNodes objectAtIndex:i-1];
    [potentialTypes addObject:[node potentialTypes]];
    
    NSArray* oldPreds = [typeChecker predecessorIndexesOfNode:node inArray:sortedNodes];
    const int pCount = [oldPreds count];
    NSMutableArray* newPreds = [NSMutableArray arrayWithCapacity:pCount];
    for (int j = 0; j < pCount; ++j) {
      int oldPred = [[oldPreds objectAtIndex:j] intValue];
      [newPreds addObject:[NSNumber numberWithInt:oldPred + (oldPred >= oldChildIndex ? 1 : 0)]];
    }
    [dag addObject:newPreds];
  }
  
  return [typeChecker checkDAG:dag withPotentialTypes:potentialTypes];  
}

- (void)insertNode:(IFTreeNode*)parent asParentOf:(IFTreeNode*)child;
{
  NSAssert([self canInsertNode:parent asParentOf:child], @"internal error");

  // TODO add ghost nodes when needed
  int parentsCount = [[child parents] count];
  for (int i = 0; i < parentsCount; ++i) {
    IFTreeNode* p = [[[[child parents] objectAtIndex:0] retain] autorelease];
    [child removeObjectFromParentsAtIndex:0];
    [parent insertObject:p inParentsAtIndex:i];
  }
  [child insertObject:parent inParentsAtIndex:0];
  [self maybeInlineNode:parent transformingMarks:[NSArray array]]; // TODO marks (in case of d&d node move)
  [self finishTreeModification];
}

- (BOOL)canInsertNode:(IFTreeNode*)child asChildOf:(IFTreeNode*)parent;
{
  // TODO add ghost nodes if required (and if we want it)
  NSArray* sortedNodes = [self topologicallySortedNodes];
  
  const int newCount = [sortedNodes count]+1;
  const int parentIndex = [sortedNodes indexOfObject:parent];
  const int childIndex = parentIndex + 1;
  NSMutableArray* potentialTypes = [NSMutableArray arrayWithCapacity:newCount];
  NSMutableArray* dag = [NSMutableArray arrayWithCapacity:newCount];
  // First add all nodes above parent (included), without modification...
  for (int i = 0; i < childIndex; ++i) {
    IFTreeNode* node = [sortedNodes objectAtIndex:i];
    [potentialTypes addObject:[node potentialTypes]];
    [dag addObject:[typeChecker predecessorIndexesOfNode:node inArray:sortedNodes]];
  }
  // ...then add child, with proper parent...
  [potentialTypes addObject:[child potentialTypes]];
  [dag addObject:[NSArray arrayWithObject:[NSNumber numberWithInt:parentIndex]]];
  // ...finally add remaining nodes, with adjusted predecessor indexes.
  for (int i = childIndex; i < newCount - 1; ++i) {
    IFTreeNode* node = [sortedNodes objectAtIndex:i];
    [potentialTypes addObject:[node potentialTypes]];

    NSArray* oldPreds = [typeChecker predecessorIndexesOfNode:node inArray:sortedNodes];
    const int pCount = [oldPreds count];
    NSMutableArray* newPreds = [NSMutableArray arrayWithCapacity:pCount];
    for (int j = 0; j < pCount; ++j) {
      int oldPred = [[oldPreds objectAtIndex:j] intValue];
      [newPreds addObject:[NSNumber numberWithInt:oldPred + (oldPred >= parentIndex ? 1 : 0)]];
    }
    [dag addObject:newPreds];
  }
  
  return [typeChecker checkDAG:dag withPotentialTypes:potentialTypes];
}

- (void)insertNode:(IFTreeNode*)child asChildOf:(IFTreeNode*)parent;
{
  NSAssert([self canInsertNode:child asChildOf:parent], @"internal error");

  IFTreeNode* originalChild = [parent child];
  int parentIndex = [[originalChild parents] indexOfObject:parent];
  [originalChild replaceObjectInParentsAtIndex:parentIndex withObject:child];
  [child insertObject:parent inParentsAtIndex:0];
  [self maybeInlineNode:child transformingMarks:[NSArray array]]; // TODO marks (in case of d&d node move)
  [self finishTreeModification];
}

- (BOOL)canReplaceGhostNode:(IFTreeNode*)ghost usingNode:(IFTreeNode*)replacement;
{
  NSArray* sortedNodes = [self topologicallySortedNodes];
  int nodesCount = [sortedNodes count];
  
  NSMutableArray* potentialTypes = [NSMutableArray arrayWithCapacity:nodesCount];
  for (int i = 0; i < nodesCount; ++i) {
    IFTreeNode* node = [sortedNodes objectAtIndex:i];
    [potentialTypes addObject:(node == ghost
                               ? (NSArray*)[[[replacement potentialTypes] collect] typeByLimitingArityTo:[ghost inputArity]]
                               : [node potentialTypes])];
  }
  
  return [typeChecker checkDAG:[typeChecker dagFromTopologicallySortedNodes:sortedNodes] withPotentialTypes:potentialTypes];
}

- (void)replaceGhostNode:(IFTreeNode*)node usingNode:(IFTreeNode*)replacement transformingMarks:(NSArray*)marks;
{
  NSAssert([self canReplaceGhostNode:node usingNode:replacement], @"internal error");

  const int parentsCount = [[node parents] count];
  const int ghostsToAdd = [replacement inputArity] - parentsCount;
  [node replaceByNode:replacement transformingMarks:marks];
  for (int i = 0; i < ghostsToAdd; ++i)
    [replacement insertObject:[IFTreeNode ghostNodeWithInputArity:0] inParentsAtIndex:parentsCount + i];
  [self maybeInlineNode:replacement transformingMarks:marks];
  [self finishTreeModification];
}

// private
- (void)deleteSingleNode:(IFTreeNode*)node transformingMarks:(NSArray*)marks;
{
  BOOL ghostNeeded;
  if ([node inputArity] == 1) {
    // To see whether a ghost is needed or not, we pretend that the node to delete has the type of the identity function ('a=>'a). If it typechecks, the node can be simply removed (i.e. no need for a ghost).
    NSArray* sortedNodes = [self topologicallySortedNodes];
    int nodesCount = [sortedNodes count];
    
    NSMutableArray* potentialTypes = [NSMutableArray arrayWithCapacity:nodesCount];
    for (int i = 0; i < nodesCount; ++i) {
      if ([sortedNodes objectAtIndex:i] == node) {
        IFTypeVar* tvar = [IFTypeVar typeVarWithIndex:0];
        [potentialTypes addObject:[NSArray arrayWithObject:[IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObject:tvar] returnType:tvar]]];
      } else
        [potentialTypes addObject:[[sortedNodes objectAtIndex:i] potentialTypes]];
    }
    ghostNeeded = ![typeChecker checkDAG:[typeChecker dagFromTopologicallySortedNodes:sortedNodes] withPotentialTypes:potentialTypes];
  } else
    ghostNeeded = YES;

  if (ghostNeeded) {
    IFTreeNode* ghost = [IFTreeNode ghostNodeWithInputArity:[node inputArity]];
    [node replaceByNode:ghost transformingMarks:marks];
  } else {
    IFTreeNode* child = [node child];
    [child replaceObjectInParentsAtIndex:[[child parents] indexOfObject:node] withObject:[[node parents] objectAtIndex:0]];    
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
  if ([contiguousNodes count] > 1) {
    IFTreeNodeMacro* macroNode = [self macroNodeByCopyingNodesOf:contiguousNodes inlineOnInsertion:NO];
    [self replaceNodesIn:contiguousNodes byMacroNode:macroNode];
    nodeToDelete = macroNode;
  } else
    nodeToDelete = [contiguousNodes anyObject];
  [self deleteSingleNode:nodeToDelete transformingMarks:marks];
}

static IFTreeNode* cloneNodesInSet(NSSet* nodes, IFTreeNode* root, int* paramsCounter)
{
  if ([nodes containsObject:root]) {
    IFTreeNode* clonedRoot = [root cloneNode];
    NSArray* parents = [root parents];
    for (int i = 0; i < [parents count]; ++i)
      [clonedRoot insertObject:cloneNodesInSet(nodes, [parents objectAtIndex:i], paramsCounter) inParentsAtIndex:i];
    return clonedRoot;
  } else
    return [IFTreeNodeParameter nodeParameterWithIndex:(*paramsCounter)++];
}

static IFTreeNode* rootOf(NSSet* nodeSet)
{
  IFTreeNode* root;
  for (root = [nodeSet anyObject]; [nodeSet containsObject:[root child]]; root = [root child])
    ;
  return root;
}

- (IFTreeNodeMacro*)macroNodeByCopyingNodesOf:(NSSet*)nodes inlineOnInsertion:(BOOL)inlineOnInsertion;
{
  int paramsCounter = 0;
  return [IFTreeNodeMacro nodeMacroWithRoot:cloneNodesInSet(nodes, rootOf(nodes), &paramsCounter) inlineOnInsertion:inlineOnInsertion];
}

static void collectBoundary(IFTreeNode* root, NSSet* nodes, NSMutableArray* boundary)
{
  NSCAssert([nodes containsObject:root], @"invalid root");

  NSArray* parents = [root parents];
  for (int i = 0; i < [parents count]; ++i) {
    IFTreeNode* parent = [parents objectAtIndex:i];
    if ([nodes containsObject:parent])
      collectBoundary(parent, nodes, boundary);
    else {
      [boundary addObject:parent];
      [root replaceObjectInParentsAtIndex:i withObject:[IFTreeNode ghostNodeWithInputArity:0]];
    }
  }
}

// TODO handle marks
- (void)replaceNodesIn:(NSSet*)nodes byMacroNode:(IFTreeNodeMacro*)macroNode;
{
  IFTreeNode* root = rootOf(nodes);
  // attach parent nodes to macro node
  NSMutableArray* actualParameters = [NSMutableArray array];
  collectBoundary(root, nodes, actualParameters);
  for (int i = 0; i < [actualParameters count]; ++i)
    [macroNode insertObject:[actualParameters objectAtIndex:i] inParentsAtIndex:i];
  // detach old root and attach new one (the macro node)
  int rootIndex = [[[root child] parents] indexOfObject:root];
  [[root child] replaceObjectInParentsAtIndex:rootIndex withObject:[IFTreeNode ghostNodeWithInputArity:0]];
  [[root child] replaceObjectInParentsAtIndex:rootIndex withObject:macroNode];
}

static void replaceParameterNodes(IFTreeNode* root, NSMutableArray* parentsOrNodes)
{
  NSArray* parents = [root parents];
  for (int i = 0; i < [parents count]; ++i) {
    IFTreeNode* parent = [parents objectAtIndex:i];
    if ([parent isKindOfClass:[IFTreeNodeParameter class]]) {
      IFTreeNodeParameter* param = (IFTreeNodeParameter*)parent;
      [root replaceObjectInParentsAtIndex:i withObject:[parentsOrNodes objectAtIndex:[param index]]];
    } else
      replaceParameterNodes(parent, parentsOrNodes);
  }
}

- (void)inlineMacroNode:(IFTreeNodeMacro*)macroNode transformingMarks:(NSArray*)marks;
{
  // Detach all parents of macro node
  NSMutableArray* detachedMacroParents = [NSMutableArray array];
  NSArray* macroParents = [macroNode parents];
  for (int i = 0; i < [macroParents count]; ++i) {
    IFTreeNode* parent = [macroParents objectAtIndex:i];
    [detachedMacroParents addObject:parent];
    [macroNode replaceObjectInParentsAtIndex:i withObject:[IFTreeNode ghostNodeWithInputArity:0]];
  }

  // Clone macro node body, and replace parameter nodes by parent nodes, introducing aliases when necessary
  IFTreeNode* bodyRootClone = [[macroNode root] cloneNodeAndAncestors];
  NSAssert(![bodyRootClone isKindOfClass:[IFTreeNodeParameter class]], @"unexpected parameter node");
  replaceParameterNodes(bodyRootClone, detachedMacroParents);
  int macroIndex = [[[macroNode child] parents] indexOfObject:macroNode];
  [[macroNode child] replaceObjectInParentsAtIndex:macroIndex withObject:bodyRootClone];
  
  [[marks do] setNode:bodyRootClone ifCurrentNodeIs:macroNode];
}

- (NSSet*)allNodes;
{
  NSMutableSet* allNodes = [NSMutableSet setWithArray:[fakeRoot dfsAncestors]];
  [allNodes removeObject:fakeRoot];
  return allNodes;
}

- (NSSet*)ancestorsOfNode:(IFTreeNode*)node;
{
  return [NSSet setWithArray:[node dfsAncestors]];
}

- (NSSet*)nodesOfTreeContainingNode:(IFTreeNode*)node;
{
  return [NSSet setWithArray:[[self rootOfTreeContainingNode:node] dfsAncestors]];
}

- (IFTreeNode*)rootOfTreeContainingNode:(IFTreeNode*)node;
{
  IFTreeNode* root = node;
  while (root != nil && [root child] != fakeRoot)
    root = [root child];
  NSAssert1(root != nil, @"cannot find root of tree containing %@",node);
  return root;  
}

// private
- (void)collectPathFromRootToNode:(IFTreeNode*)node inArray:(NSMutableArray*)result;
{
  if ([node child] != fakeRoot)
    [self collectPathFromRootToNode:[node child] inArray:result];
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
  NSArray* parents = [root parents];
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
  NSDictionary* identities = [[IFTreeIdentifier treeIdentifier] identifyTree:fakeRoot hints:[NSDictionary dictionary]];
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

- (void)maybeInlineNode:(IFTreeNode*)node transformingMarks:(NSArray*)marks;
{
  if ([node isKindOfClass:[IFTreeNodeMacro class]]) {
    IFTreeNodeMacro* macroNode = (IFTreeNodeMacro*)node;
    if ([macroNode inlineOnInsertion])
      [self inlineMacroNode:macroNode transformingMarks:marks];
  }
}

- (void)ensureGhostNodes;
{
  BOOL hasGhostColumn = NO;
  NSArray* roots = [self roots];
  for (unsigned int i = 0; i < [roots count]; i++) {
    IFTreeNode* root = [roots objectAtIndex:i];
    if ([root isGhost])
      hasGhostColumn |= ([[root parents] count] == 0);
    else if ([root outputArity] == 1) {
      [[root retain] autorelease];
      IFTreeNode* newRoot = [IFTreeNode ghostNodeWithInputArity:1];
      [fakeRoot replaceObjectInParentsAtIndex:i withObject:newRoot];
      [newRoot insertObject:root inParentsAtIndex:0];
    }
  }
  if (!hasGhostColumn)
    [fakeRoot insertObject:[IFTreeNode ghostNodeWithInputArity:0]
          inParentsAtIndex:[[fakeRoot parents] count]];
}

- (void)configureFilters;
{
  NSArray* nodes = [self topologicallySortedNodes];
  NSArray* newConfig = [typeChecker configureDAG:[typeChecker dagFromTopologicallySortedNodes:nodes] withPotentialTypes:[[nodes collect] potentialTypes]];
  [[nodes do] beginReconfiguration];
  for (int i = 0; i < [nodes count]; ++i)
    [[nodes objectAtIndex:i] endReconfigurationWithActiveTypeIndex:[[newConfig objectAtIndex:i] intValue]];
}  

- (void)finishTreeModification;
{
  [self ensureGhostNodes];
  [self configureFilters];
  [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:IFTreeChangedNotification object:self] postingStyle:NSPostWhenIdle];  
}

- (NSArray*)topologicallySortedNodes;
{
  NSMutableArray* nodes = [NSMutableArray arrayWithArray:[fakeRoot topologicallySortedAncestorsWithoutAliases]];
  NSAssert([nodes lastObject] == fakeRoot, @"internal error");
  [nodes removeLastObject];
  return nodes;
}

- (void)overwriteWith:(IFDocument*)other;
{
  // Destroy all current contents
  while ([[fakeRoot parents] count] > 0)
    [fakeRoot removeObjectFromParentsAtIndex:0];

  // Copy everything from other document
  [self setAuthorName:[other authorName]];
  [self setDocumentDescription:[other documentDescription]];
  [self setWorkingSpaceProfile:[other workingSpaceProfile]];
  [self setResolutionX:[other resolutionX]];
  [self setResolutionY:[other resolutionY]];
  
  IFTreeNode* otherFakeRoot = other->fakeRoot; // HACK
  NSArray* otherRoots = [[otherFakeRoot parents] copy];
  for (int i = 0; i < [otherRoots count]; ++i) {
    IFTreeNode* otherRoot = [[otherRoots objectAtIndex:i] retain];
    [otherFakeRoot removeObjectFromParentsAtIndex:0];
    [fakeRoot insertObject:otherRoot inParentsAtIndex:i];
    [otherRoot release];
  }
  [otherRoots release];

  // TODO copy marks
}

#pragma mark Undo support

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
  id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
  if (oldValue == [NSNull null]) oldValue = nil;
  id newValue = [change objectForKey:NSKeyValueChangeNewKey];
  if (newValue == [NSNull null]) newValue = nil;
  int changeKind = [[change objectForKey:NSKeyValueChangeKindKey] intValue];

  if ([keyPath isEqualToString:@"parents"]) {
    IFTreeNode* node = object;
    NSIndexSet* indices = [change objectForKey:NSKeyValueChangeIndexesKey];
    switch (changeKind) {
      case NSKeyValueChangeInsertion:
        [self startObservingTreesIn:newValue];
        [[[self undoManager] prepareWithInvocationTarget:self] removeParentsOfNode:node atIndices:indices];
        break;
      case NSKeyValueChangeRemoval:
        [self stopObservingTreesIn:oldValue];
        [[[self undoManager] prepareWithInvocationTarget:self] insertNodes:oldValue intoParentsOfNode:node atIndices:indices];
        break;
      case NSKeyValueChangeReplacement:
        [self stopObservingTreesIn:oldValue];
        [self startObservingTreesIn:newValue];
        [[[self undoManager] prepareWithInvocationTarget:self] replaceParentsOfNode:node byNodes:oldValue atIndices:indices];
        break;
      case NSKeyValueChangeSetting:
        [self stopObservingTreesIn:oldValue];
        [self startObservingTreesIn:newValue];
        break;
      default:
        NSAssert1(NO, @"unexpected change kind: %d",changeKind);
        break;
    }
    [fakeRoot fixChildLinks];
  } else if ([keyPath isEqualToString:@"keys"]) {
    // Change in the keys of an observed environment
    switch (changeKind) {
      case NSKeyValueChangeInsertion:
        [self startObservingKeys:newValue ofEnvironment:object];
        break;
      case NSKeyValueChangeRemoval:
        [self stopObservingKeys:oldValue ofEnvironment:object];
        break;
      default:
        NSAssert1(NO, @"unexpected change kind: %d",changeKind);
        break;
    }
  } else {
    [[[self undoManager] prepareWithInvocationTarget:self] setValue:oldValue forKey:keyPath inEnvironment:object];
  }
}

- (void)insertNodes:(NSArray*)parents intoParentsOfNode:(IFTreeNode*)node atIndices:(NSIndexSet*)indices;
{
  NSEnumerator* parentsEnum = [parents objectEnumerator];
  for (int i = [indices firstIndex]; i != NSNotFound; i = [indices indexGreaterThanIndex:i])
    [node insertObject:[parentsEnum nextObject] inParentsAtIndex:i];  
}

- (void)removeParentsOfNode:(IFTreeNode*)node atIndices:(NSIndexSet*)indices;
{
  for (int i = [indices firstIndex], c = 0; i != NSNotFound; i = [indices indexGreaterThanIndex:i], ++c)
    [node removeObjectFromParentsAtIndex:(i - c)];
}

- (void)replaceParentsOfNode:(IFTreeNode*)node byNodes:(NSArray*)newParents atIndices:(NSIndexSet*)indices;
{
  NSEnumerator* parentsEnum = [newParents objectEnumerator];
  for (int i = [indices firstIndex]; i != NSNotFound; i = [indices indexGreaterThanIndex:i])
    [node replaceObjectInParentsAtIndex:i withObject:[parentsEnum nextObject]];
}

- (void)setValue:(id)value forKey:(NSString*)key inEnvironment:(IFEnvironment*)env;
{
  [env setValue:value forKey:key];
}

- (void)startObservingTree:(IFTreeNode*)node;
{
  if ([node filter] != nil) // TODO && ![node isAlias] ???
    [self startObservingEnvironment:[[node filter] environment]];
  [node addObserver:self forKeyPath:@"parents" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
  [self startObservingTreesIn:[node parents]];
}

- (void)startObservingTreesIn:(NSArray*)nodes;
{
  if (nodes != nil && nodes != (NSArray*)[NSNull null])
    [[self do] startObservingTree:[nodes each]];
}

- (void)stopObservingTree:(IFTreeNode*)node;
{
  if ([node filter] != nil)
    [self stopObservingEnvironment:[[node filter] environment]];
  [node removeObserver:self forKeyPath:@"parents"];
  [self stopObservingTreesIn:[node parents]];
}

- (void)stopObservingTreesIn:(NSArray*)nodes;
{
  if (nodes != nil && nodes != (NSArray*)[NSNull null])
    [[self do] stopObservingTree:[nodes each]];
}

- (void)startObservingEnvironment:(IFEnvironment*)env;
{
  [env addObserver:self forKeyPath:@"keys" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
  [self startObservingKeys:[env keys] ofEnvironment:env];
}

- (void)stopObservingEnvironment:(IFEnvironment*)env;
{
  [self stopObservingKeys:[env keys] ofEnvironment:env];
  [env removeObserver:self forKeyPath:@"keys"];
}

- (void)startObservingKeys:(NSSet*)keys ofEnvironment:(IFEnvironment*)env;
{
  NSEnumerator* keysEnum = [keys objectEnumerator];
  NSString* key;
  while (key = [keysEnum nextObject]) {
    [env addObserver:self forKeyPath:key options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
  }
}

- (void)stopObservingKeys:(NSSet*)keys ofEnvironment:(IFEnvironment*)env;
{
  NSEnumerator* keysEnum = [keys objectEnumerator];
  NSString* key;
  while (key = [keysEnum nextObject]) {
    [env removeObserver:self forKeyPath:key];
  }
}

@end
