//
//  IFStaticImageLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.12.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFStaticImageLayer.h"


@implementation IFStaticImageLayer

static CGImageRef createImageNamed(NSString* imageName) {
  NSString* path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
  NSURL* url = [NSURL fileURLWithPath:path];

  CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)url, (CFDictionaryRef)[NSDictionary dictionary]);
  CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, (CFDictionaryRef)[NSDictionary dictionary]);
  CFRelease(imageSource);

  return image;
}

+ (id)layerWithImageNamed:(NSString*)theImageName;
{
  return [[[self alloc] initWithImageNamed:theImageName] autorelease];
}

- (id)initWithImageNamed:(NSString*)theImageName;
{
  if (![super init])
    return nil;

  CGImageRef image = createImageNamed(theImageName);
  self.anchorPoint = CGPointZero;
  self.bounds = CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image));
  self.contents = (id)image;
  CGImageRelease(image);

  return self;
}

@end
