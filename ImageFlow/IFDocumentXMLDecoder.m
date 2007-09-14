//
//  IFDocumentXMLDecoder.m
//  ImageFlow
//
//  Created by Michel Schinz on 28.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFDocumentXMLDecoder.h"

#import "IFTreeNode.h"
#import "IFTreeNodeAlias.h"

@interface IFDocumentXMLDecoder (Private)
- (int)xmlNodeIdentity:(NSXMLElement*)xml;
- (void)collectXMLFragmentsIn:(NSXMLElement*)xml accumulator:(NSMutableArray*)accumulator;
- (IFTreeNode*)treeFromXML:(NSXMLElement*)xml nodeMap:(NSDictionary*)nodeMap;
- (IFFilter*)filterFromXML:(NSXMLElement*)xml;
- (IFEnvironment*)environmentFromXML:(NSXMLElement*)xml;
@end

@implementation IFDocumentXMLDecoder

+ (id)decoder;
{
  return [[[self alloc] init] autorelease];
}

- (id)init;
{
  if (![super init])
    return nil;
  xmlCoder = [IFXMLCoder sharedCoder];
  return self;
}

- (IFDocument*)documentFromXML:(NSXMLDocument*)xml;
{
  IFDocument* document = [[IFDocument new] autorelease];
  NSXMLElement* xmlRoot = [xml rootElement];

  // First phase: collect all XML fragments.
  NSMutableArray* documentRootsIds = [NSMutableArray array];
  NSMutableArray* xmlFragments = [NSMutableArray array];
  for (int i = 0; i < [xmlRoot childCount]; ++i) {
    NSXMLNode* child = [xmlRoot childAtIndex:i];
    NSString* childName = [child name];

    if ([childName isEqualToString:@"title"])
      [document setTitle:[child stringValue]];
    else if ([childName isEqualToString:@"author"])
      [document setAuthorName:[child stringValue]];
    else if ([childName isEqualToString:@"description"])
      [document setDocumentDescription:[child stringValue]];
    else if ([childName isEqualToString:@"resolutionX"] || [childName isEqualToString:@"resolutionY"])
      [document setValue:[xmlCoder decodeString:[child stringValue] type:IFXMLDataTypeNumber] forKey:childName];
    else if ([childName isEqualToString:@"tree"] || [childName isEqualToString:@"alias"]) {
      [self collectXMLFragmentsIn:(NSXMLElement*)child accumulator:xmlFragments];
      [documentRootsIds addObject:[NSNumber numberWithInt:[self xmlNodeIdentity:(NSXMLElement*)child]]];
    } else
      NSAssert(NO, @"invalid node %@");
  }

  // Second phase: create tree using topologically-sorted fragments.
  NSMutableDictionary* nodeMap = [NSMutableDictionary dictionary];
  while ([xmlFragments count] > 0) {
    NSXMLElement* xml = [xmlFragments objectAtIndex:0];
    [xmlFragments removeObjectAtIndex:0];
    IFTreeNode* maybeNode = [self treeFromXML:xml nodeMap:nodeMap];
    if (maybeNode != nil)
      [nodeMap setObject:maybeNode forKey:[NSNumber numberWithInt:[self xmlNodeIdentity:xml]]];
    else
      [xmlFragments addObject:xml];
  }

  // Third phase: add created roots to document.
  for (int i = 0; i < [documentRootsIds count]; ++i)
    [document addTree:[nodeMap objectForKey:[documentRootsIds objectAtIndex:i]]];
    
  return document;
}

@end

@implementation IFDocumentXMLDecoder (Private)

- (int)xmlNodeIdentity:(NSXMLElement*)xml;
{
  NSString* identityString = [[xml attributeForName:@"id"] stringValue];
  return (identityString != nil) ? [xmlCoder decodeInt:identityString] : -1;
}

- (void)collectXMLFragmentsIn:(NSXMLElement*)xml accumulator:(NSMutableArray*)accumulator;
{
  [[self do] collectXMLFragmentsIn:[[xml elementsForName:@"tree"] each] accumulator:accumulator];
  [[self do] collectXMLFragmentsIn:[[xml elementsForName:@"alias"] each] accumulator:accumulator];
  [accumulator addObject:xml];
}

- (IFTreeNode*)treeFromXML:(NSXMLElement*)xml nodeMap:(NSDictionary*)nodeMap;
{
  if ([[xml name] isEqualToString:@"tree"]) {
    NSMutableArray* parents = [NSMutableArray array];
    for (int i = 1; i < [xml childCount]; ++i) {
      IFTreeNode* parent = [nodeMap objectForKey:[NSNumber numberWithInt:[self xmlNodeIdentity:(NSXMLElement*)[xml childAtIndex:i]]]];
      if (parent == nil)
        return nil;
      [parents addObject:parent];
    }
    IFFilter* filter = [self filterFromXML:(NSXMLElement*)[xml childAtIndex:0]];
    IFTreeNode* tree = [IFTreeNode nodeWithFilter:filter];
    for (int i = 0; i < [parents count]; ++i)
      [tree insertObject:[parents objectAtIndex:i] inParentsAtIndex:i];
    return tree;
  } else if ([[xml name] isEqualToString:@"alias"]) {
    NSNumber* originalIdentity = [xmlCoder decodeString:[[xml attributeForName:@"idref"] stringValue] type:IFXMLDataTypeNumber];
    IFTreeNode* original = [nodeMap objectForKey:originalIdentity];
    return (original != nil) ? [IFTreeNodeAlias nodeAliasWithOriginal:original] : nil;
  } else {
    NSAssert1(NO, @"invalide node %@",xml);
    return nil;
  }
}

- (IFFilter*)filterFromXML:(NSXMLElement*)xml;
{
  IFEnvironment* filterEnv = ([xml childCount] > 1)
    ? [self environmentFromXML:(NSXMLElement*)[xml childAtIndex:1]]
    : [IFEnvironment environment];
  return [IFFilter filterWithName:[[xml childAtIndex:0] stringValue] environment:filterEnv];
}

- (IFEnvironment*)environmentFromXML:(NSXMLElement*)xml;
{
  IFEnvironment* env = [IFEnvironment environment];
  for (int i = 0; i < [xml childCount] / 2; ++i) {
    NSXMLNode* keyNode = [xml childAtIndex:2*i];
    NSXMLNode* valueNode = [xml childAtIndex:(2*i)+1];
    [env setValue:[xmlCoder decodeString:[valueNode stringValue] typeName:[valueNode name]]
           forKey:[keyNode stringValue]];
  }
  return env;
}

@end

