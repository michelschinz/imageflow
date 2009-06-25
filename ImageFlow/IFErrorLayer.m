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

- (id)init;
{
  if (![super init])
    return nil;
  self.anchorPoint = CGPointZero;
  self.contents = (id)warningImage;
  self.bounds = CGRectMake(0, 0, CGImageGetWidth(warningImage), CGImageGetHeight(warningImage));
  return self;
}

+ (id)layer;
{
  return [[[self alloc] init] autorelease];
}

- (void)setExpression:(IFConstantExpression*)newExpression;
{
  // ignore expression
}

@end
