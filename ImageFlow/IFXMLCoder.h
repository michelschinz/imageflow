//
//  IFXMLCoder.h
//  ImageFlow
//
//  Created by Michel Schinz on 12.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeTemplate.h"
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
  NSNumberFormatter* numberFormatter;
}

+ (IFXMLCoder*)sharedCoder;

- (IFXMLDataType)typeForData:(NSObject*)data;
- (NSString*)typeNameForData:(NSObject*)data;

#pragma mark Low-level encoding

- (NSString*)encodeData:(NSObject*)data;
- (NSString*)encodeFloat:(float)data;
- (NSString*)encodeInt:(int)data;
- (NSString*)encodeUnsignedInt:(unsigned int)data;

#pragma mark -
#pragma mark High-level decoding

- (IFTreeTemplate*)decodeTreeTemplate:(NSXMLNode*)xml;
- (IFTreeNode*)decodeTree:(NSXMLNode*)xml;
- (IFTreeNode*)decodeTreeNode:(NSXMLNode*)xml;
- (IFEnvironment*)decodeFilterSettings:(NSXMLNode*)xml;

#pragma mark Low-level decoding

- (id)decodeString:(NSString*)string type:(IFXMLDataType)type;
- (id)decodeString:(NSString*)string typeName:(NSString*)typeName;
- (float)decodeFloat:(NSString*)string;
- (int)decodeInt:(NSString*)string;
- (unsigned int)decodeUnsignedInt:(NSString*)string;

@end
