//
//  IFImageVariant.h
//  ImageFlow
//
//  Created by Michel Schinz on 07.09.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeMark.h"

@interface IFImageVariant : NSObject {
  IFTreeMark* mark;
  NSString* name;
}

+ (id)variantWithMark:(IFTreeMark*)theMark name:(NSString*)theName;
- (id)initWithMark:(IFTreeMark*)theMark name:(NSString*)theName;

- (IFTreeMark*)mark;
- (NSString*)name;

- (BOOL)isEqualToImageVariant:(IFImageVariant*)other;

@end
