//
//  IFTreeNode.m
//  ImageFlow
//
//  Created by Michel Schinz on 20.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFTreeNode.h"
#import "IFTreeNodeFilter.h"
#import "IFExpressionPlugger.h"
#import "IFTreeMark.h"

@interface IFTreeNode (Private)
- (void)setChild:(IFTreeNode*)newChild;
- (void)dfsCollectAncestorsInArray:(NSMutableArray*)accumulator;
@end

@implementation IFTreeNode

static NSString* IFParentExpressionChangedContext = @"IFParentExpressionChangedContext";

+ (id)ghostNodeWithInputArity:(int)inputArity;
{
  IFEnvironment* env = [IFEnvironment environment];
  [env setValue:[NSNumber numberWithInt:inputArity] forKey:@"inputArity"];
  return [IFTreeNodeFilter nodeWithFilter:[IFFilter filterWithName:@"IFGhostFilter" environment:env]];
}

- (id)init;
{
  if (![super init]) return nil;
  name = nil;
  isFolded = NO;
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
  OBJC_RELEASE(name);
  [super dealloc];
}

- (IFTreeNode*)cloneNode;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
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

- (IFTreeNode*)child;
{
  return child;
}

- (void)fixChildLinks;
{
  NSArray* myParents = [self parents];
  for (int i = 0; i < [myParents count]; ++i) {
    IFTreeNode* parent = [myParents objectAtIndex:i];
    [parent setChild:self];
    [parent fixChildLinks];
  }
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
  for (int i = 0, count = [nodes count]; [seenNodes count] < count; i = (i + 1) % count) {
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

- (void)replaceByNode:(IFTreeNode*)replacement transformingMarks:(NSArray*)marks;
{
  NSAssert([[replacement parents] count] == 0 && [replacement child] == nil, @"non-detached replacement node");
  
  NSArray* parentsCopy = [[self parents] copy];
  for (int i = 0; i < [parentsCopy count]; i++) {
    IFTreeNode* ghost = [IFTreeNode ghostNodeWithInputArity:0];
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
  return NO;
}

- (BOOL)isAlias;
{
  return NO;
}

- (IFTreeNode*)original;
{
  return self;
}

- (IFFilter*)filter;
{
  return nil;
}

- (IFExpression*)expression;
{
  if (expression == nil)
    [self updateExpression];
  return expression;
}

- (NSArray*)potentialTypes;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (void)beginReconfiguration;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (void)endReconfigurationWithActiveTypeIndex:(int)typeIndex;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (int)inputArity;
{
  return [[[self potentialTypes] objectAtIndex:0] arity];
}

- (int)outputArity;
{
  // TODO
  return 1;
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  NSAssert(context == IFParentExpressionChangedContext, @"unexpected context");
  [self updateExpression];
}

#pragma mark Tree view support

- (NSString*)nameOfParentAtIndex:(int)index;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (NSString*)label;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (NSString*)toolTip;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

#pragma mark Image view support

- (NSArray*)editingAnnotationsForView:(NSView*)view;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (void)mouseDown:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (void)mouseDragged:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (void)mouseUp:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (NSArray*)variantNamesForViewing;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (NSArray*)variantNamesForEditing;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (IFExpression*)variantNamed:(NSString*)variantName ofExpression:(IFExpression*)originalExpression;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (NSAffineTransform*)transformForParentAtIndex:(int)index;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

#pragma mark -
#pragma mark (protected)

- (void)updateExpression;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (void)setExpression:(IFExpression*)newExpression;
{
  if (newExpression == expression)
    return;
  [expression release];
  expression = [newExpression retain];
}

@end

@implementation IFTreeNode (Private)

- (void)setChild:(IFTreeNode*)newChild;
{
  child = newChild;
}

- (void)dfsCollectAncestorsInArray:(NSMutableArray*)accumulator;
{
  [[parents do] dfsCollectAncestorsInArray:accumulator];
  [accumulator addObject:self];
}

@end
