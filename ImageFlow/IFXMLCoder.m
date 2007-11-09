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

@interface IFXMLCoder (Private)
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
  numberFormatter = [NSNumberFormatter new];
  [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
  [numberFormatter setNumberStyle:NSNumberFormatterScientificStyle];
  return self;
}

- (void) dealloc;
{
  OBJC_RELEASE(numberFormatter);
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
    else {
      NSAssert1(NO, @"invalid type in NSNumber: %@", [numberData objCType]);
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

#pragma mark Low-level encoding

- (NSString*)encodeData:(NSObject*)data;
{
  switch ([self typeForData:data]) {
    case IFXMLDataTypeString:
      return (NSString*)data;
    case IFXMLDataTypeNumber:
      return [numberFormatter stringFromNumber:(NSNumber*)data];
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

- (IFTreeTemplate*)decodeTreeTemplate:(NSXMLNode*)xml;
{
  NSAssert([[xml name] isEqualToString:@"tree-template"], @"invalid XML document");
  NSString* name = nil;
  NSString* description = nil;
  IFTree* tree = nil;
  
  for (int i = 0; i < [xml childCount]; ++i) {
    NSXMLNode* child = [xml childAtIndex:i];
    NSString* childName = [child name];
    
    if ([childName isEqualToString:@"name"])
      name = [child stringValue];
    else if ([childName isEqualToString:@"description"])
      description = [child stringValue];
    else if ([childName isEqualToString:@"tree"])
      tree = [self decodeTree:child];
    else
      NSAssert1(NO, @"invalid node: %@", child);
  }
  
  return [IFTreeTemplate templateWithName:name description:description tree:tree];
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
      return [NSNumber numberWithInt:[[numberFormatter numberFromString:string] intValue]];
    case IFXMLDataTypeNumber:
      return [numberFormatter numberFromString:string];
    case IFXMLDataTypePoint:
      return [NSValue valueWithPoint:NSPointFromString(string)];
    case IFXMLDataTypeRectangle:
      return [NSValue valueWithRect:NSRectFromString(string)];
    case IFXMLDataTypeColor: {
      NSArray* components = (NSArray*)[[numberFormatter collect] numberFromString:[[string componentsSeparatedByString:@" "] each]];
      // TODO color space???
      return [NSColor colorWithCalibratedRed:[[components objectAtIndex:0] floatValue]
                                       green:[[components objectAtIndex:1] floatValue]
                                        blue:[[components objectAtIndex:2] floatValue]
                                       alpha:[[components objectAtIndex:3] floatValue]];
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

  return [IFTreeNodeFilter nodeWithFilter:[IFFilter filterWithName:filterName environment:filterSettings]];  
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

