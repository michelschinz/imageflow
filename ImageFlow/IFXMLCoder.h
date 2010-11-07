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
  IFXMLDataTypeExpression,
  IFXMLDataTypeData,
  IFXMLDataTypeFileData,
  IFXMLDataTypeURL,
} IFXMLDataType;

@interface IFXMLCoder : NSObject {
  NSArray* typeNames;
}

+ (IFXMLCoder*)sharedCoder;

- (IFXMLDataType)typeForData:(NSObject*)data;
- (NSString*)typeNameForData:(NSObject*)data;

// MARK: High-level encoding

- (NSDictionary*)encodeDocument:(IFDocument*)document;
- (NSDictionary*)encodeTreeTemplate:(IFTreeTemplate*)treeTemplate;

// MARK: Low-level encoding

- (NSString*)encodeAny:(id)data;
- (NSString*)encodeInt:(int)data;
- (NSString*)encodeUnsignedInt:(unsigned int)data;
- (NSString*)encodeFloat:(float)data;
- (NSString*)encodeDouble:(double)data;
- (NSString*)encodeString:(NSString*)data;
- (NSString*)encodePoint:(NSPoint)data;
- (NSString*)encodeRect:(NSRect)data;
- (NSString*)encodeColor:(NSColor*)data;
- (NSString*)encodeExpression:(IFExpression*)data;
- (NSString*)encodeData:(NSData*)data;
- (NSString*)encodeURL:(NSURL*)url;

// MARK: High-level decoding

- (void)decodeDocument:(NSDictionary*)documentContents into:(IFDocument*)document;
- (IFTreeTemplate*)decodeTreeTemplate:(NSDictionary*)documentContents;

// MARK: Low-level decoding

- (id)decodeAny:(NSString*)string type:(IFXMLDataType)type;
- (int)decodeInt:(NSString*)string;
- (unsigned)decodeUnsignedInt:(NSString*)string;
- (float)decodeFloat:(NSString*)string;
- (double)decodeDouble:(NSString*)string;
- (NSString*)decodeString:(NSString*)string;
- (NSPoint)decodePoint:(NSString*)string;
- (NSRect)decodeRect:(NSString*)string;
- (NSColor*)decodeColor:(NSString*)string;
- (IFExpression*)decodeExpression:(NSString*)string;
- (NSData*)decodeData:(NSString*)string;
- (NSURL*)decodeURL:(NSString*)string;

@end
