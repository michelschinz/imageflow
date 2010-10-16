//
//  IFImageFile.h
//  ImageFlow
//
//  Created by Michel Schinz on 22.11.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFImage.h"

@interface IFImageFile : IFImage<NSCoding> {
  NSURL* fileURL;
  NSData* encodedData;
  CIImage* imageCI;
}

- (id)initWithFileURL:(NSURL*)theFileURL;

@property(readonly) NSURL* fileURL;

@end
