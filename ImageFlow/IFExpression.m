//
//  IFExpression.m
//  ImageFlow
//
//  Created by Michel Schinz on 18.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFExpression.h"
#import "IFLambdaExpression.h"
#import "IFMapExpression.h"
#import "IFApplyExpression.h"
#import "IFConstantExpression.h"
#import "IFPrimitiveExpression.h"
#import "IFArgumentExpression.h"

#import <caml/memory.h>

@implementation IFExpression

+ (IFExpression*)fail;
{
  return [self primitiveWithTag:IFPrimitiveTag_Fail operands:nil];
}

+ (IFExpression*)extentOf:(IFExpression*)imageExpr;
{
  return [self primitiveWithTag:IFPrimitiveTag_Extent operands:imageExpr,nil];
}

+ (IFExpression*)resample:(IFExpression*)imageExpr by:(float)scale;
{
  return [self primitiveWithTag:IFPrimitiveTag_Resample operands:imageExpr,[IFConstantExpression expressionWithFloat:scale],nil];
}

+ (IFExpression*)translate:(IFExpression*)expression byX:(float)x Y:(float)y;
{
  return [self primitiveWithTag:IFPrimitiveTag_Translate operands:expression,[IFConstantExpression expressionWithPointNS:NSMakePoint(x,y)],nil];
}

+ (IFExpression*)crop:(IFExpression*)expression along:(NSRect)rectangle;
{
  return [self primitiveWithTag:IFPrimitiveTag_Crop operands:expression,[IFConstantExpression expressionWithRectNS:rectangle],nil];
}

+ (IFExpression*)blendBackground:(IFExpression*)background withForeground:(IFExpression*)foreground inMode:(IFExpression*)mode;
{
  return [self primitiveWithTag:IFPrimitiveTag_Blend operands:background,foreground,mode,nil];
}

+ (IFExpression*)histogramOf:(IFExpression*)imageExpr;
{
  return [self primitiveWithTag:IFPrimitiveTag_HistogramRGB operands:imageExpr,nil];
}

+ (IFExpression*)checkerboardCenteredAt:(NSPoint)center color0:(NSColor*)color0 color1:(NSColor*)color1 width:(float)width sharpness:(float)sharpness;
{
  return [self primitiveWithTag:IFPrimitiveTag_Checkerboard operands:[IFConstantExpression expressionWithPointNS:center], [IFConstantExpression expressionWithColorNS:color0], [IFConstantExpression expressionWithColorNS:color1], [IFConstantExpression expressionWithFloat:width], [IFConstantExpression expressionWithFloat:sharpness], nil];
}

+ (IFExpression*)maskToImage:(IFExpression*)maskExpression;
{
  return [self primitiveWithTag:IFPrimitiveTag_MaskToImage operands:maskExpression, nil];
}

+ (IFExpression*)arrayGet:(IFExpression*)arrayExpression index:(unsigned)index;
{
  return [self primitiveWithTag:IFPrimitiveTag_ArrayGet operands:arrayExpression, [IFConstantExpression expressionWithInt:index], nil];
}

+ (IFExpression*)tupleCreate:(NSArray*)tupleElements;
{
  return [self primitiveWithTag:IFPrimitiveTag_PTupleCreate operandsArray:tupleElements];
}

+ (IFExpression*)tupleGet:(IFExpression*)tupleExpression index:(unsigned)index;
{
  return [self primitiveWithTag:IFPrimitiveTag_PTupleGet operands:tupleExpression, [IFConstantExpression expressionWithInt:index], nil];
}

+ (IFExpression*)primitiveWithTag:(IFPrimitiveTag)theTag operand:(IFExpression*)theOperand;
{
  return [self primitiveWithTag:theTag operands:theOperand, nil];
}

+ (IFExpression*)primitiveWithTag:(IFPrimitiveTag)theTag operands:(IFExpression*)firstOperand, ...;
{
  NSMutableArray* operands = [NSMutableArray array];
  if (firstOperand != nil) {
    va_list argList;
    IFExpression* nextOperand;
    [operands addObject:firstOperand];
    va_start(argList, firstOperand);
    while ((nextOperand = va_arg(argList, IFExpression*)) != nil)
      [operands addObject:nextOperand];
    va_end(argList);
  }
  return [self primitiveWithTag:theTag operandsArray:operands];
}

+ (IFExpression*)primitiveWithTag:(IFPrimitiveTag)theTag operandsArray:(NSArray*)theOperands;
{
  return [[[IFPrimitiveExpression alloc] initWithTag:theTag operands:theOperands] autorelease];
}

+ (IFExpression*)lambdaWithBody:(IFExpression*)theBody;
{
  return [[[IFLambdaExpression alloc] initWithBody:theBody] autorelease];
}

+ (IFExpression*)mapWithFunction:(IFExpression*)theFunction array:(IFExpression*)theArray;
{
  return [[[IFMapExpression alloc] initWithFunction:theFunction array:theArray] autorelease];
}

+ (IFExpression*)applyWithFunction:(IFExpression*)theFunction argument:(IFExpression*)theArgument;
{
  return [[[IFApplyExpression alloc] initWithFunction:theFunction argument:theArgument] autorelease];
}

+ (IFExpression*)argumentWithIndex:(unsigned)theIndex;
{
  return [[(IFArgumentExpression*)[IFArgumentExpression alloc] initWithIndex:theIndex] autorelease];
}

// TODO: why is this needed?
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

- (NSUInteger)hash;
{
  [self doesNotRecognizeSelector:_cmd];
  return 0;
}

+ (id)expressionWithXML:(NSXMLElement*)xmlTree;
{
  NSString* xmlName = [xmlTree name];
  if ([xmlName isEqualToString:@"primitive"])
    return [[[IFPrimitiveExpression alloc] initWithXML:xmlTree] autorelease];
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
