//
//  IFOperatorExpression.m
//  ImageFlow
//
//  Created by Michel Schinz on 19.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFOperatorExpression.h"
#import "IFExpressionVisitor.h"
#import "IFExpressionTags.h"

#import "IFFNVHash.h"

#import <caml/memory.h>
#import <caml/alloc.h>

@implementation IFOperatorExpression

+ (id)nop;
{
  return [self expressionWithOperator:[IFOperator operatorForName:@"nop"] operands:[NSArray array]];
}

+ (id)extentOf:(IFExpression*)imageExpr;
{
  return [self expressionWithOperator:[IFOperator operatorForName:@"extent"] operands:[NSArray arrayWithObject:imageExpr]];
}

+ (id)resample:(IFExpression*)imageExpr by:(float)scale;
{
  return [self expressionWithOperator:[IFOperator operatorForName:@"resample"]
                             operands:[NSArray arrayWithObjects:
                               imageExpr,
                               [IFConstantExpression expressionWithFloat:scale],
                               nil]];
}

+ (id)translate:(IFExpression*)expression byX:(float)x Y:(float)y;
{
  static IFOperator* op = nil;
  if (op == nil) op = [IFOperator operatorForName:@"translate"];
  return [self expressionWithOperator:op operands:[NSArray arrayWithObjects:
    expression,
    [IFConstantExpression expressionWithPointNS:NSMakePoint(x,y)],
    nil]];
}

+ (id)crop:(IFExpression*)expression along:(NSRect)rectangle;
{
  return [self expressionWithOperator:[IFOperator operatorForName:@"crop"]
                             operands:[NSArray arrayWithObjects:
                               expression,
                               [IFConstantExpression expressionWithRectNS:rectangle],
                               nil]];
}

+ (id)blendBackground:(IFExpression*)background withForeground:(IFExpression*)foreground inMode:(IFConstantExpression*)mode;
{
  return [self expressionWithOperator:[IFOperator operatorForName:@"blend"]
                             operands:[NSArray arrayWithObjects:
                               background,
                               foreground,
                               mode,
                               nil]];
}

+ (id)histogramOf:(IFExpression*)imageExpr;
{
  return [self expressionWithOperator:[IFOperator operatorForName:@"histogram-rgb"] operands:[NSArray arrayWithObject:imageExpr]];
}

+ (id)expressionWithOperator:(IFOperator*)theOperator operands:(NSArray*)theOperands;
{
  return [[[self alloc] initWithOperator:theOperator operands:theOperands] autorelease];
}

- (id)initWithOperator:(IFOperator*)theOperator operands:(NSArray*)theOperands;
{
  if (![super init])
    return nil;
  operator = [theOperator retain];
  operands = [theOperands retain];

  hash = FNV_step32(FNV_init(), [operator hash]);
  for (int i = 0; i < [operands count]; ++i)
    hash = FNV_step32(hash,[[operands objectAtIndex:i] hash]);

  return self;
}

- (void) dealloc {
  [operands release];
  operands = nil;
  [operator release];
  operator = nil;
  [super dealloc];
}

- (NSString*)description;
{
  NSMutableString* desc = [NSMutableString stringWithString:[operator name]];
  [desc appendString:@"("];
  [desc appendString:[operands componentsJoinedByString:@","]];
  [desc appendString:@")"];
  return desc;
}

- (IFOperator*)operator;
{
  return operator;
}

- (NSArray*)operands;
{
  return operands;
}

- (IFExpression*)operandAtIndex:(int)index;
{
  return [operands objectAtIndex:index];
}

- (void)accept:(IFExpressionVisitor*)visitor;
{
  [visitor caseOperatorExpression:self];
}

- (unsigned)hash;
{
  return hash;
}

- (BOOL)isEqualAtRoot:(id)other;
{
  return [other isKindOfClass:[IFOperatorExpression class]] && ([other operator] == operator);
}

- (BOOL)isEqual:(id)other;
{
  if ([self isEqualAtRoot:other]) {
    for (int i = [operands count] - 1; i >= 0; --i) {
      if (![[operands objectAtIndex:i] isEqual:[[other operands] objectAtIndex:i]])
        return NO;
    }
    return YES;
  } else
    return NO;
}

#pragma mark XML input/output

- (id)initWithXML:(NSXMLElement*)xmlTree;
{
  NSString* operatorName = [[xmlTree attributeForName:@"name"] stringValue];
  return [self initWithOperator:[IFOperator operatorForName:operatorName]
                       operands:([xmlTree childCount] == 0 ? [NSArray array] : [[IFExpression collect] expressionWithXML:[[xmlTree children] each]])];
}

- (NSXMLElement*)asXML;
{
  NSXMLElement* root = [NSXMLElement elementWithName:@"operation"];
  [root addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:[operator name]]];
  [[root do] addChild:[[[operands collect] asXML] each]];
  return root;
}

#pragma mark Caml representation

static value operandAsCaml(const char* operand) {
  return [(IFExpression*)operand asCaml];
}

- (value)camlRepresentation;
{
  CAMLparam0();
  CAMLlocal1(block);
  block = caml_alloc(2, IFExpressionTag_Op);
  Store_field(block, 0, caml_copy_string([[operator name] cStringUsingEncoding:NSISOLatin1StringEncoding]));
  int operandsCount = [operands count];
  IFExpression** operandsArray = malloc(sizeof(IFExpression*) * (operandsCount + 1));
  [operands getObjects:operandsArray];
  operandsArray[operandsCount] = NULL;
  Store_field(block, 1, caml_alloc_array(operandAsCaml, (char const**)operandsArray));
  free(operandsArray);
  CAMLreturn(block);
}

@end
