//
//  IFDirectoryManager.h
//  ImageFlow
//
//  Created by Michel Schinz on 14.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFDirectoryManager : NSObject {
  NSString* applicationSupportDirectory;
}

+ (IFDirectoryManager*)sharedDirectoryManager;

- (NSString*)sourceTemplatesDirectory;

- (NSString*)applicationSupportDirectory;
- (NSString*)templatesDirectory;
- (NSString*)filterTemplatesDirectory;
- (NSString*)documentTemplatesDirectory;

@end
