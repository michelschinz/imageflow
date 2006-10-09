//
//  IFColorProfileNamer.h
//  ImageFlow
//
//  Created by Michel Schinz on 24.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFColorProfile.h"
#import "IFObjectNamer.h"

@interface IFColorProfileNamer : NSObject {
  NSArray* allProfiles;
  IFObjectNamer* namer;
}

+ (IFColorProfileNamer*)sharedNamer;

- (NSArray*)uniqueNamesOfProfilesWithSpace:(OSType)space;

- (NSString*)pathForProfileWithUniqueName:(NSString*)name;
- (NSString*)uniqueNameForProfileWithPath:(NSString*)path;


@end
