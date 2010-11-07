//
//  IFFileData.h
//  ImageFlow
//
//  Created by Michel Schinz on 17.10.10.
//  Copyright 2010 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFFileData : NSObject<NSCoding> {
  NSData* fileData;
  uint64_t fileDataSignature;
}

+ (id)fileDataWithURL:(NSURL*)theFileURL;
+ (id)fileDataWithData:(NSData*)theData;

- (id)initWithData:(NSData*)theData;

@property(readonly) NSData* fileData;
@property(readonly) uint64_t fileDataSignature;
@property(readonly) NSString* contentsBasedFileName;

@end