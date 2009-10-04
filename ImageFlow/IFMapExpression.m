//
//  IFMapExpression.m
//  ImageFlow
//
//  Created by Michel Schinz on 26.09.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import "IFMapExpression.h"

#import <caml/memory.h>
#import <caml/alloc.h>

@implementation IFMapExpression

- (id)initWithFunction:(IFExpression*)theFunction array:(IFExpression*)theArray;
{
  if (![super init])
    return nil;
  function = [theFunction retain];
  array = [theArray retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(array);
  OBJC_RELEASE(function);
  [super dealloc];
}

@synthesize function, array;

- (BOOL)isEqual:(id)other;
{
  return [other isKindOfClass:[IFMapExpression class]] && [self.function isEqual:((IFMapExpression*)other).function] && [self.array isEqual:((IFMapExpression*)other).array];
}

- (NSUInteger)hash;
{
  return [function hash] ^ [array hash];
}

- (NSString*)description;
{
  return [NSString stringWithFormat:@"map(%@,%@)", function, array];
}

// MARK: XML input/output

- (id)initWithXML:(NSXMLElement*)xmlTree;
{
  return [self initWithFunction:[IFExpression expressionWithXML:(NSXMLElement*)[xmlTree childAtIndex:0]] array:[IFExpression expressionWithXML:(NSXMLElement*)[xmlTree childAtIndex:1]]];
}

- (NSXMLElement*)asXML;
{
  NSXMLElement* root = [NSXMLElement elementWithName:@"map"];
  [root addChild:[function asXML]];
  [root addChild:[array asXML]];
  return root;
}

// MARK: NSCoding protocol

- (id)initWithCoder:(NSCoder*)decoder;
{
  return [self initWithFunction:[decoder decodeObjectForKey:@"function"] array:[decoder decodeObjectForKey:@"array"]];
}

- (void)encodeWithCoder:(NSCoder*)encoder;
{
  [encoder encodeObject:function forKey:@"function"];
  [encoder encodeObject:array forKey:@"array"];
}

// MARK: Caml representation

- (value)camlRepresentation;
{
  CAMLparam0();
  CAMLlocal1(block);
  block = caml_alloc(2, IFExpressionTag_Map);
  Store_field(block, 0, [function asCaml]);
  Store_field(block, 1, [array asCaml]);
  CAMLreturn(block);
}

@end
