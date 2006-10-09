//
//  IFMaskCIFilter.h
//  ImageFlow
//
//  Created by Michel Schinz on 17.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFMaskCIFilter : CIFilter {
  CIImage* inputImage;
  CIImage* inputMaskImage;
  NSNumber* inputMaskChannel;
  NSNumber* inputMode;
}

@end
