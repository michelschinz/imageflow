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
#import "IFConfiguredFilter.h"
#import "IFExpressionEvaluator.h"
#import "IFDirectoryManager.h"
#import "IFDocumentTemplate.h"
#import "IFDocumentTemplateManager.h"
#import "IFTreeNodeParameter.h"

@interface IFDocument (Private)
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
//  evaluator = [IFExpressionEvaluatorCI new];
  evaluator = [IFExpressionEvaluator new];

  marks = [[NSArray alloc] initWithObjects:
    [IFTreeMark markWithTag:@"c"],
    [IFTreeMark markWithTag:@"1"],
    [IFTreeMark markWithTag:@"2"],
    [IFTreeMark markWithTag:@"3"],
    [IFTreeMark markWithTag:@"4"],
    [IFTreeMark markWithTag:@"5"],
    [IFTreeMark markWithTag:@"6"],
    [IFTreeMark markWithTag:@"7"],
    [IFTreeMark markWithTag:@"8"],
    [IFTreeMark markWithTag:@"9"],
    nil];

  fakeRoot = [[IFTreeNode nodeWithFilter:nil] retain];
  [self ensureGhostNodes];
  [self startObservingTree:fakeRoot];
  
  workingSpaceProfile = nil;
  [self setWorkingSpaceProfile:[IFColorProfile profileDefaultRGB]];
  [self setResolutionX:300];
  [self setResolutionY:300];
  
  return self;
}

- (void)dealloc;
{
  [self stopObservingTree:fakeRoot];
  [fakeRoot release];
  fakeRoot = nil;
  [marks release];
  marks = nil;

  [workingSpaceProfile release];
  workingSpaceProfile = nil;
  
  if (documentDescription != nil) {
    [documentDescription release];
    documentDescription = nil;
  }
  if (authorName != nil) {
    [authorName release];
    authorName = nil;
  }
  if (title != nil) {
    [title release];
    title = nil;
  }
  
  [evaluator release];
  evaluator = nil;
  
  [super dealloc];
}

-(void)makeWindowControllers {
  [self addWindowController:[IFTreeViewWindowController new]];
}

- (IFExpressionEvaluator*)evaluator;
{
  return evaluator;
}

- (NSArray*)roots;
{
  return [fakeRoot parents];
}

- (NSArray*)marks;
{
  return marks;
}

- (IFTreeMark*)cursorMark;
{
  return [[self marks] objectAtIndex:0];
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
  return [parent acceptsParents:[[child parents] count]]
  && [parent acceptsChildren:1]
  && [child acceptsParents:1];
}

- (void)insertNode:(IFTreeNode*)parent asParentOf:(IFTreeNode*)child;
{
  if (![self canInsertNode:parent asParentOf:child]) {
    NSBeep();
    return;
  }
  int parentsCount = [[child parents] count];
  for (int i = 0; i < parentsCount; ++i) {
    IFTreeNode* p = [[[child parents] objectAtIndex:0] retain];
    [child removeObjectFromParentsAtIndex:0];
    [parent insertObject:p inParentsAtIndex:i];
    [p release];
  }
  [child insertObject:parent inParentsAtIndex:0];
  [self ensureGhostNodes];
}

- (BOOL)canInsertNode:(IFTreeNode*)child asChildOf:(IFTreeNode*)parent;
{
  return [parent acceptsChildren:1] && [child acceptsParents:1];
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
  [self ensureGhostNodes];
}

- (BOOL)canReplaceNode:(IFTreeNode*)node usingNode:(IFTreeNode*)replacement;
{
  const int parentsCount = [[node parents] count];
  int ghostsToAdd;
  for (ghostsToAdd = 0; ![replacement acceptsParents:parentsCount+ghostsToAdd] && ghostsToAdd < 10; ++ghostsToAdd) // HACK
    ;
  return [replacement acceptsParents:parentsCount+ghostsToAdd] && [replacement acceptsChildren:([node child] == fakeRoot ? 0 : 1)];    
}

- (void)replaceNode:(IFTreeNode*)node usingNode:(IFTreeNode*)replacement;
{
  if (![self canReplaceNode:node usingNode:replacement]) {
    NSBeep();
    return;
  }
  const int parentsCount = [[node parents] count];
  int ghostsToAdd;
  for (ghostsToAdd = 0; ![replacement acceptsParents:parentsCount+ghostsToAdd]; ++ghostsToAdd) // HACK
    ;
  [node replaceByNode:replacement transformingMarks:marks];
  for (int i = 0; i < ghostsToAdd; ++i)
    [replacement insertObject:[IFTreeNode nodeWithFilter:[IFConfiguredFilter ghostFilter]]
             inParentsAtIndex:parentsCount + i];
  [self ensureGhostNodes];
}

- (void)deleteNode:(IFTreeNode*)node;
{
  NSArray* parents = [node parents];
  IFTreeNode* child = [node child];
  int nodeIndex = [[child parents] indexOfObject:node];
  IFTreeNode* ghost = [IFTreeNode nodeWithFilter:[IFConfiguredFilter ghostFilter]];
  switch ([parents count]) {
    case 0: {
      if ([child acceptsParents:([[child parents] count] - 1)])
        [child removeObjectFromParentsAtIndex:nodeIndex];
      else
        [node replaceByNode:ghost transformingMarks:marks];
    } break;
    case 1: {
      IFTreeNode* singleParent = [parents objectAtIndex:0];
      [[self cursorMark] setNode:singleParent ifCurrentNodeIs:node];
      [[marks do] setNode:nil ifCurrentNodeIs:node];
      [node replaceObjectInParentsAtIndex:0 withObject:ghost];
      [child replaceObjectInParentsAtIndex:nodeIndex withObject:singleParent];
    } break;
    default: {
      [node replaceByNode:ghost transformingMarks:marks];
    }
  }
  [self ensureGhostNodes];
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

- (void)inlineMacroNode:(IFTreeNodeMacro*)macroNode;
{
  // Detach all parents of macro node
  NSMutableArray* detachedMacroParents = [NSMutableArray array];
  NSArray* macroParents = [macroNode parents];
  for (int i = 0; i < [macroParents count]; ++i) {
    IFTreeNode* parent = [macroParents objectAtIndex:i];
    [detachedMacroParents addObject:parent];
    [macroNode replaceObjectInParentsAtIndex:i withObject:[IFTreeNode nodeWithFilter:[IFConfiguredFilter ghostFilter]]];
  }

  // Clone macro node body, and replace parameter nodes by parent nodes, introducing aliases when necessary
  IFTreeNode* bodyRootClone = [[macroNode root] deepClone];
  NSAssert(![bodyRootClone isKindOfClass:[IFTreeNodeParameter class]], @"unexpected parameter node");
  replaceParameterNodes(bodyRootClone, detachedMacroParents);
  int macroIndex = [[[macroNode child] parents] indexOfObject:macroNode];
  [[macroNode child] replaceObjectInParentsAtIndex:macroIndex withObject:bodyRootClone];
  
  [[marks do] setNode:bodyRootClone ifCurrentNodeIs:macroNode];
}

#pragma mark exportation

- (NSArray*)collectExportersForKind:(NSString*)kind startingAt:(IFTreeNode*)root;
{
  NSMutableArray* exporters = [NSMutableArray array];
  if ([kind isEqualToString:[[[root filter] filter] exporterKind]])
    [exporters addObject:root];
  NSArray* parentExporters = [[self collect] collectExportersForKind:kind startingAt:[[root parents] each]];
  for (int i = 0; i < [parentExporters count]; ++i)
    [exporters addObjectsFromArray:[parentExporters objectAtIndex:i]];
  return exporters;
}

- (void)exportForKind:(NSString*)kind;
{
  NSArray* exporters = [self collectExportersForKind:kind startingAt:fakeRoot];
  for (int i = 0; i < [exporters count]; ++i) {
    IFTreeNode* node = [exporters objectAtIndex:i];
    IFConfiguredFilter* configuredFilter = [node filter];
    IFImageConstantExpression* imageExpr = (IFImageConstantExpression*)[evaluator evaluateExpression:[[[node parents] objectAtIndex:0] expression]];
    [[configuredFilter filter] exportImage:imageExpr environment:[configuredFilter environment] document:self];
  }
}

- (IBAction)exportAllFiles:(id)sender;
{
  [self exportForKind:@"file"];
}

- (IBAction)exportAllPrints:(id)sender;
{
  [self exportForKind:@"printer"];
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

- (void)overwriteWith:(IFDocument*)other;
{
  // Destroy all current contents
  while ([[fakeRoot parents] count] > 0)
    [fakeRoot removeObjectFromParentsAtIndex:0];
  for (int i = 0; i < [marks count]; ++i)
    [[marks objectAtIndex:i] unset];

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
    else if ([root acceptsChildren:1]) {
      [[root retain] autorelease];
      IFTreeNode* newRoot = [IFTreeNode nodeWithFilter:[IFConfiguredFilter ghostFilter]];
      [fakeRoot replaceObjectInParentsAtIndex:i withObject:newRoot];
      [newRoot insertObject:root inParentsAtIndex:0];
    }
  }
  if (!hasGhostColumn)
    [fakeRoot insertObject:[IFTreeNode nodeWithFilter:[IFConfiguredFilter ghostFilter]]
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
