//
//  IFAverageCIFilter.h
//  ImageFlow
//
//  Created by Michel Schinz on 25.06.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFAverageCIFilter : CIFilter {
  NSMutableArray* inputImages;
}

- (NSUInteger)countOfInputImages;
- (CIImage*)objectInInputImagesAtIndex:(NSUInteger)index;
- (void)insertObject:(CIImage*)image inInputImagesAtIndex:(NSUInteger)index;
- (void)removeObjectFromInputImagesAtIndex:(NSUInteger)index;

@end
