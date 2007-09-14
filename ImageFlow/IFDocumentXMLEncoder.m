//
//  IFDocumentXMLEncoder.m
//  ImageFlow
//
//  Created by Michel Schinz on 28.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFDocumentXMLEncoder.h"

#import "IFTreeNodeAlias.h"

@interface IFDocumentXMLEncoder (Private)
- (NSXMLElement*)treeToXML:(IFTreeNode*)root identities:(NSDictionary*)identities;
- (NSXMLElement*)filterToXML:(IFFilter*)filter;
- (NSXMLElement*)environmentToXML:(IFEnvironment*)environment;
@end

@implementation IFDocumentXMLEncoder

+ (id)encoder;
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

- (NSXMLDocument*)documentToXML:(IFDocument*)document identities:(NSDictionary*)identities;
{
  // XML tree
  NSXMLElement* xmlRoot = [NSXMLElement elementWithName:@"imageflow"];
  [xmlRoot setChildren:[NSArray arrayWithObjects:
    [NSXMLElement elementWithName:@"title" stringValue:[document title]],    
    [NSXMLElement elementWithName:@"author" stringValue:[document authorName]],
    [NSXMLElement elementWithName:@"description" stringValue:[document documentDescription]],
    [NSXMLElement elementWithName:@"resolutionX" stringValue:[xmlCoder encodeFloat:[document resolutionX]]],
    [NSXMLElement elementWithName:@"resolutionY" stringValue:[xmlCoder encodeFloat:[document resolutionY]]],
    nil]];
  NSArray* xmlRoots = (NSArray*)[[self collect] treeToXML:[[document roots] each] identities:identities];
  [[xmlRoot do] addChild:[xmlRoots each]];
  NSXMLDocument* xmlDoc = [NSXMLDocument documentWithRootElement:xmlRoot];
  [xmlDoc setVersion:@"1.0"];
  return xmlDoc;
}

@end

@implementation IFDocumentXMLEncoder (Private)

- (NSXMLElement*)treeToXML:(IFTreeNode*)root identities:(NSDictionary*)identities;
{
  NSXMLElement* xml;
  if ([root isAlias]) {
    xml = [NSXMLElement elementWithName:@"alias"];
    NSNumber* originalIdentity = [identities objectForKey:[NSValue valueWithPointer:[(IFTreeNodeAlias*)root original]]];
    NSAssert(originalIdentity != nil, @"no identity for node");
    [xml addAttribute:[NSXMLNode attributeWithName:@"idref" stringValue:[originalIdentity stringValue]]];
  } else {
    xml = [NSXMLElement elementWithName:@"tree"];
    [xml addChild:[self filterToXML:[root filter]]];
    NSAssert([root parents] != nil, @"nil parents");
    NSArray* xmlParents = (NSArray*)[[self collect] treeToXML:[[root parents] each] identities:identities];
    [[xml do] addChild:[xmlParents each]];
  }

  NSNumber* identity = [identities objectForKey:[NSValue valueWithPointer:root]];
  NSAssert1(identity != nil, @"no identity for node %@", root);
  [xml addAttribute:[NSXMLNode attributeWithName:@"id" stringValue:[identity stringValue]]]; 
  return xml;
}

- (NSXMLElement*)filterToXML:(IFFilter*)filter;
{
  NSXMLElement* xml = [NSXMLElement elementWithName:@"filter"];
  [xml addChild:[NSXMLElement elementWithName:@"name" stringValue:[[filter filter] name]]];
  [xml addChild:[self environmentToXML:[filter environment]]];
  return xml;
}

- (NSXMLElement*)environmentToXML:(IFEnvironment*)environment;
{
  NSXMLElement* xml = [NSXMLElement elementWithName:@"env"];
  NSDictionary* env = [environment asDictionary];
  NSEnumerator* keysEnum = [env keyEnumerator];
  NSString* key;
  while (key = [keysEnum nextObject]) {
    NSObject* value = [env objectForKey:key];
    if ([value isKindOfClass:[IFExpression class]])
      continue;
    [xml addChild:[NSXMLElement elementWithName:@"key" stringValue:key]];
    [xml addChild:[NSXMLElement elementWithName:[xmlCoder typeNameForData:value] stringValue:[xmlCoder encodeData:value]]];
  }
  return xml;
}

@end
