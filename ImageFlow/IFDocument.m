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
#import "IFTreeNodeParameter.h"
#import "IFTreeNodeAlias.h"

#import <caml/memory.h>
#import <caml/alloc.h>
#import <caml/callback.h>

@interface IFDocument (Private)
- (NSArray*)topologicallySortedNodes;
- (void)overwriteWith:(IFDocument*)other;
- (void)ensureGhostNodes;
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
- (IBAction)debugCheckTree:(id)sender;
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
  evaluator = [IFExpressionEvaluator new];

  fakeRoot = [[IFTreeNode nodeWithFilter:nil] retain];
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
  [self ensureGhostNodes];
}

- (BOOL)canInsertNode:(IFTreeNode*)parent asParentOf:(IFTreeNode*)child;
{
  // TODO check types instead of arity only
  return [parent inputArity] >= [[child parents] count]
  && [parent outputArity] == 1
  && [child inputArity] >= 1;
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
  [self ensureGhostNodes];
}

- (BOOL)canInsertNode:(IFTreeNode*)child asChildOf:(IFTreeNode*)parent;
{
  // TODO check types instead of arity only
  return [parent outputArity] == 1 && [child inputArity] >= 1;
}

- (void)insertNode:(IFTreeNode*)child asChildOf:(IFTreeNode*)parent;
{
  if (![self canInsertNode:child asChildOf:parent]) {
    NSBeep();
    return;
  }
  IFTreeNode* originalChild = [parent child];
  int parentIndex = [[originalChild parents] indexOfObject:parent];
  [originalChild replaceObjectInParentsAtIndex:parentIndex withObject:child];
  [child insertObject:parent inParentsAtIndex:0];
  // TODO add ghost parents if needed
  [self ensureGhostNodes];
}

static value camlCons(value h, value t) {
  CAMLparam2(h,t);
  CAMLlocal1(cell);
  cell = caml_alloc(2, 0);
  Store_field(cell, 0, h);
  Store_field(cell, 1, t);
  CAMLreturn(cell);
}

static value camlCanReplaceGhostNodeUsingNode(NSArray* constraints, NSArray* potentialTypes) {
  CAMLparam0();
  CAMLlocal4(camlConstraints, camlConstraint, camlPotentialTypes, camlTypes);

  // Transform constraints to lists (of lists of ints)
  camlConstraints = Val_int(0);
  for (int i = [constraints count] - 1; i >= 0; --i) {
    NSArray* constraint = [constraints objectAtIndex:i];
    camlConstraint = Val_int(0);
    for (int j = [constraint count] - 1; j >= 0; --j) {
      int c = [[constraint objectAtIndex:j] intValue];
      camlConstraint = camlCons(Val_int(c), camlConstraint);
    }
    camlConstraints = camlCons(camlConstraint, camlConstraints);
  }
  
  // Transform potential types to their Caml equivalent
  camlPotentialTypes = Val_int(0);
  for (int i = [potentialTypes count] - 1; i >= 0; --i) {
    NSArray* types = [potentialTypes objectAtIndex:i];
    camlTypes = Val_int(0);
    for (int j = [types count] - 1; j >= 0; --j) {
      IFType* type = [types objectAtIndex:j];
      camlTypes = camlCons([type asCaml], camlTypes);
    }
    camlPotentialTypes = camlCons(camlTypes,camlPotentialTypes);
  }

  static value* validConfigurationExistsClosure = NULL;
  if (validConfigurationExistsClosure == NULL)
    validConfigurationExistsClosure = caml_named_value("Typechecker.check");

  CAMLreturn(caml_callback2(*validConfigurationExistsClosure, camlConstraints, camlPotentialTypes));
}

- (BOOL)canReplaceGhostNode:(IFTreeNode*)ghost usingNode:(IFTreeNode*)replacement;
{
  NSArray* sortedNodes = [self topologicallySortedNodes];
  int nodesCount = [sortedNodes count];

  NSMutableArray* constraints = [NSMutableArray arrayWithCapacity:nodesCount];
  for (int i = 0; i < nodesCount; ++i) {
    IFTreeNode* node = [sortedNodes objectAtIndex:i];
    NSArray* parents = [node parents];
    NSMutableArray* constraint = [NSMutableArray arrayWithCapacity:[parents count]];
    for (int j = 0, pCount = [parents count]; j < pCount; ++j)
      [constraint addObject:[NSNumber numberWithInt:[sortedNodes indexOfObject:[[parents objectAtIndex:j] original]]]];
    [constraints addObject:constraint];
  }

  NSMutableArray* potentialTypes = [NSMutableArray arrayWithCapacity:nodesCount];
  for (int i = 0; i < nodesCount; ++i) {
    IFTreeNode* node = [sortedNodes objectAtIndex:i];
    if (node == ghost) {
      NSArray* replacementPotentialTypes = [replacement potentialTypes];
      NSMutableArray* limitedReplacementTypes = [NSMutableArray arrayWithCapacity:[replacementPotentialTypes count]];
      for (int i = 0; i < [replacementPotentialTypes count]; ++i)
        [limitedReplacementTypes addObject:[[replacementPotentialTypes objectAtIndex:i] typeByLimitingArityTo:[ghost inputArity]]];
      [potentialTypes addObject:limitedReplacementTypes];
    } else
      [potentialTypes addObject:[node potentialTypes]];
  }

  return Bool_val(camlCanReplaceGhostNodeUsingNode(constraints, potentialTypes));
}

- (void)replaceGhostNode:(IFTreeNode*)node usingNode:(IFTreeNode*)replacement transformingMarks:(NSArray*)marks;
{
  NSAssert([self canReplaceGhostNode:node usingNode:replacement], @"internal error");

  const int parentsCount = [[node parents] count];
  const int ghostsToAdd = [replacement inputArity] - parentsCount;
  [node replaceByNode:replacement transformingMarks:marks];
  for (int i = 0; i < ghostsToAdd; ++i)
    [replacement insertObject:[IFTreeNode nodeWithFilter:[IFFilter ghostFilterWithInputArity:0]]
             inParentsAtIndex:parentsCount + i];
  if ([replacement isKindOfClass:[IFTreeNodeMacro class]]) {
    IFTreeNodeMacro* macroReplacement = (IFTreeNodeMacro*)replacement;
    if ([macroReplacement inlineOnInsertion])
      [self inlineMacroNode:macroReplacement transformingMarks:marks];
  }
  [self ensureGhostNodes];
}

// private
- (void)deleteSingleNode:(IFTreeNode*)node transformingMarks:(NSArray*)marks;
{
  IFTreeNode* ghost = [IFTreeNode nodeWithFilter:[IFFilter ghostFilterWithInputArity:[node inputArity]]];
  // TODO avoid inserting ghost when possible (i.e. the tree is well-typed even without it).
  [node replaceByNode:ghost transformingMarks:marks];
  [self ensureGhostNodes];
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
      [root replaceObjectInParentsAtIndex:i withObject:[IFTreeNode nodeWithFilter:[IFFilter ghostFilterWithInputArity:0]]];
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
  [[root child] replaceObjectInParentsAtIndex:rootIndex withObject:[IFTreeNode nodeWithFilter:[IFFilter ghostFilterWithInputArity:0]]];
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
    [macroNode replaceObjectInParentsAtIndex:i withObject:[IFTreeNode nodeWithFilter:[IFFilter ghostFilterWithInputArity:0]]];
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

// TODO this should be done by the observation routines
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
      IFTreeNode* newRoot = [IFTreeNode nodeWithFilter:[IFFilter ghostFilterWithInputArity:1]];
      [fakeRoot replaceObjectInParentsAtIndex:i withObject:newRoot];
      [newRoot insertObject:root inParentsAtIndex:0];
    }
  }
  if (!hasGhostColumn)
    [fakeRoot insertObject:[IFTreeNode nodeWithFilter:[IFFilter ghostFilterWithInputArity:0]]
          inParentsAtIndex:[[fakeRoot parents] count]];
  [self debugCheckTree:self];
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
    [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:IFTreeChangedNotification object:self]
                                               postingStyle:NSPostWhenIdle];
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

#pragma mark Debugging

- (IBAction)debugCheckTree:(id)sender;
{
  [fakeRoot debugCheckLinks];
}

@end
