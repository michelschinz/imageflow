//
//  IFArgumentExpression.m
//  ImageFlow
//
//  Created by Michel Schinz on 05.09.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import "IFArgumentExpression.h"

#import "IFXMLCoder.h"
#import "IFExpressionTags.h"

#import <caml/memory.h>
#import <caml/alloc.h>

@implementation IFArgumentExpression

- (IFArgumentExpression*)initWithIndex:(unsigned)theIndex;
{
  if (![super init])
    return nil;
  index = theIndex;
  return self;
}

- (NSString*)description;
{
  return [NSString stringWithFormat:@"#%d", index];
}

@synthesize index;

- (NSUInteger)hash;
{
  return index * 19;
}

- (BOOL)isEqual:(id)other;
{
  return [other isKindOfClass:[IFArgumentExpression class]] && (index == [(IFArgumentExpression*)other index]);
}

// MARK: XML input/output

- (id)initWithXML:(NSXMLElement*)xmlTree;
{
  IFXMLCoder* xmlCoder = [IFXMLCoder sharedCoder];
  return [self initWithIndex:[xmlCoder decodeInt:[[xmlTree attributeForName:@"index"] stringValue]]];
}

- (NSXMLElement*)asXML;
{
  IFXMLCoder* xmlCoder = [IFXMLCoder sharedCoder];
  NSXMLElement* elem = [NSXMLElement elementWithName:@"arg"];
  [elem addAttribute:[NSXMLNode attributeWithName:@"index" stringValue:[xmlCoder encodeInt:index]]];
  return elem;
}

// MARK: NSCoding protocol

- (id)initWithCoder:(NSCoder*)decoder;
{
  return [self initWithIndex:[decoder decodeIntForKey:@"index"]];
}

- (void)encodeWithCoder:(NSCoder*)encoder;
{
  [encoder encodeInt:index forKey:@"index"];
}

// MARK: Caml representation

- (value)camlRepresentation;
{
  CAMLparam0();
  CAMLlocal1(block);
  block = caml_alloc(1, IFExpressionTag_Arg);
  Store_field(block, 0, Val_int([self index]));
  CAMLreturn(block);
}

@end
