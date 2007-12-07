//
//  IFXMLCoder.h
//  ImageFlow
//
//  Created by Michel Schinz on 12.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFDocument.h"
#import "IFTreeTemplate.h"
#import "IFTree.h"
#import "IFTreeNode.h"
#import "IFEnvironment.h"

typedef enum {
  IFXMLDataTypeInvalid = -1,
  IFXMLDataTypeString,
  IFXMLDataTypeNumber,
  IFXMLDataTypeInteger,
  IFXMLDataTypePoint,
  IFXMLDataTypeRectangle,
  IFXMLDataTypeColor,
  IFXMLDataTypeProfile,
  IFXMLDataTypeExpression,
  IFXMLDataTypeData
} IFXMLDataType;

@interface IFXMLCoder : NSObject {
  NSArray* typeNames;
}

+ (IFXMLCoder*)sharedCoder;

- (IFXMLDataType)typeForData:(NSObject*)data;
- (NSString*)typeNameForData:(NSObject*)data;

#pragma mark High-level encoding

- (NSXMLDocument*)encodeDocument:(IFDocument*)document;
- (NSXMLDocument*)encodeTreeTemplate:(IFTreeTemplate*)treeTemplate;
- (NSXMLElement*)encodeTree:(IFTree*)tree;

#pragma mark Low-level encoding

- (NSString*)encodeData:(id)data;
- (NSString*)encodeFloat:(float)data;
- (NSString*)encodeInt:(int)data;
- (NSString*)encodeUnsignedInt:(unsigned int)data;

#pragma mark -
#pragma mark High-level decoding

- (void)decodeDocument:(NSXMLDocument*)xmlDocument into:(IFDocument*)document;
- (IFTreeTemplate*)decodeTreeTemplate:(NSXMLDocument*)xml;
- (IFTree*)decodeTree:(NSXMLNode*)xml;

#pragma mark Low-level decoding

- (id)decodeString:(NSString*)string type:(IFXMLDataType)type;
- (id)decodeString:(NSString*)string typeName:(NSString*)typeName;
- (float)decodeFloat:(NSString*)string;
- (int)decodeInt:(NSString*)string;
- (unsigned int)decodeUnsignedInt:(NSString*)string;

@end
