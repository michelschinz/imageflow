//
//  IFVariableExpression.m
//  ImageFlow
//
//  Created by Michel Schinz on 19.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFVariableExpression.h"
#import "IFConstantExpression.h"
#import "IFExpressionVisitor.h"
#import "IFExpressionTags.h"

#import <caml/memory.h>
#import <caml/alloc.h>

@implementation IFVariableExpression

- (id)initWithName:(NSString*)theName;
{
  if (![super init])
    return nil;
  name = [theName copy];
  return self;
}

- (void) dealloc {
  OBJC_RELEASE(name);
  [super dealloc];
}

- (NSString*)description;
{
  return [@"_" stringByAppendingString:name];
}

@synthesize name;

- (void)accept:(IFExpressionVisitor*)visitor;
{
  [visitor caseVariableExpression:self];
}

- (NSUInteger)hash;
{
  return [name hash] * 3;
}

- (BOOL)isEqualAtRoot:(id)other;
{
  return [other isKindOfClass:[IFVariableExpression class]] && [name isEqualToString:[other name]];
}

// MARK: XML input/output

- (id)initWithXML:(NSXMLElement*)xmlTree;
{
  return [self initWithName:[[xmlTree attributeForName:@"name"] stringValue]];
}

- (NSXMLElement*)asXML;
{
  NSXMLElement* elem = [NSXMLElement elementWithName:@"variable"];
  [elem addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:name]];
  return elem;
}

// MARK: NSCoding protocol

- (id)initWithCoder:(NSCoder*)decoder;
{
  return [self initWithName:[decoder decodeObjectForKey:@"name"]];
}

- (void)encodeWithCoder:(NSCoder*)encoder;
{
  [encoder encodeObject:name forKey:@"name"];
}

// MARK: Caml representation

- (value)camlRepresentation;
{
  CAMLparam0();
  CAMLlocal1(block);
  block = caml_alloc(1, IFExpressionTag_Var);
  Store_field(block, 0, caml_copy_string([[self name] cStringUsingEncoding:NSISOLatin1StringEncoding]));
  CAMLreturn(block);
}

@end
