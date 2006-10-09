//
//  IFDocumentTemplateManager.h
//  ImageFlow
//
//  Created by Michel Schinz on 14.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFDocumentTemplate.h"

@interface IFDocumentTemplateManager : NSObject {
  NSString* directory;
  NSArray* templates;
}

+ (id)managerWithDirectory:(NSString*)theDirectory;
- (id)initWithDirectory:(NSString*)theDirectory;

- (NSArray*)templates;
- (IFDocumentTemplate*)templateWithName:(NSString*)name;

// pre-defined templates
- (IFDocumentTemplate*)loadFileTemplate;

@end
