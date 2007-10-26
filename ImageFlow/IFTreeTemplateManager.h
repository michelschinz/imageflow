//
//  IFTreeTemplateManager.h
//  ImageFlow
//
//  Created by Michel Schinz on 26.10.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeTemplate.h"

@interface IFTreeTemplateManager : NSObject {
  NSString* directory;
  NSArray* templates;

}

+ (IFTreeTemplateManager*)sharedManager;

- (id)initWithDirectory:(NSString*)theDirectory;

- (NSArray*)templates;

- (IFTreeTemplate*)loadFileTemplate;

@end
