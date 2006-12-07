//
//  IFAnnotationRect.h
//  ImageFlow
//
//  Created by Michel Schinz on 28.08.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFAnnotation.h"

@interface IFAnnotationRect : IFAnnotation {
  NSColor* lineColor;
  float lineWidth;
  BOOL canBeDragged, canBeResized;
}

+ (id)annotationRectWithView:(NSView*)theView source:(IFVariable*)theSource;

- (float)lineWidth;
- (void)setLineWidth:(float)newLineWidth;

- (NSColor*)lineColor;
- (void)setLineColor:(NSColor*)newLineColor;

- (BOOL)canBeDragged;
- (void)setCanBeDragged:(BOOL)newCanBeDragged;

- (BOOL)canBeResized;
- (void)setCanBeResized:(BOOL)newCanBeResized;

@end
