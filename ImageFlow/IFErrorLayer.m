//
//  IFErrorLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.12.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFErrorLayer.h"


@implementation IFErrorLayer

static CGImageRef warningImage = nil;

+ (void)initialize;
{
  NSString* path = [[NSBundle mainBundle] pathForResource:@"warning-sign" ofType:@"png"];
  NSURL* url = [NSURL fileURLWithPath:path];
  
  CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)url, (CFDictionaryRef)[NSDictionary dictionary]);
  warningImage = CGImageSourceCreateImageAtIndex(imageSource, 0, (CFDictionaryRef)[NSDictionary dictionary]);
  CFRelease(imageSource);
}

+ (id)layerWithLayoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
{
  return [[[self alloc] initWithLayoutParameters:theLayoutParameters canvasBounds:theCanvasBoundsVar] autorelease];
}

- (id)initWithLayoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
{
  if (![super initWithLayoutParameters:theLayoutParameters canvasBounds:theCanvasBoundsVar])
    return nil;
  self.anchorPoint = CGPointZero;
  self.contents = (id)warningImage;
  self.bounds = CGRectMake(0, 0, CGImageGetWidth(warningImage), CGImageGetHeight(warningImage));
  return self;
}

- (NSArray*)thumbnailLayers;
{
  return [NSArray array];
}

@end
