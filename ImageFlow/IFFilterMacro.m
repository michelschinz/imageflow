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

static int parametersCount(IFTreeNode* root) {
  if ([root isKindOfClass:[IFTreeNodeParameter class]])
    return 1;
  else {
    NSArray* parents = [root parents];
    int count = 0;
    for (int i = 0; i < [parents count]; ++i)
      count += parametersCount([parents objectAtIndex:i]);
    return count;
  }
}

+ (id)filterWithMacroRootReference:(IFTreeNodeReference*)theMacroRootRef;
{
  return [[[self alloc] initWithMacroRootReference:theMacroRootRef] autorelease];
}

- (id)initWithMacroRootReference:(IFTreeNodeReference*)theMacroRootRef;
{
  int parentsCount = parametersCount([theMacroRootRef treeNode]);
  if (![super initWithName:@"<macro>"
                expression:[[theMacroRootRef treeNode] expression]
              parentsArity:NSMakeRange(parentsCount,1)
                childArity:NSMakeRange(0, [[theMacroRootRef treeNode] acceptsChildren:1] ? 2 : 1)
           settingsNibName:nil
                  delegate:nil])
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

@end
