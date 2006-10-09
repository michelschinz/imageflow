//
//  IFConfiguredFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 22.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFConfiguredFilter.h"

@interface IFConfiguredFilter (Private)
- (void)startObservingEnvironmentKeys:(NSSet*)keys;
- (void)stopObservingEnvironmentKeys:(NSSet*)keys;
- (void)updateExpression;
- (void)setExpression:(IFExpression*)newExpression;
@end

@implementation IFConfiguredFilter

+ (IFConfiguredFilter*)ghostFilter;
{
  return [[[self alloc] initWithFilter:[IFFilter filterForName:@"nop"] environment:[IFEnvironment environment]] autorelease];
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
  [filterEnvironment addObserver:self forKeyPath:@"keys" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
  
  return self;
}

- (void)dealloc;
{
  [filterEnvironment removeObserver:self forKeyPath:@"keys"];
  [self stopObservingEnvironmentKeys:[filterEnvironment keys]];
  
  [filterEnvironment release];
  filterEnvironment = nil;
  [filter release];
  filter = nil;
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

- (BOOL)acceptsParents:(int)parentsCount;
{
  return [filter acceptsParents:parentsCount];
}

- (BOOL)acceptsChildren:(int)childsCount;
{
  return [filter acceptsChildren:childsCount];
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
    [filterEnvironment addObserver:self forKeyPath:key options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
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
  if ([keyPath isEqualToString:@"keys"]) {
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
  } else {
    [self updateExpression]; // TODO only if key is part of expression
  }
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
