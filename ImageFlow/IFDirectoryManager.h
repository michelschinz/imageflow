//
//  IFDirectoryManager.h
//  ImageFlow
//
//  Created by Michel Schinz on 14.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFDirectoryManager : NSObject {
}

+ (IFDirectoryManager*)sharedDirectoryManager;

- (NSString*)documentTemplatesDirectory;
- (NSString*)userFilterTemplateDirectory;
- (NSSet*)filterTemplatesDirectories;

@end
