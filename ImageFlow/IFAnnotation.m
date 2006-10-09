//
//  IFAnnotation.m
//  ImageFlow
//
//  Created by Michel Schinz on 28.08.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFAnnotation.h"

@implementation IFAnnotation

- (id)initWithView:(NSView*)theView source:(IFAnnotationSource*)theSource;
{
  if (![super init])
    return nil;
  view = theView;
  source = [theSource retain];
  transform = [[NSAffineTransform transform] retain];
  inverseTransform = [transform copy];
  [source addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
  return self;
}

- (void)dealloc;
{
  [source removeObserver:self forKeyPath:@"value"];
  [inverseTransform release];
  inverseTransform = nil;
  [transform release];
  transform = nil;
  [source release];
  source = nil;
  view = nil;
  [super dealloc];
}

- (NSView*)view;
{
  return view;
}

- (IFAnnotationSource*)source;
{
  return source;
}

- (void)setTransform:(NSAffineTransform*)newTransform;
{
  [transform setTransformStruct:[newTransform transformStruct]];
  [inverseTransform setTransformStruct:[newTransform transformStruct]];
  [inverseTransform invert];
  
  [view setNeedsDisplay:YES]; // TODO set only for affected area
}

- (NSAffineTransform*)transform;
{
  return transform;
}

- (NSAffineTransform*)inverseTransform;
{
  return inverseTransform;
}

- (void)drawForRect:(NSRect)rect;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (NSArray*)cursorRects;
{
  return [NSArray array];
}

- (bool)handleMouseDown:(NSEvent*)event;
{
  return NO;
}

- (bool)handleMouseUp:(NSEvent*)event;
{
  return NO;
}

- (bool)handleMouseDragged:(NSEvent*)event;
{
  return NO;
}

@end
