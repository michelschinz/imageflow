//
//  IFFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 22.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFFilter.h"
#import "IFDirectoryManager.h"
#import "IFExpressionPlugger.h"

@interface IFFilter (Private)
- (void)startObservingEnvironmentKeys:(NSSet*)keys;
- (void)stopObservingEnvironmentKeys:(NSSet*)keys;
- (void)updateExpression;
- (void)setExpression:(IFExpression*)newExpression;
@end

static NSString* IFEnvironmentKeySetDidChangeContext = @"IFEnvironmentKeySetDidChangeContext";
static NSString* IFEnvironmentValueDidChangeContext = @"IFEnvironmentValueDidChangeContext";

@implementation IFFilter

+ (id)ghostFilterWithInputArity:(int)inputArity;
{
  IFEnvironment* env = [IFEnvironment environment];
  [env setValue:[NSNumber numberWithInt:inputArity] forKey:@"inputArity"];
  return [self filterWithName:@"IFGhostFilter" environment:env];
}

+ (id)filterWithName:(NSString*)filterName environment:(IFEnvironment*)theEnvironment;
{
  Class cls = [[NSBundle mainBundle] classNamed:filterName];
  NSAssert1(cls != nil, @"cannot find class for filter named '%@'",filterName);
  return [[[cls alloc] initWithEnvironment:theEnvironment] autorelease];
}

- (id)initWithEnvironment:(IFEnvironment*)theEnvironment;
{
  if (![super init])
    return nil;
  environment = [theEnvironment retain];
  activeTypeIndex = 0;
  expression = nil;
  settingsNib = nil;
  
  [self startObservingEnvironmentKeys:[environment keys]];
  [environment addObserver:self forKeyPath:@"keys" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:IFEnvironmentKeySetDidChangeContext];
  
  return self;
}

- (void)dealloc;
{
  [environment removeObserver:self forKeyPath:@"keys"];
  [self stopObservingEnvironmentKeys:[environment keys]];

  OBJC_RELEASE(settingsNib);
  OBJC_RELEASE(expression);
  OBJC_RELEASE(environment);
  [super dealloc];
}

- (IFFilter*)clone;
{
  return [IFFilter filterWithName:[self name] environment:[environment clone]];
}

- (NSString*)name;
{
  return [self className];
}

- (IFEnvironment*)environment;
{
  return environment;
}

- (BOOL)isGhost;
{
  return NO;
}

- (NSArray*)potentialTypes;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (NSArray*)potentialRawExpressions;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (int)activeTypeIndex;
{
  return activeTypeIndex;
}

- (void)setActiveTypeIndex:(int)newIndex;
{
  if (newIndex == activeTypeIndex)
    return;
  activeTypeIndex = newIndex;
  [self updateExpression];
}

- (IFExpression*)expression;
{
  if (expression == nil)
    [self updateExpression];
  return expression;
}

- (NSArray*)instantiateSettingsNibWithOwner:(NSObject*)owner;
{
  if (settingsNib == nil) {
    settingsNib = [[NSNib alloc] initWithNibNamed:[self className] bundle:nil];
    if (settingsNib == nil)
      return nil; // Nib file does not exist
  }

  NSArray* topLevelObjects = nil;
  BOOL nibOk = [settingsNib instantiateNibWithOwner:owner topLevelObjects:&topLevelObjects];
  NSAssert1(nibOk, @"error during nib instantiation %@", settingsNib);
  
  return topLevelObjects;
}

- (NSString*)nameOfParentAtIndex:(int)index;
{
  return [NSString stringWithFormat:@"parent %d",index];
}

- (NSString*)label;
{
  return [self name];
}

- (NSString*)toolTip;
{
  return [self label];
}

- (NSArray*)editingAnnotationsForNode:(IFTreeNode*)node view:(NSView*)view;
{
  return [NSArray array];
}

- (void)mouseDown:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
{
  // do nothing by default
}

- (void)mouseDragged:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
{
  // do nothing by default
}

- (void)mouseUp:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
{
  // do nothing by default
}

- (NSArray*)variantNamesForViewing;
{
  return [NSArray arrayWithObject:@""];
}

- (NSArray*)variantNamesForEditing;
{
  return [NSArray arrayWithObject:@""];  
}

- (IFExpression*)variantNamed:(NSString*)variantName ofExpression:(IFExpression*)originalExpression;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (NSAffineTransform*)transformForParentAtIndex:(int)index;
{
  return [NSAffineTransform transform];
}

@end

@implementation IFFilter (Private)

- (void)startObservingEnvironmentKeys:(NSSet*)keys;
{
  NSEnumerator* keysEnum = [keys objectEnumerator];
  NSString* key;
  while (key = [keysEnum nextObject])
    [environment addObserver:self forKeyPath:key options:0 context:IFEnvironmentValueDidChangeContext];
}

- (void)stopObservingEnvironmentKeys:(NSSet*)keys;
{
  NSEnumerator* keysEnum = [keys objectEnumerator];
  NSString* key;
  while (key = [keysEnum nextObject])
    [environment removeObserver:self forKeyPath:key];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  if (context == IFEnvironmentKeySetDidChangeContext) {
    NSSet* oldKeys = [change objectForKey:NSKeyValueChangeOldKey];
    NSSet* newKeys = [change objectForKey:NSKeyValueChangeNewKey];
    int changeKind = [(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue];
    switch (changeKind) {
      case NSKeyValueChangeInsertion:
        [self startObservingEnvironmentKeys:newKeys];
        break;
      case NSKeyValueChangeRemoval:
        [self stopObservingEnvironmentKeys:oldKeys];
        break;
      default:
        NSAssert(NO, @"unexpected change kind");
        break;
    }
  } else if (context == IFEnvironmentValueDidChangeContext) {
    [self updateExpression]; // TODO only if key is part of expression
  } else
    NSAssert(NO, @"unexpected context");
}

- (void)updateExpression;
{
  [self setExpression:[IFExpressionPlugger plugValuesInExpression:[[self potentialRawExpressions] objectAtIndex:activeTypeIndex] withValuesFromVariablesEnvironment:[environment asDictionary]]];
}

- (void)setExpression:(IFExpression*)newExpression;
{
  if (newExpression == expression)
    return;
  [expression release];
  expression = [newExpression retain];
}

@end
