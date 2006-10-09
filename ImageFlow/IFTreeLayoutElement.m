//
//  IFTreeLayoutElement.m
//  ImageFlow
//
//  Created by Michel Schinz on 17.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFTreeLayoutElement.h"

@implementation IFTreeLayoutElement

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey;
{
  return ![theKey isEqualToString:@"bounds"] && [super automaticallyNotifiesObserversForKey:theKey];
}

- (id)initWithContainingView:(IFTreeView*)theContainingView;
{
  if (![super init]) return nil;
  containingView = theContainingView;
  translation = NSZeroPoint;
  bounds = NSZeroRect;
  return self;
}

- (IFTreeView*)containingView;
{
  return containingView;
}

- (void)setBounds:(NSRect)newBounds;
{
  if (NSEqualRects(newBounds,bounds))
    return;
  [self willChangeValueForKey:@"bounds"];
  bounds = newBounds;
  [self didChangeValueForKey:@"bounds"];
}

- (NSRect)bounds;
{
  return bounds;
}

- (NSRect)frame;
{
  NSPoint offset = [self translation];
  return NSOffsetRect(bounds,offset.x,offset.y);
}

- (void)setTranslation:(NSPoint)thePoint;
{
  translation = thePoint;
}

- (NSPoint)translation;
{
  return NSMakePoint(round(translation.x),round(translation.y));
}

- (void)translateBy:(NSPoint)offset;
{
  NSPoint currTranslation = [self translation];
  [self setTranslation:NSMakePoint(currTranslation.x + offset.x, currTranslation.y + offset.y)];
}

- (IFTreeNode*)node;
{
  return nil;
}

- (void)activate;
{ }

- (void)activateWithMouseDown:(NSEvent*)event;
{ }

- (void)deactivate;
{ }

- (void)setNeedsDisplay;
{
  [containingView setNeedsDisplayInRect:[self frame]];
}

-(void)drawForRect:(NSRect)rect;
{
  NSAffineTransform* localTranslation = [NSAffineTransform transform];
  NSPoint offset = [self translation];
  [localTranslation translateXBy:offset.x yBy:offset.y];
  [localTranslation concat];
  NSAffineTransform* invLocalTranslation = [NSAffineTransform transform];
  [invLocalTranslation translateXBy:-offset.x yBy:-offset.y];
  
  NSRect localRect = { [invLocalTranslation transformPoint:rect.origin], rect.size };
  [self drawForLocalRect:localRect];
  
  [invLocalTranslation concat];
}

- (void)drawForLocalRect:(NSRect)localRect;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (NSImage*)dragImage;
{
  [NSGraphicsContext saveGraphicsState];
  
  NSRect enclosingRect = { NSZeroPoint, [self bounds].size };
  NSBitmapImageRep* opaqueImageRep = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                              pixelsWide:NSWidth(enclosingRect)
                                                                              pixelsHigh:NSHeight(enclosingRect)
                                                                           bitsPerSample:8
                                                                         samplesPerPixel:4
                                                                                hasAlpha:YES
                                                                                isPlanar:NO
                                                                          colorSpaceName:NSCalibratedRGBColorSpace
                                                                             bytesPerRow:0
                                                                            bitsPerPixel:0] autorelease];
  [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:opaqueImageRep]];
  [[NSColor clearColor] set];
  NSRectFillUsingOperation(enclosingRect,NSCompositeClear);
  NSAffineTransform* transform = [NSAffineTransform transform];
  [transform translateXBy:-NSMinX([self bounds]) yBy:-NSMinY([self bounds])];
  [transform concat];
  [self drawForLocalRect:enclosingRect];
  NSImage* opaqueImage = [[NSImage new] autorelease];
  [opaqueImage addRepresentation:opaqueImageRep];
  
  NSBitmapImageRep* transparentImageRep = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                                   pixelsWide:NSWidth(enclosingRect)
                                                                                   pixelsHigh:NSHeight(enclosingRect)
                                                                                bitsPerSample:8
                                                                              samplesPerPixel:4
                                                                                     hasAlpha:YES
                                                                                     isPlanar:NO
                                                                               colorSpaceName:NSCalibratedRGBColorSpace
                                                                                  bytesPerRow:0
                                                                                 bitsPerPixel:0] autorelease];
  [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:transparentImageRep]];
  [[NSColor clearColor] set];
  NSRectFillUsingOperation(enclosingRect,NSCompositeClear);
  [opaqueImage dissolveToPoint:NSZeroPoint fraction:0.6];
  NSImage* transparentImage = [[NSImage new] autorelease];
  [transparentImage addRepresentation:transparentImageRep];
  
  [NSGraphicsContext restoreGraphicsState];
  
  return transparentImage;
}

- (NSSet*)leavesOfKind:(IFTreeLayoutElementKind)kind;
{
  return [NSSet set];
}

- (IFTreeLayoutSingle*)layoutElementForNode:(IFTreeNode*)node kind:(IFTreeLayoutElementKind)kind;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

-(IFTreeLayoutElement*)layoutElementAtPoint:(NSPoint)thePoint;
{
  return nil;
}

- (NSSet*)layoutElementsIntersectingRect:(NSRect)rect kind:(IFTreeLayoutElementKind)kind;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

@end
