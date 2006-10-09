//
//  IFCursorRect.h
//  ImageFlow
//
//  Created by Michel Schinz on 31.08.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFCursorRect : NSObject {
  NSRect rect;
  NSCursor* cursor;
}

+ (id)cursor:(NSCursor*)theCursor rect:(NSRect)theRect;
- (id)initWithCursor:(NSCursor*)theCursor rect:(NSRect)theRect;

- (NSCursor*)cursor;
- (NSRect)rect;

@end
