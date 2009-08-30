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
  return [self expressionWithOperatorNamed:@"nop" operands:nil];
}

+ (id)extentOf:(IFExpression*)imageExpr;
{
  return [self expressionWithOperatorNamed:@"extent" operands:imageExpr,nil];
}

+ (id)resample:(IFExpression*)imageExpr by:(float)scale;
{
  return [self expressionWithOperatorNamed:@"resample" operands:imageExpr,[IFConstantExpression expressionWithFloat:scale],nil];
}

+ (id)translate:(IFExpression*)expression byX:(float)x Y:(float)y;
{
  return [self expressionWithOperatorNamed:@"translate" operands:expression,[IFConstantExpression expressionWithPointNS:NSMakePoint(x,y)],nil];
}

+ (id)crop:(IFExpression*)expression along:(NSRect)rectangle;
{
  return [self expressionWithOperatorNamed:@"crop" operands:expression,[IFConstantExpression expressionWithRectNS:rectangle],nil];
}

+ (id)blendBackground:(IFExpression*)background withForeground:(IFExpression*)foreground inMode:(IFConstantExpression*)mode;
{
  return [self expressionWithOperatorNamed:@"blend" operands:background,foreground,mode,nil];
}

+ (id)histogramOf:(IFExpression*)imageExpr;
{
  return [self expressionWithOperatorNamed:@"histogram-rgb" operands:imageExpr,nil];
}

+ (id)checkerboardCenteredAt:(NSPoint)center color0:(NSColor*)color0 color1:(NSColor*)color1 width:(float)width sharpness:(float)sharpness;
{
  return [self expressionWithOperatorNamed:@"checkerboard" operands:[IFConstantExpression expressionWithPointNS:center], [IFConstantExpression expressionWithColorNS:color0], [IFConstantExpression expressionWithColorNS:color1], [IFConstantExpression expressionWithFloat:width], [IFConstantExpression expressionWithFloat:sharpness], nil];
}

+ (id)maskToImage:(IFExpression*)maskExpression;
{
  return [self expressionWithOperatorNamed:@"mask-to-image" operands:maskExpression, nil];
}

+ (id)arrayGet:(IFExpression*)arrayExpression index:(unsigned)index;
{
  return [self expressionWithOperatorNamed:@"array-get" operands:arrayExpression, [IFConstantExpression expressionWithInt:index], nil];
}

+ (id)expressionWithOperator:(IFOperator*)theOperator operands:(NSArray*)theOperands;
{
  return [[[self alloc] initWithOperator:theOperator operands:theOperands] autorelease];
}

+ (id)expressionWithOperatorNamed:(NSString*)theOperatorName operands:(IFExpression*)firstOperand, ...;
{
  NSMutableArray* operandsArray = [NSMutableArray array];
  if (firstOperand != nil) {
    va_list argList;
    IFExpression* nextOperand;
    [operandsArray addObject:firstOperand];
    va_start(argList, firstOperand);
    while ((nextOperand = va_arg(argList, IFExpression*)) != nil)
      [operandsArray addObject:nextOperand];
    va_end(argList);
  }
  return [self expressionWithOperator:[IFOperator operatorForName:theOperatorName] operands:operandsArray];
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
  OBJC_RELEASE(operands);
  OBJC_RELEASE(operator);
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

#pragma mark NSCoding protocol

- (id)initWithCoder:(NSCoder*)decoder;
{
  return [self initWithOperator:[decoder decodeObjectForKey:@"operator"] operands:[decoder decodeObjectForKey:@"operands"]];
}

- (void)encodeWithCoder:(NSCoder*)encoder;
{
  [encoder encodeObject:operator forKey:@"operator"];
  [encoder encodeObject:operands forKey:@"operands"];
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
