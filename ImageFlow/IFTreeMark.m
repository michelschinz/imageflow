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

+ (id)markWithTag:(NSString*)theTag;
{
  return [self markWithTag:theTag node:nil];
}

+ (id)markWithTag:(NSString*)theTag node:(IFTreeNode*)theNode;
{
  return [[[self alloc] initWithTag:theTag node:theNode] autorelease];
}

- (id)initWithTag:(NSString*)theTag node:(IFTreeNode*)theNode;
{
  if (![super init]) return nil;
  tag = [theTag copy];
  node = [theNode retain];
  return self;
}

- (void)dealloc;
{
  [tag release];
  tag = nil;
  [node release];
  node = nil;
  [super dealloc];
}

- (BOOL)isSet;
{
  return ([self node] != nil);
}

- (NSString*)tag;
{
  return tag;
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
