//
//  IFColorProfile.m
//  ImageFlow
//
//  Created by Michel Schinz on 03.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFColorProfile.h"

// Most of what follows is taken from
// http://developer.apple.com/samplecode/ImageApp/ImageApp.html

// Callback routine with a description of a profile that is 
// called during an iteration through the available profiles.
static OSErr profileIterate (CMProfileIterateData *info, void *refCon) {
  NSMutableArray* array = (NSMutableArray*) refCon;
  
  IFColorProfile* prof = [IFColorProfile profileWithIterateData:info];
  if (prof)
    [array addObject:prof];
  
  return noErr;
}

@implementation IFColorProfile

// return an array of all profiles
+ (NSArray*) arrayOfAllProfiles;
{
  NSMutableArray* profs = [NSMutableArray array];
  
  CMProfileIterateUPP iterUPP = NewCMProfileIterateUPP(profileIterate);
  CMIterateColorSyncFolder(iterUPP, NULL, 0L, profs);
  DisposeCMProfileIterateUPP(iterUPP);
  
  return (NSArray*)profs;
}

// return an array of all profiles for the given color space
+ (NSArray*) arrayOfAllProfilesWithSpace:(OSType)space;
{
  NSArray* profArray = [IFColorProfile arrayOfAllProfiles];
  NSMutableArray*  profs = [NSMutableArray arrayWithCapacity:0];
  
  CFIndex count = [profArray count];
  for (CFIndex i = 0; i < count; i++) {
    IFColorProfile* prof = [profArray objectAtIndex:i];
    OSType pClass = [prof classType];
    
    if ([prof spaceType] == space && [prof description] && (pClass==cmDisplayClass || pClass==cmOutputClass))
      [profs addObject:prof];
  }
  return profs;
}

// default RGB profile
+ (IFColorProfile*) profileDefaultRGB;
{
  NSString* path = @"/System/Library/ColorSync/Profiles/Generic RGB Profile.icc";
  return [IFColorProfile profileWithPath:path];
}

// default Gray profile
+ (IFColorProfile*) profileDefaultGray;
{
  NSString* path = @"/System/Library/ColorSync/Profiles/Generic Gray Profile.icc";
  return [IFColorProfile profileWithPath:path];
}

// default CMYK profile
+ (IFColorProfile*) profileDefaultCMYK;
{
  NSString* path = @"/System/Library/ColorSync/Profiles/Generic CMYK Profile.icc";
  return [IFColorProfile profileWithPath:path];
}

// build profile from iterate data
+ (IFColorProfile*) profileWithIterateData:(CMProfileIterateData*) data;
{
  return [[[IFColorProfile alloc] initWithIterateData:data] autorelease];
}

+ (IFColorProfile*) profileWithData:(NSData*) data;
{
  return [[[self alloc] initWithData:data] autorelease];
}

// build profile from path
+ (IFColorProfile*) profileWithPath:(NSString*) path;
{
  return [[[IFColorProfile alloc] initWithPath:path] autorelease];
}

- (IFColorProfile*)initWithIterateData:(CMProfileIterateData*)info;
{
  const size_t kMaxProfNameLen = 36;
  
  mLocation  = info->location;
  mClass = info->header.profileClass;
  mSpace = info->header.dataColorSpace;
  
  if (info->uniCodeNameCount > 1)
  {
    CFIndex numChars = info->uniCodeNameCount - 1;
    if (numChars > kMaxProfNameLen) numChars = kMaxProfNameLen;
    mName = [[NSString stringWithCharacters:info->uniCodeName length:numChars] retain];
  }
  
  return self;
}

- (IFColorProfile*) initWithData:(NSData*)data;
{
  mLocation.locType  = cmBufferBasedProfile;
  mLocation.u.bufferLoc.buffer = (void*)[data bytes];
  mLocation.u.bufferLoc.size = [data length];
  mClass = cmDisplayClass; // TODO extract from data, is possible (see below)
  mSpace = cmRGBData; // TODO extract from data, is possible (see below)
  
  if (CMOpenProfile(&mRef, &mLocation) == noErr)
    return self;
  else {
    [self autorelease];
    return nil;
  }
}

- (IFColorProfile*) initWithPath:(NSString*) path;
{
  if (path == nil) {
    [self autorelease];
    return nil;
  }
    
  mPath = [path retain];
    
  mLocation.locType = cmPathBasedProfile;
  strncpy(mLocation.u.pathLoc.path, [path fileSystemRepresentation], 255);

  CMAppleProfileHeader header;
  if (noErr==CMGetProfileHeader([self ref], &header)) {
    mClass = header.cm2.profileClass;
    mSpace = header.cm2.dataColorSpace;
  }
  return self;
}

- (void) dealloc;
{
  CMCloseProfile(mRef);
  CGColorSpaceRelease(mColorspace);
  [mName release];
  [mPath release];
  [super dealloc];
}

- (CMProfileRef) ref;
{
  if (mRef == NULL)
    (void) CMOpenProfile(&mRef, &mLocation);
  return mRef;
}

- (CMProfileLocation*) location;
{
  return &mLocation;
}

// profile class
- (OSType) classType;
{
  return mClass;
}

// profile space
- (OSType) spaceType;
{
  return mSpace;
}

// profile description string
- (NSString*) name;
{
  if (mName == nil)
    CMCopyProfileDescriptionString([self ref], (CFStringRef*) &mName);
  return mName;
}

- (NSString*) description;
{
  return [self name];
}

// profile path
- (NSString*) path {
  if (mPath == nil) {
    if (mLocation.locType == cmFileBasedProfile) {
      FSRef fsref;
      UInt8 path[1024];
      if (FSpMakeFSRef(&(mLocation.u.fileLoc.spec), &fsref) == noErr && FSRefMakePath(&fsref, path, 1024) == noErr)
        mPath = [[NSString stringWithUTF8String:(const char *)path] retain];
    } else if (mLocation.locType == cmPathBasedProfile)
      mPath = [[NSString stringWithUTF8String:mLocation.u.pathLoc.path] retain];
  }
  return mPath;
}

- (BOOL)isEqual:(id)obj
{
  if ([obj isKindOfClass:[self class]])
    return [[self path] isEqualToString:[obj path]];
  return [super isEqual:obj];
}

- (CGColorSpaceRef) colorspace;
{
  if (mColorspace == nil)
    mColorspace = CGColorSpaceCreateWithPlatformColorSpace([self ref]);
  return mColorspace;
}

@end
