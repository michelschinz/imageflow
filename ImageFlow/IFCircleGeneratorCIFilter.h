//
//  IFCircleGeneratorCIFilter.h
//  ImageFlow
//
//  Created by Michel Schinz on 09.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFCircleGeneratorCIFilter : CIFilter {
  CIVector* inputCenter;
  NSNumber* inputRadius;
  CIColor* inputColor;
}

@end
