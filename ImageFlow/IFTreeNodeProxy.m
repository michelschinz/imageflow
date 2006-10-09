//
//  IFTreeNodeProxy.m
//  ImageFlow
//
//  Created by Michel Schinz on 29.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFTreeNodeProxy.h"

@implementation IFTreeNodeProxy

+ (id)proxyForNode:(IFTreeNode*)theNode ofDocument:(IFDocument*)theDocument;
{
  return [[[self alloc] initForNode:theNode ofDocument:theDocument] autorelease];
}

- (id)initForNode:(IFTreeNode*)theNode ofDocument:(IFDocument*)theDocument;
{
  if (![super init])
    return nil;
  document = [theDocument retain];
  node = [theNode retain];
  return self;
}

- (void)dealloc;
{
  [node release];
  node = nil;
  [document release];
  document = nil;
  [super dealloc];
}

- (IFDocument*)document;
{
  return document;
}

- (IFTreeNode*)node;
{
  return node;
}

// NSCoding protocol

- (id)initWithCoder:(NSCoder*)decoder;
{
  self = [super initWithCoder:decoder];
  unsigned len;

  const void* ptr = [decoder decodeBytesWithReturnedLength:&len];
  NSAssert(len == sizeof(document), @"unexpected size on decoding");
  document = [*(IFDocument**)ptr retain];

  ptr = [decoder decodeBytesWithReturnedLength:&len];
  NSAssert(len == sizeof(node), @"unexpected size on decoding");
  node = [*(IFTreeNode**)ptr retain];

  return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder;
{
  [encoder encodeBytes:&document length:sizeof(document)];
  [encoder encodeBytes:&node length:sizeof(node)];
}

@end
