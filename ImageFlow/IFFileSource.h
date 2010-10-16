//
//  IFFileSource.h
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeNodeFilter.h"
#import "IFImageFile.h"

@interface IFFileSource : IFTreeNodeFilter {
  IFImageFile* cachedImage;
}

@end
