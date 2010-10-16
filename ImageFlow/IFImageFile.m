//
//  IFImageFile.m
//  ImageFlow
//
//  Created by Michel Schinz on 22.11.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import "IFImageFile.h"

@implementation IFImageFile

- (id)initWithFileURL:(NSURL *)theFileURL encodedData:(NSData*)theEncodedData imageCI:(CIImage*)theImageCI;
{
  if (![super initWithKind:IFImageKindRGBImage])
    return nil;
  fileURL = [theFileURL retain];
  encodedData = [theEncodedData retain];
  imageCI = [theImageCI retain];
  return self;
}

- (id)initWithFileURL:(NSURL*)theFileURL;
{
  NSData* fileData = [NSData dataWithContentsOfURL:theFileURL];
  return [self initWithFileURL:theFileURL encodedData:fileData imageCI:[CIImage imageWithData:fileData]];
}

- (void)dealloc;
{
  OBJC_RELEASE(imageCI);
  OBJC_RELEASE(encodedData);
  OBJC_RELEASE(fileURL);
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

@synthesize encodedData;

@synthesize fileURL;

// MARK: NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder;
{
  return [self initWithFileURL:[decoder decodeObjectForKey:@"fileURL"] encodedData:[decoder decodeObjectForKey:@"encodedData"] imageCI:[decoder decodeObjectForKey:@"imageCI"]];
}

- (void)encodeWithCoder:(NSCoder *)encoder;
{
  [encoder encodeObject:fileURL forKey:@"fileURL"];
  [encoder encodeObject:encodedData forKey:@"encodedData"];
  [encoder encodeObject:imageCI forKey:@"imageCI"];
}

@end
