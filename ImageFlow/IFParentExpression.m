//
//  IFParentExpression.m
//  ImageFlow
//
//  Created by Michel Schinz on 25.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFParentExpression.h"
#import "IFOperatorExpression.h"
#import "IFXMLCoder.h"
#import "IFExpressionVisitor.h"
#import "IFExpressionTags.h"

#import <caml/memory.h>
#import <caml/alloc.h>

@implementation IFParentExpression

+ (id)parentExpressionWithIndex:(int)index;
{
  return [[[self alloc] initWithIndex:index] autorelease];
}

- (id)initWithIndex:(int)theIndex;
{
  if (![super init])
    return nil;
  index = theIndex;
  return self;
}

- (NSString*)description;
{
  return [NSString stringWithFormat:@"@%d",index];
}

- (int)index;
{
  return index;
}

- (void)accept:(IFExpressionVisitor*)visitor;
{
  [visitor caseParentExpression:self];
}

- (unsigned)hash;
{
  return index * 1973;
}

- (BOOL)isEqualAtRoot:(id)other;
{
  return [other isKindOfClass:[IFParentExpression class]] && (index == [other index]);
}
  
#pragma mark XML input/output

- (id)initWithXML:(NSXMLElement*)xmlTree;
{
  IFXMLCoder* xmlCoder = [IFXMLCoder sharedCoder];
  return [self initWithIndex:[(NSNumber*)[xmlCoder decodeString:[[xmlTree attributeForName:@"index"] stringValue] type:IFXMLDataTypeNumber] intValue]];
}

- (NSXMLElement*)asXML;
{
  IFXMLCoder* xmlCoder = [IFXMLCoder sharedCoder];
  NSXMLElement* elem = [NSXMLElement elementWithName:@"parent"];
  [elem addAttribute:[NSXMLNode attributeWithName:@"index" stringValue:[xmlCoder encodeData:[NSNumber numberWithInt:index]]]];
  return elem;
}

#pragma mark Caml representation

- (value)camlRepresentation;
{
  CAMLparam0();
  CAMLlocal1(block);
  block = caml_alloc(1, IFExpressionTag_Parent);
  Store_field(block, 0, Val_int([self index]));
  CAMLreturn(block);
}

@end
