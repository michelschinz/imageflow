//
//  IFConfiguredFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 22.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFConfiguredFilter.h"
#import "IFType.h"

@interface IFConfiguredFilter (Private)
- (void)startObservingEnvironmentKeys:(NSSet*)keys;
- (void)stopObservingEnvironmentKeys:(NSSet*)keys;
- (void)updateExpression;
- (void)setExpression:(IFExpression*)newExpression;
@end

@implementation IFConfiguredFilter

static NSString* IFEnvironmentKeySetDidChangeContext = @"IFEnvironmentKeySetDidChangeContext";
static NSString* IFEnvironmentValueDidChangeContext = @"IFEnvironmentValueDidChangeContext";

+ (IFConfiguredFilter*)ghostFilterWithInputArity:(int)inputArity;
{
  IFEnvironment* env = [IFEnvironment environment];
  [env setValue:[NSNumber numberWithInt:inputArity] forKey:@"inputArity"];
  return [[[self alloc] initWithFilter:[IFFilter filterForName:@"nop"] environment:env] autorelease];
}

+ (id)configuredFilterWithFilter:(IFFilter*)theFilter environment:(IFEnvironment*)theEnvironment;
{
  return [[[self alloc] initWithFilter:theFilter environment:theEnvironment] autorelease];
}

- (id)initWithFilter:(IFFilter*)theFilter environment:(IFEnvironment*)theEnvironment;
{
  if (![super init])
    return nil;
  filter = [theFilter retain];
  filterEnvironment = [theEnvironment retain];
  expression = nil;
  
  [self startObservingEnvironmentKeys:[filterEnvironment keys]];
  [filterEnvironment addObserver:self forKeyPath:@"keys" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:IFEnvironmentKeySetDidChangeContext];
  
  return self;
}

- (void)dealloc;
{
  [filterEnvironment removeObserver:self forKeyPath:@"keys"];
  [self stopObservingEnvironmentKeys:[filterEnvironment keys]];
  
  OBJC_RELEASE(filterEnvironment);
  OBJC_RELEASE(filter);
  [super dealloc];
}

- (IFConfiguredFilter*)clone;
{
  return [IFConfiguredFilter configuredFilterWithFilter:filter environment:[filterEnvironment clone]];
}

- (IFFilter*)filter;
{
  return filter;
}

- (IFEnvironment*)environment;
{
  return filterEnvironment;
}

- (BOOL)isGhost;
{
  return [filter isGhost];
}

- (NSArray*)potentialTypes;
{
  return [filter potentialTypesWithEnvironment:filterEnvironment];
}

- (IFExpression*)expression;
{
  if (expression == nil)
    [self updateExpression];
  return expression;
}

- (NSString*)label;
{
  return [filter labelWithEnvironment:filterEnvironment];
}

- (NSString*)toolTip;
{
  return [filter toolTipWithEnvironment:filterEnvironment];
}

@end

@implementation IFConfiguredFilter (Private)

- (void)startObservingEnvironmentKeys:(NSSet*)keys;
{
  NSEnumerator* keysEnum = [keys objectEnumerator];
  NSString* key;
  while (key = [keysEnum nextObject])
    [filterEnvironment addObserver:self forKeyPath:key options:0 context:IFEnvironmentValueDidChangeContext];
}

- (void)stopObservingEnvironmentKeys:(NSSet*)keys;
{
  NSEnumerator* keysEnum = [keys objectEnumerator];
  NSString* key;
  while (key = [keysEnum nextObject])
    [filterEnvironment removeObserver:self forKeyPath:key];
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
  [self setExpression:[filter expressionWithEnvironment:filterEnvironment]];
}

- (void)setExpression:(IFExpression*)newExpression;
{
  if (newExpression == expression)
    return;
  [expression release];
  expression = [newExpression retain];
}

@end
