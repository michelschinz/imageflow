//
//  IFFileExportAction.h
//  ImageFlow
//
//  Created by Michel Schinz on 15.11.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFAction.h"

@interface IFFileExportAction : IFAction {
  NSURL* fileURL;
  CIImage* image;
  CGRect exportArea;  
}

+ (id)exportActionWithFileURL:(NSURL*)theFileURL image:(CIImage*)theImage exportArea:(CGRect)theExportArea;
- (id)initWithFileURL:(NSURL*)theFileURL image:(CIImage*)theImage exportArea:(CGRect)theExportArea;

@end
