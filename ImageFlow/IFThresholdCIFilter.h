//
//  IFThresholdCIFilter.h
//  ImageFlow
//
//  Created by Michel Schinz on 02.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IFThresholdCIFilter : CIFilter {
  CIImage* inputImage;
  NSNumber* inputThreshold;
}

@end
