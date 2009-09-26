//
//  IFApplyExpression.m
//  ImageFlow
//
//  Created by Michel Schinz on 26.09.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import "IFApplyExpression.h"
#import "IFExpressionVisitor.h"

#import <caml/memory.h>
#import <caml/alloc.h>

@implementation IFApplyExpression

- (id)initWithFunction:(IFExpression*)theFunction argument:(IFExpression*)theArgument;
{
  if (![super init])
    return nil;
  function = [theFunction retain];
  argument = [theArgument retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(argument);
  OBJC_RELEASE(function);
  [super dealloc];
}

@synthesize function, argument;

- (void)accept:(IFExpressionVisitor*)visitor;
{
  [visitor caseApplyExpression:self];
}

- (BOOL)isEqual:(id)other;
{
  return [other isKindOfClass:[IFApplyExpression class]] && [self.function isEqual:((IFApplyExpression*)other).function] && [self.argument isEqual:((IFApplyExpression*)other).argument];
}

- (NSUInteger)hash;
{
  return [function hash] ^ [argument hash];
}

- (NSString*)description;
{
  return [NSString stringWithFormat:@"%@(%@)", function, argument];
}

// MARK: XML input/output

- (id)initWithXML:(NSXMLElement*)xmlTree;
{
  return [self initWithFunction:[IFExpression expressionWithXML:(NSXMLElement*)[xmlTree childAtIndex:0]] argument:[IFExpression expressionWithXML:(NSXMLElement*)[xmlTree childAtIndex:1]]];
}

- (NSXMLElement*)asXML;
{
  NSXMLElement* root = [NSXMLElement elementWithName:@"apply"];
  [root addChild:[function asXML]];
  [root addChild:[argument asXML]];
  return root;
}

// MARK: NSCoding protocol

- (id)initWithCoder:(NSCoder*)decoder;
{
  return [self initWithFunction:[decoder decodeObjectForKey:@"function"] argument:[decoder decodeObjectForKey:@"argument"]];
}

- (void)encodeWithCoder:(NSCoder*)encoder;
{
  [encoder encodeObject:function forKey:@"function"];
  [encoder encodeObject:argument forKey:@"argument"];
}

// MARK: Caml representation

- (value)camlRepresentation;
{
  CAMLparam0();
  CAMLlocal1(block);
  block = caml_alloc(2, IFExpressionTag_Apply);
  Store_field(block, 0, [function asCaml]);
  Store_field(block, 1, [argument asCaml]);
  CAMLreturn(block);
}

@end
