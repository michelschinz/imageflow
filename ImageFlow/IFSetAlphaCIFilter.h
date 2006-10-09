//
//  IFSetAlphaCIFilter.h
//  ImageFlow
//
//  Created by Michel Schinz on 18.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFSetAlphaCIFilter : CIFilter {
  CIImage* inputImage;
  NSNumber* inputAlpha;
}

@end
