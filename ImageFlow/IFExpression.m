//
//  IFExpression.m
//  ImageFlow
//
//  Created by Michel Schinz on 18.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFExpression.h"
#import "IFParentExpression.h"
#import "IFOperatorExpression.h"
#import "IFVariableExpression.h"
#import "IFConstantExpression.h"
#import "IFExpressionVisitor.h"

#import <caml/memory.h>

@implementation IFExpression

- (id)copyWithZone:(NSZone*)zone;
{
  return [self retain];
}

- (void)dealloc;
{
  if (camlRepresentationIsValid) {
    caml_remove_global_root(&camlRepresentation);
    camlRepresentation = 0;
    camlRepresentationIsValid = NO;
  }
  [super dealloc];
}

- (void)accept:(IFExpressionVisitor*)visitor;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (NSUInteger)hash;
{
  [self doesNotRecognizeSelector:_cmd];
  return 0;
}

- (BOOL)isEqualAtRoot:(id)other;
{
  [self doesNotRecognizeSelector:_cmd];
  return NO;
}

- (BOOL)isEqual:(id)other;
{
  return [self isEqualAtRoot:other];
}

+ (id)expressionWithXML:(NSXMLElement*)xmlTree;
{
  NSString* xmlName = [xmlTree name];
  if ([xmlName isEqualToString:@"operation"])
    return [[[IFOperatorExpression alloc] initWithXML:xmlTree] autorelease];
  else if ([xmlName isEqualToString:@"parent"])
    return [[[IFParentExpression alloc] initWithXML:xmlTree] autorelease];
  else if ([xmlName isEqualToString:@"variable"])
    return [[[IFVariableExpression alloc] initWithXML:xmlTree] autorelease];
  else if ([xmlName isEqualToString:@"constant"])
    return [[[IFConstantExpression alloc] initWithXML:xmlTree] autorelease];
  else {
    NSAssert1(false, @"unknown XML element: %@",xmlName); // TODO handle errors
    return nil;
  }
}

// MARK: XML input/output

- (id)initWithXML:(NSXMLElement*)xml;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (NSXMLElement*)asXML;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

// MARK: Caml representation

- (value)asCaml;
{
  if (!camlRepresentationIsValid) {
    caml_register_global_root(&camlRepresentation);
    camlRepresentation = [self camlRepresentation];
    camlRepresentationIsValid = YES;
  }
  return camlRepresentation;
}

- (value)camlRepresentation;
{
  [self doesNotRecognizeSelector:_cmd];
  return Val_unit;
}

@end
