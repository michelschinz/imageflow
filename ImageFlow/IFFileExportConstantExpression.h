//
//  IFFileExportConstantExpression.h
//  ImageFlow
//
//  Created by Michel Schinz on 07.11.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFConstantExpression.h"
#import "IFImageConstantExpression.h"

@interface IFFileExportConstantExpression : IFConstantExpression {
  NSURL* fileURL;
  CIImage* image;
  CGRect exportArea;
}

- (id)initWithFileURL:(NSURL*)theFileURL image:(CIImage*)theImage exportArea:(CGRect)theExportArea;

- (void)executeAction;

@end
