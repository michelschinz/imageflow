//
//  IFRectIVarController.h
//  ImageFlow
//
//  Created by Michel Schinz on 07.12.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IFRectIVarController : NSObject {
  NSObject* object;
  NSString* key;
  NSRect rect;
}

- (void)setObject:(NSObject*)newObject andKey:(NSString*)newKey;

- (float)originX;
- (void)setOriginX:(float)newOriginX;

- (float)originY;
- (void)setOriginY:(float)newOriginY;

- (float)width;
- (void)setWidth:(float)newWidth;

- (float)height;
- (void)setHeight:(float)newHeight;

@end
