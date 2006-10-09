//
//  IFSingleColorCIFilter.h
//  ImageFlow
//
//  Created by Michel Schinz on 21.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFSingleColorCIFilter : CIFilter {
  CIImage* inputImage;
  CIColor* inputColor;
}

@end
