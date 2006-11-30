//
//  IFRectangularWindowCIFilter.h
//  ImageFlow
//
//  Created by Michel Schinz on 30.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFRectangularWindowCIFilter : CIFilter {
  CIImage* inputImage;
  CIColor* inputMaskColor;
  CIVector* inputCutoutRectangle;
  NSNumber* inputCutoutMargin;
}

@end
