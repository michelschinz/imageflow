//
//  IFTreeTemplateCollection.h
//  ImageFlow
//
//  Created by Michel Schinz on 06.12.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeTemplate.h"

@interface IFTreeTemplateCollection : NSObject {
  NSString* directory;
  BOOL modifiable;
  NSMutableSet* templates;
}

+ (id)treeTemplateCollectionWithDirectory:(NSString*)theDirectory;
- (id)initWithDirectory:(NSString*)theDirectory;

- (NSString*)directory;

- (NSSet*)templates;
- (BOOL)containsTemplate:(IFTreeTemplate*)treeTemplate;

- (BOOL)isModifiable;
- (void)addTemplate:(IFTreeTemplate*)treeTemplate;
- (void)removeTemplate:(IFTreeTemplate*)treeTemplate;

@end
