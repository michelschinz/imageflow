//
//  IFFileData.m
//  ImageFlow
//
//  Created by Michel Schinz on 17.10.10.
//  Copyright 2010 Michel Schinz. All rights reserved.
//

#import "IFFileData.h"

#import "IFFNVHash.h"

@implementation IFFileData

static uint64_t dataSignature(NSData* data) {
  uint64_t signature = FNV64_init();
  const uint8_t* bytes = [data bytes];
  const NSUInteger length = [data length];
  for (NSUInteger i = 0; i < length; ++i)
    signature = FNV64_step8(signature, bytes[i]);
  return signature;
}

+ (id)fileDataWithURL:(NSURL*)theURL;
{
  NSData* urlData = [NSData dataWithContentsOfURL:theURL];
  return [[[self alloc] initWithData:urlData] autorelease];
}

+ (id)fileDataWithData:(NSData*)theData;
{
  return [[[self alloc] initWithData:theData] autorelease];
}

- (id)initWithData:(NSData*)theData;
{
  if (![super init])
    return nil;
  fileData = [theData retain];
  fileDataSignature = dataSignature(theData);
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(fileData);
  [super dealloc];
}

@synthesize fileData, fileDataSignature;

- (NSString*) contentsBasedFileName;
{
  return [NSString stringWithFormat:@"%016qX",self.fileDataSignature];
}

// MARK: NSCoding protocol

- (void)encodeWithCoder:(NSCoder*)encoder;
{
  [encoder encodeObject:fileData forKey:@"fileData"];
}

- (id)initWithCoder:(NSCoder*)decoder;
{
  return [self initWithData:[decoder decodeObjectForKey:@"fileData"]];
}

@end
