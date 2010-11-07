//
//  IFAnnotation.m
//  ImageFlow
//
//  Created by Michel Schinz on 28.08.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFAnnotation.h"

@implementation IFAnnotation

+ (id)annotationWithView:(NSView*)theView source:(IFVariable*)theSource;
{
  return [[[self alloc] initWithView:theView source:theSource] autorelease];
}

- (id)initWithView:(NSView*)theView source:(IFVariable*)theSource;
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
  OBJC_RELEASE(inverseTransform);
  OBJC_RELEASE(transform);
  OBJC_RELEASE(source);
  view = nil;
  [super dealloc];
}

- (NSView*)view;
{
  return view;
}

- (IFVariable*)source;
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
