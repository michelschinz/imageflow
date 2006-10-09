//
//  IFColorProfile.h
//  ImageFlow
//
//  Created by Michel Schinz on 03.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Most of what follows is taken from
// http://developer.apple.com/samplecode/ImageApp/ImageApp.html

@interface IFColorProfile : NSObject {
  CMProfileRef mRef;
  CGColorSpaceRef mColorspace;
  CMProfileLocation mLocation;
  OSType mClass;
  OSType mSpace;
  NSString* mName;
  NSString* mPath;
}

+ (NSArray*)arrayOfAllProfilesWithSpace:(OSType)space;
+ (NSArray*)arrayOfAllProfiles;

+ (IFColorProfile*)profileDefaultRGB;
+ (IFColorProfile*)profileDefaultGray;
+ (IFColorProfile*)profileDefaultCMYK;

+ (IFColorProfile*)profileWithIterateData:(CMProfileIterateData*) data;
- (IFColorProfile*)initWithIterateData:(CMProfileIterateData*) data;
+ (IFColorProfile*)profileWithData:(NSData*) data;
- (IFColorProfile*)initWithData:(NSData*)data;
+ (IFColorProfile*)profileWithPath:(NSString*) path;
- (IFColorProfile*)initWithPath:(NSString*) path;

- (CMProfileRef)ref;
- (CMProfileLocation*)location;
- (OSType)classType;
- (OSType)spaceType;
- (NSString*)name;
- (NSString*)path;
- (CGColorSpaceRef)colorspace;

@end
