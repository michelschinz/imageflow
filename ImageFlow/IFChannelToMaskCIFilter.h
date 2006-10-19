//
//  IFChannelToMaskCIFilter.h
//  ImageFlow
//
//  Created by Michel Schinz on 16.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
  IFChannelRed,
  IFChannelGreen,
  IFChannelBlue,
  IFChannelAlpha,
  IFChannelLuminosity
} IFChannel;

@interface IFChannelToMaskCIFilter : CIFilter {
  CIImage* inputImage;
  NSNumber* inputChannel;
}

@end
