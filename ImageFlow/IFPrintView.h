//
//  IFPrintView.h
//  ImageFlow
//
//  Created by Michel Schinz on 18.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFImageConstantExpression.h"

@interface IFPrintView : NSView {
  CIImage* image;
}

+ (id)printViewWithFrame:(NSRect)theFrame image:(CIImage*)theImage;
- (id)initWithFrame:(NSRect)theFrame image:(CIImage*)theImage;

@end
