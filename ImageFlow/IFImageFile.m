//
//  IFImageFile.m
//  ImageFlow
//
//  Created by Michel Schinz on 22.11.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import "IFImageFile.h"

@implementation IFImageFile

- (id)initWithImageCI:(CIImage*)theImageCI;
{
  if (![super initWithKind:IFImageKindRGBImage])
    return nil;
  imageCI = [theImageCI retain];
  return self;
}

- (id)initWithContentsOfURL:(NSURL*)theFileURL;
{
  return [self initWithImageCI:[CIImage imageWithData:[NSData dataWithContentsOfURL:theFileURL]]];
}

- (id)initWithData:(NSData*)theData;
{
  return [self initWithImageCI:[CIImage imageWithData:theData]];
}

- (void)dealloc;
{
  OBJC_RELEASE(imageCI);
  [super dealloc];
}

- (CGRect)extent;
{
  return [imageCI extent];
}

@synthesize imageCI;

- (BOOL)isLocked;
{
  return [self retainCount] > 1 || [imageCI retainCount] > 1;
}

// MARK: NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder;
{
  return [self initWithImageCI:[decoder decodeObjectForKey:@"imageCI"]];
}

- (void)encodeWithCoder:(NSCoder *)encoder;
{
  [encoder encodeObject:imageCI forKey:@"imageCI"];
}

@end
