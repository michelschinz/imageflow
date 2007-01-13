//
//  IFPrintSinkDelegate.m
//  ImageFlow
//
//  Created by Michel Schinz on 18.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFPrintSinkDelegate.h"
#import "IFPrintView.h"
#import "IFDocument.h"
#import "IFFunType.h"
#import "IFBasicType.h"
#import "IFImageType.h"

@implementation IFPrintSinkDelegate

- (NSArray*)potentialTypesWithEnvironment:(IFEnvironment*)env;
{
  static NSArray* types = nil;
  if (types == nil) {
    types = [[NSArray arrayWithObject:
      [IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObject:[IFImageType imageRGBAType]]
                               returnType:[IFBasicType actionType]]] retain];
  }
  return types;
}

- (NSString*)exporterKind;
{
  return @"printer";
}

- (void)exportImage:(IFImageConstantExpression*)imageExpr environment:(IFEnvironment*)environment document:(IFDocument*)document;
{
  BOOL printToFile = [[environment valueForKey:@"printToFile"] boolValue];
  
  NSPrintInfo* sharedPrintInfo = [NSPrintInfo sharedPrintInfo];
  NSMutableDictionary* printInfoDict = [NSMutableDictionary dictionaryWithDictionary:[sharedPrintInfo dictionary]];
  if (printToFile) {
    [printInfoDict setObject:NSPrintSaveJob forKey:NSPrintJobDisposition];
    [printInfoDict setObject:[environment valueForKey:@"fileName"] forKey:NSPrintSavePath];
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

- (NSString*)labelWithEnvironment:(IFEnvironment*)env;
{
  return [NSString stringWithFormat:@"print TODO"];
}

@end
