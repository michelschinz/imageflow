//
//  IFPrimitiveExpression.m
//  ImageFlow
//
//  Created by Michel Schinz on 25.09.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import "IFPrimitiveExpression.h"
#import "IFFNVHash.h"

#import <caml/memory.h>
#import <caml/alloc.h>

static NSArray* tagNames;

@implementation IFPrimitiveExpression

+ (void)initialize;
{
  if (self != [IFPrimitiveExpression class])
    return; // avoid repeated initialisation

  tagNames = [[NSArray arrayWithObjects:
               @"apply",
               @"array-create",
               @"array-get",
               @"average",
               @"blend",
               @"channel-to-mask",
               @"checkerboard",
               @"circle",
               @"color-controls",
               @"constant-color",
               @"crop",
               @"crop-overlay",
               @"div",
               @"empty",
               @"export-action-create",
               @"extent",
               @"fail",
               @"file-extent",
               @"gaussian-blur",
               @"histogram-rgb",
               @"invert",
               @"invert-mask",
               @"load",
               @"map",
               @"mask",
               @"mask-overlay",
               @"mask-to-image",
               @"mul",
               @"opacity",
               @"paint",
               @"paint-extent",
               @"point-mul",
               @"rect-intersection",
               @"rect-mul",
               @"rect-outset",
               @"rect-scale",
               @"rect-translate",
               @"rect-union",
               @"rectangular-window",
               @"resample",
               @"single-color",
               @"threshold",
               @"threshold-mask",
               @"translate",
               @"tuple-create",
               @"tuple-get",               
               @"unsharp-mask",
               @"zip",
               nil] retain];
}

- (id)initWithTag:(IFPrimitiveTag)theTag operands:(NSArray*)theOperands;
{
  NSAssert(0 <= theTag && theTag < [tagNames count], @"invalid tag %d", theTag);

  if (![super init])
    return nil;
  primitiveTag = theTag;
  operands = [theOperands retain];

  hash = FNV_step32(FNV_init(), primitiveTag);
  for (IFExpression* operand in operands)
    hash = FNV_step32(hash, [operand hash]);

  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(operands);
  [super dealloc];
}

@synthesize primitiveTag, operands;

- (NSString*)name;
{
  return [tagNames objectAtIndex:primitiveTag];
}

- (int)tag;
{
  return IFExpressionTag_Prim;
}

- (BOOL)isEqual:(id)other;
{
  return ([other isKindOfClass:[IFPrimitiveExpression class]]
          && hash == [other hash]
          && primitiveTag == [(IFPrimitiveExpression*)other primitiveTag]
          && [operands isEqual:[other operands]]);
}

@synthesize hash;

- (NSString*)description;
{
  return [NSString stringWithFormat:@"%@[%@]", self.name, [operands componentsJoinedByString:@","]];
}

// MARK: XML input/output

- (id)initWithXML:(NSXMLElement*)xmlTree;
{
  NSString* primitiveName = [[xmlTree attributeForName:@"name"] stringValue];
  NSMutableArray* theOperands = [NSMutableArray array];
  for (NSXMLElement* child in xmlTree.children)
    [theOperands addObject:[IFExpression expressionWithXML:child]];
  return [self initWithTag:[tagNames indexOfObject:primitiveName] operands:theOperands];
}

- (NSXMLElement*)asXML;
{
  NSXMLElement* root = [NSXMLElement elementWithName:@"primitive"];
  [root addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:self.name]];
  for (IFExpression* operand in operands)
    [root addChild:[operand asXML]];
  return root;
}

// MARK: NSCoding protocol

- (id)initWithCoder:(NSCoder*)decoder;
{
  return [self initWithTag:[decoder decodeIntForKey:@"primitive"] operands:[decoder decodeObjectForKey:@"operands"]];
}

- (void)encodeWithCoder:(NSCoder*)encoder;
{
  [encoder encodeInt:primitiveTag forKey:@"primitive"];
  [encoder encodeObject:operands forKey:@"operands"];
}

// MARK: Caml representation

static value operandAsCaml(const char* operand) {
  return [(IFExpression*)operand asCaml];
}

- (value)camlRepresentation;
{
  CAMLparam0();
  CAMLlocal1(block);
  block = caml_alloc(2, IFExpressionTag_Prim);
  Store_field(block, 0, Val_int(primitiveTag));
  int operandsCount = [operands count];
  IFExpression** operandsArray = malloc(sizeof(IFExpression*) * (operandsCount + 1));
  [operands getObjects:operandsArray];
  operandsArray[operandsCount] = NULL;
  Store_field(block, 1, caml_alloc_array(operandAsCaml, (char const**)operandsArray));
  free(operandsArray);
  CAMLreturn(block);
}

@end
