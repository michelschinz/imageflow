//
//  IFCropImageWithMaskCIFilter.h
//  ImageFlow
//
//  Created by Michel Schinz on 29.08.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFCropImageWithMaskCIFilter : CIFilter {
  CIImage* inputImage;
  CIVector* inputRectangle;
}

@end
