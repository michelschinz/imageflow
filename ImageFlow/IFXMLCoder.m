//
//  IFXMLCoder.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFXMLCoder.h"
#import "IFColorProfile.h"
#import "NSDataAdditions.h"
#import "IFExpression.h"
#import "IFEnvironment.h"
#import "IFTreeEdge.h"
#import "IFTreeNodeFilter.h"
#import "IFTreeNodeHole.h"
#import "IFTreeNodeAlias.h"
#import "IFObjectNumberer.h"

@interface IFXMLCoder (Private)
- (NSXMLElement*)encodeTreeNode:(IFTreeNode*)treeNode ofTree:(IFTree*)tree numberer:(IFObjectNumberer*)numberer;
- (NSXMLElement*)encodeFilterSettings:(IFEnvironment*)settings;

- (NSNumber*)xmlNodeIdentity:(NSXMLNode*)xml;
- (IFTreeNode*)decodeFilter:(NSXMLNode*)xml;
- (IFEnvironment*)decodeFilterSettings:(NSXMLNode*)xml;
@end

@implementation IFXMLCoder

static IFXMLCoder* sharedCoder = nil;

+ (IFXMLCoder*)sharedCoder;
{
  if (sharedCoder == nil)
    sharedCoder = [self new];
  return sharedCoder;
}

- (id)init;
{
  if (![super init])
    return nil;
  typeNames = [[NSArray arrayWithObjects:@"string",@"number",@"integer",@"point",@"rect",@"color",@"profile",@"expression",@"data",nil] retain];
  return self;
}

- (void) dealloc;
{
  OBJC_RELEASE(typeNames);
  [super dealloc];
}

- (IFXMLDataType)typeForData:(NSObject*)data;
{
  if ([data isKindOfClass:[NSString class]])
    return IFXMLDataTypeString;
  else if ([data isKindOfClass:[NSNumber class]]) {
    NSNumber* numberData = (NSNumber*)data;
    if (strcmp([numberData objCType], @encode(int)) == 0)
      return IFXMLDataTypeInteger;
    else if (strcmp([numberData objCType], @encode(float)) == 0)
      return IFXMLDataTypeNumber;
    else if (strcmp([numberData objCType], @encode(double)) == 0)
      return IFXMLDataTypeNumber;
    else {
      NSAssert1(NO, @"invalid type in NSNumber: %s", [numberData objCType]);
      return IFXMLDataTypeInvalid;
    }
  } else if ([data isKindOfClass:[NSValue class]]) {
    NSValue* valueData = (NSValue*)data;
    if (strcmp([valueData objCType], @encode(NSPoint)) == 0)
      return IFXMLDataTypePoint;
    else if (strcmp([valueData objCType], @encode(NSRect)) == 0)
      return IFXMLDataTypeRectangle;
    else {
      NSAssert1(false, @"invalid type in NSValue: %@",[valueData objCType]);  
      return IFXMLDataTypeInvalid;
    }
  } else if ([data isKindOfClass:[NSColor class]])
    return IFXMLDataTypeColor;
  else if ([data isKindOfClass:[IFColorProfile class]])
    return IFXMLDataTypeProfile;
  else if ([data isKindOfClass:[IFExpression class]])
    return IFXMLDataTypeExpression;
  else if ([data isKindOfClass:[NSData class]])
    return IFXMLDataTypeData;
  else {
    NSAssert2(NO, @"invalid data: %@ (class %@)",data,[data class]);  
    return IFXMLDataTypeInvalid;
  }
}

- (NSString*)typeNameForData:(NSObject*)data;
{
  return [typeNames objectAtIndex:[self typeForData:data]];
}

#pragma mark High-level encoding

- (NSXMLDocument*)encodeDocument:(IFDocument*)document;
{
  NSXMLElement* xmlDocumentRoot = [NSXMLElement elementWithName:@"document"];
  [xmlDocumentRoot setChildren:[NSArray arrayWithObjects:
    [NSXMLElement elementWithName:@"title" stringValue:[document title]],    
    [NSXMLElement elementWithName:@"author" stringValue:[document authorName]],
    [NSXMLElement elementWithName:@"description" stringValue:[document documentDescription]],
    [NSXMLElement elementWithName:@"resolution-x" stringValue:[self encodeFloat:[document resolutionX]]],
    [NSXMLElement elementWithName:@"resolution-y" stringValue:[self encodeFloat:[document resolutionY]]],
    [NSXMLElement elementWithName:@"canvas-bounds" stringValue:NSStringFromRect([document canvasBounds])],
    [self encodeTree:[document tree]],
    nil]];
  
  NSXMLDocument* xmlDocument = [NSXMLDocument documentWithRootElement:xmlDocumentRoot];
  [xmlDocument setVersion:@"1.0"];
  return xmlDocument;
}

- (NSXMLDocument*)encodeTreeTemplate:(IFTreeTemplate*)treeTemplate;
{
  NSXMLElement* xmlDocumentRoot = [NSXMLElement elementWithName:@"tree-template"];
  [xmlDocumentRoot setChildren:[NSArray arrayWithObjects:
    [NSXMLElement elementWithName:@"name" stringValue:[treeTemplate name]],
    [NSXMLElement elementWithName:@"description" stringValue:[treeTemplate description]],
    [self encodeTree:[treeTemplate tree]],
    nil]];
  
  NSXMLDocument* xmlDocument = [NSXMLDocument documentWithRootElement:xmlDocumentRoot];
  [xmlDocument setVersion:@"1.0"];
  return xmlDocument;
}

- (NSXMLElement*)encodeTree:(IFTree*)tree;
{
  NSXMLElement* xmlTree = [NSXMLElement elementWithName:@"tree"];
  IFObjectNumberer* numberer = [IFObjectNumberer numberer];
  [xmlTree setChildren:[NSArray arrayWithObject:[self encodeTreeNode:[tree root] ofTree:tree numberer:numberer]]];
  return xmlTree;
}

#pragma mark Low-level encoding

- (NSString*)encodeData:(id)data;
{
  switch ([self typeForData:data]) {
    case IFXMLDataTypeString:
      return (NSString*)data;
    case IFXMLDataTypeNumber:
      return [NSString stringWithFormat:@"%lf",[data doubleValue]];
    case IFXMLDataTypeInteger:
      return [data description];
    case IFXMLDataTypePoint:
      return NSStringFromPoint([(NSValue*)data pointValue]);
    case IFXMLDataTypeRectangle:
      return NSStringFromRect([(NSValue*)data rectValue]);
    case IFXMLDataTypeColor: {
      NSColor* color = (NSColor*)data;
      // TODO color space???
      return [NSString stringWithFormat:@"%f %f %f %f",[color redComponent],[color greenComponent],[color blueComponent],[color alphaComponent]];
    }
    case IFXMLDataTypeProfile:
      return [[(IFColorProfile*)data asData] base64Encoding];
    case IFXMLDataTypeExpression:
      return [[(IFExpression*)data asXML] XMLStringWithOptions:NSXMLNodeCompactEmptyElement];
    case IFXMLDataTypeData:
      return [(NSData*)data base64Encoding];
    default:
      NSAssert(NO, @"unexpected type");
      return nil;
  }
}

- (NSString*)encodeFloat:(float)data;
{
  return [self encodeData:[NSNumber numberWithFloat:data]];
}

- (NSString*)encodeInt:(int)data;
{
  return [self encodeData:[NSNumber numberWithInt:data]];
}

- (NSString*)encodeUnsignedInt:(unsigned int)data;
{
  return [self encodeData:[NSNumber numberWithInt:data]];
}

#pragma mark -
#pragma mark High-level decoding

- (void)decodeDocument:(NSXMLDocument*)xmlDocument into:(IFDocument*)document;
{
  NSXMLElement* xmlRoot = [xmlDocument rootElement];
  NSAssert([[xmlRoot name] isEqualToString:@"document"], @"invalid xml document");
  
  for (int i = 0; i < [xmlRoot childCount]; ++i) {
    NSXMLNode* child = [xmlRoot childAtIndex:i];
    NSString* childName = [child name];
    
    if ([childName isEqualToString:@"title"])
      [document setTitle:[child stringValue]];
    else if ([childName isEqualToString:@"author"])
      [document setAuthorName:[child stringValue]];
    else if ([childName isEqualToString:@"description"])
      [document setDocumentDescription:[child stringValue]];
    else if ([childName isEqualToString:@"resolution-x"])
      [document setResolutionX:[[self decodeString:[child stringValue] type:IFXMLDataTypeNumber] floatValue]];
    else if ([childName isEqualToString:@"resolution-y"])
      [document setResolutionY:[[self decodeString:[child stringValue] type:IFXMLDataTypeNumber] floatValue]];
    else if ([childName isEqualToString:@"canvas-bounds"])
      [document setCanvasBounds:NSRectFromString([child stringValue])];
    else if ([childName isEqualToString:@"tree"])
      [document setTree:[self decodeTree:child]];
    else
      NSAssert(NO, @"invalid node %@");
  }  
}

- (IFTreeTemplate*)decodeTreeTemplate:(NSXMLDocument*)xmlDocument;
{
  NSXMLNode* xml = [xmlDocument rootElement];
  NSAssert([[xml name] isEqualToString:@"tree-template"], @"invalid XML document");

  NSString* name = nil;
  NSString* description = nil;
  IFTree* tree = nil;
  NSString* tag = nil;
  
  for (int i = 0; i < [xml childCount]; ++i) {
    NSXMLNode* child = [xml childAtIndex:i];
    NSString* childName = [child name];
    
    if ([childName isEqualToString:@"name"])
      name = [child stringValue];
    else if ([childName isEqualToString:@"description"])
      description = [child stringValue];
    else if ([childName isEqualToString:@"tree"])
      tree = [self decodeTree:child];
    else if ([childName isEqualToString:@"tag"])
      tag = [child stringValue];
    else
      NSAssert1(NO, @"invalid node: %@", child);
  }

  IFTreeTemplate* treeTemplate = [IFTreeTemplate templateWithName:name description:description tree:tree];
  if (tag != nil)
    [treeTemplate setTag:tag];
  return treeTemplate;
}

- (IFTree*)decodeTree:(NSXMLNode*)xml;
{
  NSAssert([[xml name] isEqualToString:@"tree"], @"invalid XML document");
  NSAssert([xml childCount] == 1, @"invalid XML document");
  
  NSError* error; // TODO check and handle errors
  IFTree* tree = [IFTree tree];
  NSMutableDictionary* nodeMap = [NSMutableDictionary dictionary];
  
  // First pass, create non-alias nodes
  NSArray* nonAliasNodes = [xml nodesForXPath:@"//filter|//hole" error:&error];
  for (int i = 0; i < [nonAliasNodes count]; ++i) {
    NSXMLNode* xmlNode = [nonAliasNodes objectAtIndex:i];
    IFTreeNode* node = [[xmlNode name] isEqualToString:@"filter"]
      ? [self decodeFilter:xmlNode]
      : [IFTreeNodeHole hole] ;
    
    [tree addNode:node];
    [nodeMap setObject:node forKey:[self xmlNodeIdentity:xmlNode]];
  }
  
  // Second pass, create alias nodes
  NSArray* aliasNodes = [xml nodesForXPath:@"//alias" error:&error];
  for (int i = 0; i < [aliasNodes count]; ++i) {
    NSXMLNode* xmlNode = [aliasNodes objectAtIndex:i];
    unsigned originalId = [self decodeUnsignedInt:[[(NSXMLElement*)xmlNode attributeForName:@"original-ref"] stringValue]];
    IFTreeNode* alias = [IFTreeNodeAlias nodeAliasWithOriginal:[nodeMap objectForKey:[NSNumber numberWithUnsignedInt:originalId]]]; // TODO decode and set name, if any
    
    [tree addNode:alias];
    [nodeMap setObject:alias forKey:[self xmlNodeIdentity:xmlNode]];
  }
  
  // Third pass, create edges
  NSArray* nodesWithParents = [xml nodesForXPath:@"//filter[parents]" error:&error];
  for (int i = 0; i < [nodesWithParents count]; ++i) {
    NSXMLNode* xmlNode = [nodesWithParents objectAtIndex:i];
    IFTreeNode* child = [nodeMap objectForKey:[self xmlNodeIdentity:xmlNode]];
    NSArray* xmlParents = [xmlNode nodesForXPath:@"./parents/*" error:&error];
    for (int j = 0; j < [xmlParents count]; ++j) {
      IFTreeNode* parent = [nodeMap objectForKey:[self xmlNodeIdentity:[xmlParents objectAtIndex:j]]];
      [tree addEdgeFromNode:parent toNode:child withIndex:j];
    }
  }
  return tree;
}

#pragma mark Low-level decoding

- (id)decodeString:(NSString*)string type:(IFXMLDataType)type;
{
  switch (type) {
    case IFXMLDataTypeString:
      return string;
    case IFXMLDataTypeInteger:
      return [NSNumber numberWithInt:(int)strtod([string UTF8String], NULL)];
    case IFXMLDataTypeNumber:
      return [NSNumber numberWithDouble:strtod([string UTF8String], NULL)];
    case IFXMLDataTypePoint:
      return [NSValue valueWithPoint:NSPointFromString(string)];
    case IFXMLDataTypeRectangle:
      return [NSValue valueWithRect:NSRectFromString(string)];
    case IFXMLDataTypeColor: {
      NSArray* componentStrs = [string componentsSeparatedByString:@" "];
      // TODO color space???
      return [NSColor colorWithCalibratedRed:strtof([[componentStrs objectAtIndex:0] UTF8String], NULL)
                                       green:strtof([[componentStrs objectAtIndex:1] UTF8String], NULL)
                                        blue:strtof([[componentStrs objectAtIndex:2] UTF8String], NULL)
                                       alpha:strtof([[componentStrs objectAtIndex:3] UTF8String], NULL)];
    }
    case IFXMLDataTypeExpression: {
      NSError* outError = nil; // TODO handle errors
      NSXMLElement* xmlElement = [[[NSXMLElement alloc] initWithXMLString:string error:&outError] autorelease];
      return [IFExpression expressionWithXML:xmlElement];
    }
    case IFXMLDataTypeData:
      return [NSData dataWithBase64EncodedString:string];
    default:
      NSAssert1(NO, @"invalid type name %d", type);
      return nil;
  }
}

- (id)decodeString:(NSString*)string typeName:(NSString*)typeName;
{
  return [self decodeString:string type:[typeNames indexOfObject:typeName]];
}

- (float)decodeFloat:(NSString*)string;
{
  return [[self decodeString:string type:IFXMLDataTypeNumber] floatValue];
}

- (int)decodeInt:(NSString*)string;
{
  return [[self decodeString:string type:IFXMLDataTypeNumber] intValue];
}

- (unsigned int)decodeUnsignedInt:(NSString*)string;
{
  return [[self decodeString:string type:IFXMLDataTypeNumber] unsignedIntValue];
}

@end

@implementation IFXMLCoder (Private)

#pragma mark encoding

- (NSXMLElement*)encodeTreeNode:(IFTreeNode*)treeNode ofTree:(IFTree*)tree numberer:(IFObjectNumberer*)numberer;
{
  NSXMLElement* xmlTreeNode;
  if ([treeNode isAlias]) {
    xmlTreeNode = [NSXMLElement elementWithName:@"alias"];
    [xmlTreeNode addAttribute:[NSXMLNode attributeWithName:@"original-ref" stringValue:[self encodeUnsignedInt:[numberer uniqueNumberForObject:[treeNode original]]]]];
  } else if ([treeNode isHole]) {
    xmlTreeNode = [NSXMLElement elementWithName:@"hole"];
  } else {
    NSXMLElement* xmlParents = [NSXMLElement elementWithName:@"parents"];
    NSArray* parents = [tree parentsOfNode:treeNode];
    for (int i = 0; i < [parents count]; ++i)
      [xmlParents addChild:[self encodeTreeNode:[parents objectAtIndex:i] ofTree:tree numberer:numberer]];
    
    xmlTreeNode = [NSXMLElement elementWithName:@"filter"];
    [xmlTreeNode setChildren:[NSArray arrayWithObjects:
      [NSXMLElement elementWithName:@"name" stringValue:NSStringFromClass([treeNode class])],
      [self encodeFilterSettings:[treeNode settings]],
      xmlParents,
      nil]];
  }
  [xmlTreeNode addAttribute:[NSXMLNode attributeWithName:@"id" stringValue:[self encodeUnsignedInt:[numberer uniqueNumberForObject:treeNode]]]];
  return xmlTreeNode;
}

- (NSXMLElement*)encodeFilterSettings:(IFEnvironment*)settings;
{
  NSXMLElement* xmlSettings = [NSXMLElement elementWithName:@"settings"];
  NSDictionary* env = [settings asDictionary];
  NSEnumerator* keysEnum = [env keyEnumerator];
  NSString* key;
  while (key = [keysEnum nextObject]) {
    NSObject* value = [env objectForKey:key];
//    if ([value isKindOfClass:[IFExpression class]])
//      continue;
    [xmlSettings addChild:[NSXMLElement elementWithName:@"key" stringValue:key]];
    [xmlSettings addChild:[NSXMLElement elementWithName:[self typeNameForData:value] stringValue:[self encodeData:value]]];
  }
  return xmlSettings;
}

#pragma mark decoding

- (NSNumber*)xmlNodeIdentity:(NSXMLNode*)xml;
{
  NSAssert([xml isKindOfClass:[NSXMLElement class]], @"invalid XML element");
  NSString* identityString = [[(NSXMLElement*)xml attributeForName:@"id"] stringValue];
  return (identityString != nil) ? [NSNumber numberWithUnsignedInt:[self decodeUnsignedInt:identityString]] : nil;
}

- (IFTreeNode*)decodeFilter:(NSXMLNode*)xml;
{
  NSString* filterName = nil;
  IFEnvironment* filterSettings = [IFEnvironment environment];

  for (int i = 0; i < [xml childCount]; ++i) {
    NSXMLNode* child = [xml childAtIndex:i];
    NSString* childName = [child name];
    if ([childName isEqualToString:@"name"])
      filterName = [child stringValue];
    else if ([childName isEqualToString:@"settings"])
      filterSettings = [self decodeFilterSettings:child];
    else if ([childName isEqualToString:@"parents"])
      continue;
    else
      NSAssert1(NO, @"invalid node: %@", child);
  }

  return [IFTreeNodeFilter nodeWithFilterNamed:filterName settings:filterSettings];
}

- (IFEnvironment*)decodeFilterSettings:(NSXMLNode*)xml;
{
  IFEnvironment* env = [IFEnvironment environment];
  for (int i = 0; i < [xml childCount]; i += 2) {
    NSXMLNode* keyNode = [xml childAtIndex:i];
    NSXMLNode* valueNode = [xml childAtIndex:i+1];
    [env setValue:[self decodeString:[valueNode stringValue] typeName:[valueNode name]] forKey:[keyNode stringValue]];
  }
  return env;
}

@end

