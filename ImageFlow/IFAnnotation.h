//
//  IFAnnotation.h
//  ImageFlow
//
//  Created by Michel Schinz on 28.08.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFAnnotationSource.h"

@interface IFAnnotation : NSObject {
  NSView* view; // not retained
  IFAnnotationSource* source;
  NSAffineTransform* transform;
  NSAffineTransform* inverseTransform;
}

- (id)initWithView:(NSView*)theView source:(IFAnnotationSource*)theSource;

- (NSView*)view;
- (IFAnnotationSource*)source;

- (void)setTransform:(NSAffineTransform*)newTransform;
- (NSAffineTransform*)transform;
- (NSAffineTransform*)inverseTransform;

- (void)drawForRect:(NSRect)rect;
- (NSArray*)cursorRects;

- (bool)handleMouseDown:(NSEvent*)event;
- (bool)handleMouseUp:(NSEvent*)event;
- (bool)handleMouseDragged:(NSEvent*)event;

@end
