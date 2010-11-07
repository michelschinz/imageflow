//
//  IFXMLCoder.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFXMLCoder.h"
#import "NSDataAdditions.h"
#import "IFExpression.h"
#import "IFEnvironment.h"
#import "IFTreeEdge.h"
#import "IFTreeNodeFilter.h"
#import "IFTreeNodeHole.h"
#import "IFTreeNodeAlias.h"
#import "IFObjectNumberer.h"
#import "IFFileData.h"

@interface IFXMLCoder ()
- (NSXMLElement*)encodeTree:(IFTree*)tree;
- (NSXMLElement*)encodeTreeNode:(IFTreeNode*)treeNode ofTree:(IFTree*)tree numberer:(IFObjectNumberer*)numberer;
- (NSXMLElement*)encodeFilterSettings:(IFEnvironment*)settings;
- (void)encodePayloadOf:(IFTreeNode*)treeNode ofTree:(IFTree*)tree into:(NSMutableDictionary*)destination;

- (NSNumber*)xmlNodeIdentity:(NSXMLNode*)xml;
- (IFTree*)decodeTree:(NSXMLNode*)xml withPayload:(NSDictionary*)payload;
- (IFTreeNode*)decodeFilter:(NSXMLNode*)xml withPayload:(NSDictionary*)payload;
- (IFEnvironment*)decodeFilterSettings:(NSXMLNode*)xml withPayload:(NSDictionary*)payload;
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
  // Note: the type names below must correspond to the values of IFXMLDataType
  typeNames = [[NSArray arrayWithObjects:@"string",@"number",@"integer",@"point",@"rect",@"color",@"expression",@"data",@"file-data",@"url",nil] retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(typeNames);
  [super dealloc];
}

- (IFXMLDataType)typeForData:(NSObject*)data;
{
  if ([data isKindOfClass:[NSString class]])
    return IFXMLDataTypeString;
  else if ([data isKindOfClass:[NSNumber class]]) {
    const char* numberDataType = [(NSNumber*)data objCType];
    if (strcmp(numberDataType, @encode(char)) == 0 || strcmp(numberDataType, @encode(short)) == 0 || strcmp(numberDataType, @encode(int)) == 0)
      return IFXMLDataTypeInteger;
    else if (strcmp(numberDataType, @encode(float)) == 0 || strcmp(numberDataType, @encode(double)) == 0)
      return IFXMLDataTypeNumber;
    else {
      NSAssert1(NO, @"invalid type in NSNumber: %s", numberDataType);
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
  else if ([data isKindOfClass:[IFExpression class]])
    return IFXMLDataTypeExpression;
  else if ([data isKindOfClass:[NSData class]])
    return IFXMLDataTypeData;
  else if ([data isKindOfClass:[IFFileData class]])
    return IFXMLDataTypeFileData;
  else if ([data isKindOfClass:[NSURL class]])
    return IFXMLDataTypeURL;
  else {
    NSAssert2(NO, @"invalid data: %@ (class %@)",data,[data class]);
    return IFXMLDataTypeInvalid;
  }
}

- (NSString*)typeNameForData:(NSObject*)data;
{
  return [typeNames objectAtIndex:[self typeForData:data]];
}

// MARK: High-level encoding

- (NSDictionary*)encodeDocument:(IFDocument*)document;
{
  NSMutableDictionary* documentContents = [NSMutableDictionary dictionary];

  NSXMLDocument* xmlDocument = [NSXMLDocument documentWithRootElement:
                                [NSXMLElement elementWithName:@"document"
                                                     children:[NSArray arrayWithObjects:
                                                               [NSXMLElement elementWithName:@"title" stringValue:[self encodeString:document.title]],
                                                               [NSXMLElement elementWithName:@"author" stringValue:[self encodeString:document.authorName]],
                                                               [NSXMLElement elementWithName:@"description" stringValue:[self encodeString:document.documentDescription]],
                                                               [NSXMLElement elementWithName:@"resolution-x" stringValue:[self encodeFloat:document.resolutionX]],
                                                               [NSXMLElement elementWithName:@"resolution-y" stringValue:[self encodeFloat:document.resolutionY]],
                                                               [NSXMLElement elementWithName:@"canvas-bounds" stringValue:[self encodeRect:document.canvasBounds]],
                                                               [self encodeTree:document.tree],
                                                               nil]
                                                   attributes:nil]];
  [xmlDocument setVersion:@"1.0"];
  [documentContents setObject:[xmlDocument XMLDataWithOptions:NSXMLNodePrettyPrint] forKey:@"tree.xml"];

  [self encodePayloadOf:document.tree.root ofTree:document.tree into:documentContents];

  return documentContents;
}

- (NSDictionary*)encodeTreeTemplate:(IFTreeTemplate*)treeTemplate;
{
  NSMutableDictionary* documentContents = [NSMutableDictionary dictionary];

  NSXMLDocument* xmlDocument = [NSXMLDocument documentWithRootElement:
                                [NSXMLElement elementWithName:@"tree-template"
                                                     children:[NSArray arrayWithObjects:
                                                               [NSXMLElement elementWithName:@"name" stringValue:[treeTemplate name]],
                                                               [NSXMLElement elementWithName:@"description" stringValue:[treeTemplate description]],
                                                               [self encodeTree:[treeTemplate tree]],
                                                               nil]
                                                   attributes:nil]];
  [xmlDocument setVersion:@"1.0"];
  [documentContents setObject:[xmlDocument XMLDataWithOptions:NSXMLNodePrettyPrint] forKey:@"tree.xml"];

  [self encodePayloadOf:treeTemplate.tree.root ofTree:treeTemplate.tree into:documentContents];

  return documentContents;
}

// MARK: Low-level encoding

- (NSString*)encodeAny:(id)data;
{
  switch ([self typeForData:data]) {
    case IFXMLDataTypeString:
      return [self encodeString:data];
    case IFXMLDataTypeNumber:
      return [self encodeDouble:[data doubleValue]];
    case IFXMLDataTypeInteger:
      return [self encodeInt:[data intValue]];
    case IFXMLDataTypePoint:
      return [self encodePoint:[data pointValue]];
    case IFXMLDataTypeRectangle:
      return [self encodeRect:[data rectValue]];
    case IFXMLDataTypeColor:
      return [self encodeColor:data];
    case IFXMLDataTypeExpression:
      return [self encodeExpression:data];
    case IFXMLDataTypeData:
      return [self encodeData:data];
    case IFXMLDataTypeFileData:
      return [self encodeString:[data contentsBasedFileName]];
    case IFXMLDataTypeURL:
      return [self encodeURL:data];
    default:
      NSAssert(NO, @"unexpected type");
      return nil;
  }
}

- (NSString*)encodeInt:(int)data;
{
  return [NSString stringWithFormat:@"%d", data];
}

- (NSString*)encodeUnsignedInt:(unsigned int)data;
{
  return [NSString stringWithFormat:@"%u", data];
}

- (NSString*)encodeFloat:(float)data;
{
  return [NSString stringWithFormat:@"%f", data];
}

- (NSString*)encodeDouble:(double)data;
{
  return [NSString stringWithFormat:@"%lf", data];
}

- (NSString*)encodeString:(NSString*)data;
{
  // Note: escaping will be performed by NSXML classes later
  return data;
}

- (NSString*)encodePoint:(NSPoint)data;
{
  return [NSString stringWithFormat:@"%f %f", data.x, data.y];
}

- (NSString*)encodeRect:(NSRect)data;
{
  return [NSString stringWithFormat:@"%f %f %f %f", data.origin.x, data.origin.y, data.size.width, data.size.height];
}

- (NSString*)encodeColor:(NSColor*)data;
{
  // TODO: encode color space
  return [NSString stringWithFormat:@"%f %f %f %f", data.redComponent, data.greenComponent, data.blueComponent, data.alphaComponent];
}

- (NSString*)encodeExpression:(IFExpression*)data;
{
  return [[data asXML] XMLStringWithOptions:NSXMLNodeCompactEmptyElement];
}

- (NSString*)encodeData:(NSData*)data;
{
  return [data base64Encoding];
}

- (NSString*)encodeURL:(NSURL*)data;
{
  return [data absoluteString];
}

// MARK: High-level decoding

- (void)decodeDocument:(NSDictionary*)documentContents into:(IFDocument*)document;
{
  // read all payload data
  NSMutableDictionary* payload = [NSMutableDictionary dictionary];
  for (NSString* fileName in documentContents) {
    if ([fileName isEqualToString:@"tree.xml"])
      continue;
    [payload setObject:[IFFileData fileDataWithData:[documentContents objectForKey:fileName]] forKey:fileName];
  }

  // read main XML document
  NSXMLDocument* xmlDocument = [[[NSXMLDocument alloc] initWithData:[documentContents objectForKey:@"tree.xml"] options:NSXMLDocumentTidyXML error:nil] autorelease]; // TODO: error handling
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
      [document setResolutionX:[self decodeFloat:[child stringValue]]];
    else if ([childName isEqualToString:@"resolution-y"])
      [document setResolutionY:[self decodeFloat:[child stringValue]]];
    else if ([childName isEqualToString:@"canvas-bounds"])
      [document setCanvasBounds:NSRectFromString([child stringValue])];
    else if ([childName isEqualToString:@"tree"])
      [document setTree:[self decodeTree:child withPayload:payload]];
    else
      NSAssert(NO, @"invalid node %@");
  }
}

- (IFTreeTemplate*)decodeTreeTemplate:(NSDictionary*)documentContents;
{
  // read all payload data
  NSMutableDictionary* payload = [NSMutableDictionary dictionary];
  for (NSString* fileName in documentContents) {
    if ([fileName isEqualToString:@"tree.xml"])
      continue;
    [payload setObject:[IFFileData fileDataWithData:[documentContents objectForKey:fileName]] forKey:fileName];
  }

  // read main XML document
  NSXMLDocument* xmlDocument = [[[NSXMLDocument alloc] initWithData:[documentContents objectForKey:@"tree.xml"] options:NSXMLDocumentTidyXML error:nil] autorelease]; // TODO: error handling
  NSXMLNode* xmlRoot = [xmlDocument rootElement];
  NSAssert([[xmlRoot name] isEqualToString:@"tree-template"], @"invalid XML document");

  NSString* name = nil;
  NSString* description = nil;
  IFTree* tree = nil;
  NSString* tag = nil;

  for (int i = 0; i < [xmlRoot childCount]; ++i) {
    NSXMLNode* child = [xmlRoot childAtIndex:i];
    NSString* childName = [child name];

    if ([childName isEqualToString:@"name"])
      name = [child stringValue];
    else if ([childName isEqualToString:@"description"])
      description = [child stringValue];
    else if ([childName isEqualToString:@"tree"])
      tree = [self decodeTree:child withPayload:payload];
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

// MARK: Low-level decoding

- (id)decodeAny:(NSString*)string type:(IFXMLDataType)type;
{
  switch (type) {
    case IFXMLDataTypeString:
      return [self decodeString:string];
    case IFXMLDataTypeInteger:
      return [NSNumber numberWithInt:[self decodeInt:string]];
    case IFXMLDataTypeNumber:
      return [NSNumber numberWithDouble:[self decodeDouble:string]];
    case IFXMLDataTypePoint:
      return [NSValue valueWithPoint:[self decodePoint:string]];
    case IFXMLDataTypeRectangle:
      return [NSValue valueWithRect:[self decodeRect:string]];
    case IFXMLDataTypeColor:
      return [self decodeColor:string];
    case IFXMLDataTypeExpression:
      return [self decodeExpression:string];
    case IFXMLDataTypeData:
      return [self decodeData:string];
    case IFXMLDataTypeURL:
      return [self decodeURL:string];
    default:
      NSAssert1(NO, @"invalid type name %d", type);
      return nil;
  }
}

- (int)decodeInt:(NSString*)string;
{
  return (int)strtol([string UTF8String], NULL, 10);
}

- (unsigned)decodeUnsignedInt:(NSString*)string;
{
  return (unsigned)strtol([string UTF8String], NULL, 10);
}

- (float)decodeFloat:(NSString*)string;
{
  return strtof([string UTF8String], NULL);
}

- (double)decodeDouble:(NSString*)string;
{
  return strtod([string UTF8String], NULL);
}

- (NSString*)decodeString:(NSString*)string;
{
  return string;
}

- (NSPoint)decodePoint:(NSString*)string;
{
  NSArray* components = [string componentsSeparatedByString:@" "];
  return NSMakePoint(strtof([[components objectAtIndex:0] UTF8String], NULL),
                     strtof([[components objectAtIndex:1] UTF8String], NULL));
}

- (NSRect)decodeRect:(NSString*)string;
{
  NSArray* components = [string componentsSeparatedByString:@" "];
  return NSMakeRect(strtof([[components objectAtIndex:0] UTF8String], NULL),
                    strtof([[components objectAtIndex:1] UTF8String], NULL),
                    strtof([[components objectAtIndex:2] UTF8String], NULL),
                    strtof([[components objectAtIndex:3] UTF8String], NULL));
}

- (NSColor*)decodeColor:(NSString*)string;
{
  NSArray* components = [string componentsSeparatedByString:@" "];
  return [NSColor colorWithCalibratedRed:strtof([[components objectAtIndex:0] UTF8String], NULL)
                                   green:strtof([[components objectAtIndex:1] UTF8String], NULL)
                                    blue:strtof([[components objectAtIndex:2] UTF8String], NULL)
                                   alpha:strtof([[components objectAtIndex:3] UTF8String], NULL)];
}

- (IFExpression*)decodeExpression:(NSString*)string;
{
  NSError* outError = nil; // TODO: handle errors
  return [IFExpression expressionWithXML:[[[NSXMLElement alloc] initWithXMLString:string error:&outError] autorelease]];
}

- (NSData*)decodeData:(NSString*)string;
{
  return [NSData dataWithBase64EncodedString:string];
}

- (NSURL*)decodeURL:(NSString*)string;
{
  return [NSURL URLWithString:string];
}

// MARK: -
// MARK: PRIVATE

- (NSXMLElement*)encodeTree:(IFTree*)tree;
{
  NSXMLElement* xmlTree = [NSXMLElement elementWithName:@"tree"];
  IFObjectNumberer* numberer = [IFObjectNumberer numberer];
  [xmlTree setChildren:[NSArray arrayWithObject:[self encodeTreeNode:[tree root] ofTree:tree numberer:numberer]]];
  return xmlTree;
}

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
  for (NSString* key in env) {
    NSObject* value = [env objectForKey:key];
    [xmlSettings addChild:[NSXMLElement elementWithName:@"key" stringValue:key]];
    [xmlSettings addChild:[NSXMLElement elementWithName:[self typeNameForData:value] stringValue:[self encodeAny:value]]];
  }
  return xmlSettings;
}

- (void)encodePayloadOf:(IFTreeNode*)treeNode ofTree:(IFTree*)tree into:(NSMutableDictionary*)destination;
{
  if (treeNode.isAlias)
    return;

  NSDictionary* env = [treeNode.settings asDictionary];
  for (NSString* key in env) {
    id value = [env objectForKey:key];
    if ([value isKindOfClass:[IFFileData class]]) {
      IFFileData* fileData = value;
      [destination setObject:fileData.fileData forKey:fileData.contentsBasedFileName];
    }
  }
  for (IFTreeNode* parent in [tree parentsOfNode:treeNode])
    [self encodePayloadOf:parent ofTree:tree into:destination];
}

- (NSNumber*)xmlNodeIdentity:(NSXMLNode*)xml;
{
  NSAssert([xml isKindOfClass:[NSXMLElement class]], @"invalid XML element");
  NSString* identityString = [[(NSXMLElement*)xml attributeForName:@"id"] stringValue];
  return (identityString != nil) ? [NSNumber numberWithUnsignedInt:[self decodeUnsignedInt:identityString]] : nil;
}

- (IFTree*)decodeTree:(NSXMLNode*)xml withPayload:(NSDictionary*)payload;
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
    ? [self decodeFilter:xmlNode withPayload:payload]
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

- (IFTreeNode*)decodeFilter:(NSXMLNode*)xml withPayload:(NSDictionary*)payload;
{
  NSString* filterName = nil;
  IFEnvironment* filterSettings = [IFEnvironment environment];

  for (int i = 0; i < [xml childCount]; ++i) {
    NSXMLNode* child = [xml childAtIndex:i];
    NSString* childName = [child name];
    if ([childName isEqualToString:@"name"])
      filterName = [child stringValue];
    else if ([childName isEqualToString:@"settings"])
      filterSettings = [self decodeFilterSettings:child withPayload:payload];
    else if ([childName isEqualToString:@"parents"])
      continue;
    else
      NSAssert1(NO, @"invalid node: %@", child);
  }

  return [IFTreeNodeFilter nodeWithFilterNamed:filterName settings:filterSettings];
}

- (IFEnvironment*)decodeFilterSettings:(NSXMLNode*)xml withPayload:(NSDictionary*)payload;
{
  IFEnvironment* env = [IFEnvironment environment];
  for (int i = 0; i < [xml childCount]; i += 2) {
    NSString* key = [[xml childAtIndex:i] stringValue];
    NSString* value = [[xml childAtIndex:i+1] stringValue];
    IFXMLDataType type = [typeNames indexOfObject:[[xml childAtIndex:i+1] name]];
    if (type == IFXMLDataTypeFileData)
      [env setValue:[payload objectForKey:value] forKey:key];
    else
      [env setValue:[self decodeAny:value type:type] forKey:key];
  }
  return env;
}

@end

