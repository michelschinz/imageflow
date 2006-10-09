//
//  IFGrabableViewMixin.h
//  ImageFlow
//
//  Created by Michel Schinz on 28.09.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFGrabableViewMixin : NSObject {
  NSView* view;
  int mode;
}

- (id)initWithView:(NSView*)theView;

- (BOOL)handlesKeyDown:(NSEvent*)event;
- (BOOL)handlesKeyUp:(NSEvent*)event;
- (BOOL)handlesMouseDown:(NSEvent*)event;
- (BOOL)handlesMouseUp:(NSEvent*)event;
- (BOOL)handlesMouseDragged:(NSEvent *)event;

@end
