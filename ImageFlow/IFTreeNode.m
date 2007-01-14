//
//  IFTreeNode.m
//  ImageFlow
//
//  Created by Michel Schinz on 20.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFTreeNode.h"
#import "IFTreeMark.h"
#import "IFTreeNodeAlias.h"
#import "IFXMLCoder.h"
#import "IFExpressionPlugger.h"

@interface IFTreeNode (Private)
- (void)dfsCollectAncestorsInArray:(NSMutableArray*)accumulator;
@end

@implementation IFTreeNode

static NSString* IFFilterExpressionChangedContext = @"IFFilterExpressionChangedContext";
static NSString* IFParentExpressionChangedContext = @"IFParentExpressionChangedContext";

const unsigned int ID_NONE = ~0;

+ (id)nodeWithFilter:(IFConfiguredFilter*)theFilter;
{
  return [[[IFTreeNode alloc] initWithFilter:theFilter] autorelease];
}

- (id)initWithFilter:(IFConfiguredFilter*)theFilter;
{
  if (![super init]) return nil;
  name = nil;
  isFolded = NO;
  filter = [theFilter retain];
  [filter addObserver:self forKeyPath:@"expression" options:0 context:IFFilterExpressionChangedContext];
  parents = [NSMutableArray new];
  child = nil;
  return self;
}

- (void)dealloc;
{
  child = nil;
  while ([parents count] > 0)
    [self removeObjectFromParentsAtIndex:0];
  OBJC_RELEASE(parents);
  OBJC_RELEASE(expression);
  [filter removeObserver:self forKeyPath:@"expression"];  
  OBJC_RELEASE(filter);
  OBJC_RELEASE(name);
  [super dealloc];
}

- (IFTreeNode*)cloneNode;
{
  NSAssert([self class] == [IFTreeNode class], @"missing redefiniton of <clone> method");
  return [IFTreeNode nodeWithFilter:[filter clone]];
}

- (IFTreeNode*)cloneNodeAndAncestors;
{
  IFTreeNode* clone = [self cloneNode];
  NSArray* parentsToClone = [self parents];
  for (int i = 0; i < [parentsToClone count]; ++i)
    [clone insertObject:[[parentsToClone objectAtIndex:i] cloneNodeAndAncestors] inParentsAtIndex:i];
  return clone;
}

#pragma mark Parents and child

- (NSArray*)parents;
{
  return parents;
}

- (void)insertObject:(IFTreeNode*)parent inParentsAtIndex:(unsigned int)index;
{
  [parent setChild:self];
  [parents insertObject:parent atIndex:index];
  
  [self updateExpression];
  [parent addObserver:self forKeyPath:@"expression" options:0 context:IFParentExpressionChangedContext];
}

- (void)removeObjectFromParentsAtIndex:(unsigned int)index;
{
  IFTreeNode* parent = [parents objectAtIndex:index];
  [parent removeObserver:self forKeyPath:@"expression"];
  
  [parent setChild:nil];
  [parents removeObjectAtIndex:index];
  
  [self updateExpression];
}

- (void)replaceObjectInParentsAtIndex:(unsigned int)index withObject:(IFTreeNode*)newParent;
{
  IFTreeNode* oldParent = [parents objectAtIndex:index];
  [oldParent removeObserver:self forKeyPath:@"expression"];
  
  [newParent setChild:self];
  [parents replaceObjectAtIndex:index withObject:newParent];
  
  [newParent addObserver:self forKeyPath:@"expression" options:0 context:IFParentExpressionChangedContext];
  [self updateExpression];
}

- (void)setChild:(IFTreeNode*)newChild;
{
  child = newChild;
}

- (IFTreeNode*)child;
{
  return child;
}

- (NSArray*)dfsAncestors;
{
  NSMutableArray* result = [NSMutableArray array];
  [self dfsCollectAncestorsInArray:result];
  return result;
}

- (NSArray*)topologicallySortedAncestorsWithoutAliases;
{
  NSArray* nodes = [self dfsAncestors];
  NSMutableArray* sortedNodes = [NSMutableArray arrayWithCapacity:[nodes count]];
  NSMutableSet* seenNodes = [NSMutableSet setWithCapacity:[nodes count]];
  for (int i = 0, count = [nodes count]; [sortedNodes count] < count; i = (i + 1) % count) {
    IFTreeNode* node = [nodes objectAtIndex:i];
    NSSet* parentsSet = [NSSet setWithArray:[[node original] parents]];
    if (![seenNodes containsObject:node] && [parentsSet isSubsetOfSet:seenNodes]) {
      if (![node isAlias])
        [sortedNodes addObject:node];
      [seenNodes addObject:node];
    }
  }
  return sortedNodes;
}

- (BOOL)isParentOf:(IFTreeNode*)other;
{
  return (other != nil) && (self == other || [[self child] isParentOf:other]);
}

#pragma mark Attributes

- (void)setName:(NSString*)newName;
{
  if (name == newName)
    return;
  [name release];
  name = [newName retain];
}

- (NSString*)name;
{
  return name;
}

- (void)setIsFolded:(BOOL)newIsFolded;
{
  isFolded = newIsFolded;
}

- (BOOL)isFolded;
{
  return isFolded;
}

- (BOOL)isGhost;
{
  return [filter isGhost];
}

- (BOOL)isAlias;
{
  return NO;
}

- (IFTreeNode*)original;
{
  return self;
}

- (IFConfiguredFilter*)filter;
{
  return filter;
}

- (IFExpression*)expression;
{
  if (expression == nil)
    [self updateExpression];
  return expression;
}

- (NSArray*)potentialTypes;
{
  return [filter potentialTypes];
}

- (int)inputArity;
{
  return [[[self potentialTypes] objectAtIndex:0] arity];
}

- (int)outputArity;
{
  NSLog(@"TODO outputArity");
  return 1;
}

- (void)replaceByNode:(IFTreeNode*)replacement transformingMarks:(NSArray*)marks;
{
  NSAssert([[replacement parents] count] == 0 && [replacement child] == nil, @"non-detached replacement node");
  
  NSArray* parentsCopy = [[self parents] copy];
  for (int i = 0; i < [parentsCopy count]; i++) {
    IFTreeNode* ghost = [IFTreeNode nodeWithFilter:[IFConfiguredFilter ghostFilterWithInputArity:0]];
    [self replaceObjectInParentsAtIndex:i withObject:ghost];
    IFTreeNode* parent = [parentsCopy objectAtIndex:i];
    [replacement insertObject:parent inParentsAtIndex:i];
  }
  [parentsCopy release];

  [child replaceObjectInParentsAtIndex:[[child parents] indexOfObject:self]
                            withObject:replacement];
  
  for (int i = 0; i < [marks count]; ++i)
    [[marks objectAtIndex:i] setNode:replacement ifCurrentNodeIs:self];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  NSAssert(context == IFFilterExpressionChangedContext || context == IFParentExpressionChangedContext, @"unexpected context");
  [self updateExpression];
}

#pragma mark -
#pragma mark Protected

- (void)updateExpression;
{
  if (filter == nil)
    return;
  NSMutableDictionary* parentEnv = [NSMutableDictionary dictionary];
  for (int i = 0; i < [parents count]; ++i)
    [parentEnv setObject:[[parents objectAtIndex:i] expression] forKey:[NSNumber numberWithInt:i]];
  [self setExpression:[IFExpressionPlugger plugValuesInExpression:[filter expression] withValuesFromParentsEnvironment:parentEnv]];
}

- (void)setExpression:(IFExpression*)newExpression;
{
  if (newExpression == expression)
    return;
  [expression release];
  expression = [newExpression retain];
}

#pragma mark -
#pragma mark Debugging

- (void)debugCheckLinks;
{
  NSArray* myParents = [self parents];
  for (int i = 0; i < [myParents count]; ++i) {
    IFTreeNode* parent = [myParents objectAtIndex:i];
    [parent debugCheckLinks];
    NSAssert3([parent child] == self,@"invalid child for node %@: should be %@, is %@",parent,self,[parent child]);
  }
}

@end

@implementation IFTreeNode (Private)

- (void)dfsCollectAncestorsInArray:(NSMutableArray*)accumulator;
{
  [[parents do] dfsCollectAncestorsInArray:accumulator];
  [accumulator addObject:self];
}

@end
