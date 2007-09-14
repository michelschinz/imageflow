//
//  IFFilterMacro.m
//  ImageFlow
//
//  Created by Michel Schinz on 20.01.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFFilterMacro.h"
#import "IFTreeNodeParameter.h"

@implementation IFFilterMacro

static NSString* IFRootExpressionChangedContext = @"IFRootExpressionChangedContext";

+ (id)filterWithMacroRootReference:(IFTreeNodeReference*)theMacroRootRef;
{
  return [[[self alloc] initWithMacroRootReference:theMacroRootRef] autorelease];
}

- (id)initWithMacroRootReference:(IFTreeNodeReference*)theMacroRootRef;
{
  if (![super initWithEnvironment:[IFEnvironment environment]])
    return nil;
  macroRootRef = [theMacroRootRef retain];
  [macroRootRef addObserver:self forKeyPath:@"treeNode.expression" options:0 context:IFRootExpressionChangedContext];
  return self;
}

- (void)dealloc;
{
  [macroRootRef removeObserver:self forKeyPath:@"treeNode.expression"];
  OBJC_RELEASE(macroRootRef);
  [super dealloc];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  NSAssert(context == IFRootExpressionChangedContext, @"invalid context");
  NSLog(@"TODO");
}

- (NSArray*)potentialRawExpressions;
{
  return [NSArray arrayWithObject:[[macroRootRef treeNode] expression]];
}

@end
