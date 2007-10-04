//
//  IFTreeMark.m
//  ImageFlow
//
//  Created by Michel Schinz on 17.07.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFTreeMark.h"


@implementation IFTreeMark

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey {
  return (![theKey isEqualToString:@"node"]
          && [super automaticallyNotifiesObserversForKey:theKey]);
}

+ (id)mark;
{
  return [[[self alloc] init] autorelease];
}

- (void)dealloc;
{
  OBJC_RELEASE(node);
  [super dealloc];
}

- (BOOL)isSet;
{
  return ([self node] != nil);
}

- (IFTreeNode*)node;
{
  return node;
}

- (void)setNode:(IFTreeNode*)newNode;
{
  if (newNode == node) return;
  [self willChangeValueForKey:@"node"];
  [node release];
  node = [newNode retain];
  [self didChangeValueForKey:@"node"];
}

- (void)setNode:(IFTreeNode*)newNode ifCurrentNodeIs:(IFTreeNode*)maybeCurrentNode;
{
  if (node == maybeCurrentNode)
    [self setNode:newNode];
}

- (void)setLikeMark:(IFTreeMark*)otherMark;
{
  [self setNode:[otherMark node]];
}

- (void)unset;
{
  [self setNode:nil];
}

@end
