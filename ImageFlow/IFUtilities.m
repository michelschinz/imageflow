//
//  IFUtilities.m
//  ImageFlow
//
//  Created by Michel Schinz on 08.09.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFUtilities.h"

static const void *retainCallback(CFAllocatorRef allocator, const void *value)
{
  [(NSObject*)value retain];
  return value;
}

static const void *releaseCallback(CFAllocatorRef allocator, const void *value)
{
  [(NSObject*)value release];
  return value;
}

NSMutableDictionary* createMutableDictionaryWithRetainedKeys()
{
  CFDictionaryKeyCallBacks keyCallbacks = {
    0, (CFDictionaryRetainCallBack)retainCallback, (CFDictionaryReleaseCallBack)releaseCallback, NULL, NULL, NULL
  };
  CFDictionaryValueCallBacks valueCallbacks = {
    0, (CFDictionaryRetainCallBack)retainCallback, (CFDictionaryReleaseCallBack)releaseCallback, NULL, NULL
  };
  return (NSMutableDictionary*)CFDictionaryCreateMutable(NULL,0,&keyCallbacks,&valueCallbacks);
}

CGSize CGSizeFromNSSize(NSSize s) {
  return CGSizeMake(s.width,s.height);
}

NSSize NSSizeFromCGSize(CGSize s) {
  return NSMakeSize(s.width,s.height);
}

CGRect CGRectFromNSRect(NSRect r) {
  return CGRectMake(NSMinX(r),NSMinY(r),NSWidth(r),NSHeight(r));
}

NSRect NSRectFromCGRect(CGRect r) {
  return NSMakeRect(CGRectGetMinX(r),CGRectGetMinY(r),CGRectGetWidth(r),CGRectGetHeight(r));
}

NSRect NSRectFromCIVector(CIVector* v) {
  return NSMakeRect([v X],[v Y],[v Z],[v W]);
}

NSRect NSRectInfinite() {
  return NSRectFromCGRect(CGRectInfinite);
}

// taken from http://developer.apple.com/qa/qa2004/qa1396.html
CGColorSpaceRef CreateICCColorSpaceFromPathToProfile (const char * iccProfilePath) {
  CMProfileRef iccProfile = (CMProfileRef) 0;
  CGColorSpaceRef iccColorSpace = NULL;
  CMProfileLocation loc;
  
  // Specify that the location of the profile will be a POSIX path to the profile.
  loc.locType = cmPathBasedProfile;
  
  // Make sure the path is not larger then the buffer
  if (strlen(iccProfilePath) > sizeof(loc.u.pathLoc.path))
    return NULL;
  
  // Copy the path the profile into the CMProfileLocation structure
  strcpy (loc.u.pathLoc.path, iccProfilePath);
  
  // Open the profile
  if (CMOpenProfile(&iccProfile, &loc) != noErr)
  {
    iccProfile = (CMProfileRef) 0;
    return NULL;
  }
  
  // Create the ColorSpace with the open profile.
  iccColorSpace = CGColorSpaceCreateWithPlatformColorSpace( iccProfile );
  
  // Close the profile now that we have what we need from it.
  CMCloseProfile(iccProfile);
  
  return iccColorSpace;
}

// taken from http://developer.apple.com/qa/qa2004/qa1396.html
CGColorSpaceRef CreateColorSpaceFromSystemICCProfileName(NSString* profileNameNS) {
  CFStringRef profileName = (CFStringRef)profileNameNS;
  FSRef pathToProfilesFolder;
  FSRef pathToProfile;
  
  // Find the Systems Color Sync Profiles folder
  if(FSFindFolder(kOnSystemDisk, kColorSyncProfilesFolderType,
                  kDontCreateFolder, &pathToProfilesFolder) == noErr) {
    
    // Make a UniChar string of the profile name
    UniChar uniBuffer[sizeof(CMPathLocation)];
    CFStringGetCharacters (profileName,CFRangeMake(0,CFStringGetLength(profileName)),uniBuffer);
    
    // Create a FSRef to the profile in the Systems Color Sync Profile folder
    if(FSMakeFSRefUnicode (&pathToProfilesFolder,CFStringGetLength(profileName),uniBuffer,
                           kUnicodeUTF8Format,&pathToProfile) == noErr) {
      char path[sizeof(CMPathLocation)];
      
      // Write the posix path to the profile into our path buffer from the FSRef
      if(FSRefMakePath (&pathToProfile,(unsigned char*)path,sizeof(CMPathLocation)) == noErr)
        return CreateICCColorSpaceFromPathToProfile(path);
    }
  }
  
  return NULL;
}

