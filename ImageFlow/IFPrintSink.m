//
//  IFPrintSink.m
//  ImageFlow
//
//  Created by Michel Schinz on 18.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFPrintSink.h"
#import "IFPrintView.h"
#import "IFDocument.h"
#import "IFType.h"
#import "IFExpression.h"

@implementation IFPrintSink

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 1) 
    return [NSArray arrayWithObject:[IFType funTypeWithArgumentType:[IFType imageRGBAType] returnType:[IFType actionType]]];
  else
    return [NSArray array];
}

- (IFExpression*)potentialRawExpressionsForArity:(unsigned)arity typeIndex:(unsigned)typeIndex;
{
  NSAssert(arity == 1 && typeIndex == 0, @"invalid arity or type index");
  return [IFExpression lambdaWithBody:[IFExpression primitiveWithTag:IFPrimitiveTag_Print operands:nil]];
}

- (NSString*)exporterKind;
{
  return @"printer";
}

// TODO obsolete
- (void)exportImage:(IFImageConstantExpression*)imageExpr document:(IFDocument*)document;
{
  BOOL printToFile = [[settings valueForKey:@"printToFile"] boolValue];
  
  NSPrintInfo* sharedPrintInfo = [NSPrintInfo sharedPrintInfo];
  NSMutableDictionary* printInfoDict = [NSMutableDictionary dictionaryWithDictionary:[sharedPrintInfo dictionary]];
  if (printToFile) {
    [printInfoDict setObject:NSPrintSaveJob forKey:NSPrintJobDisposition];
    [printInfoDict setObject:[settings valueForKey:@"fileName"] forKey:NSPrintSavePath];
  } else
    [printInfoDict setObject:NSPrintSpoolJob forKey:NSPrintJobDisposition];

  NSSize paperSize = [sharedPrintInfo paperSize];
  NSRect printableRect = [sharedPrintInfo imageablePageBounds];
  
  float marginL = printableRect.origin.x;
  float marginR = paperSize.width - (printableRect.origin.x + printableRect.size.width);
  float marginB = printableRect.origin.y;
  float marginT = paperSize.height - (printableRect.origin.y + printableRect.size.height);

  CGAffineTransform scaling = CGAffineTransformMakeScale(72.0 / [document resolutionX], 72.0 / [document resolutionY]);
  CIImage* scaledImage = [[imageExpr imageValueCI] imageByApplyingTransform:scaling];
  IFPrintView* printView = [IFPrintView printViewWithFrame:NSRectFromCGRect([scaledImage extent]) image:scaledImage];
  
  NSPrintInfo* printInfo = [[[NSPrintInfo alloc] initWithDictionary:printInfoDict] autorelease];
  [printInfo setHorizontalPagination:NSAutoPagination];
  [printInfo setVerticalPagination:NSAutoPagination];
  [printInfo setBottomMargin:marginB];
  [printInfo setTopMargin:marginT];
  [printInfo setLeftMargin:marginL];
  [printInfo setRightMargin:marginR];
  NSPrintOperation* printOp = [NSPrintOperation printOperationWithView:printView printInfo:printInfo];
  [printOp setShowPanels:NO];
  [printOp runOperation];
}

- (NSString*)nameOfParentAtIndex:(int)index;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (NSString*)computeLabel;
{
  return [NSString stringWithFormat:@"print TODO"];
}

@end
