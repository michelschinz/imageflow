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
  BOOL isModifiable;
  NSMutableSet* templates;
}

+ (id)treeTemplateCollectionWithDirectory:(NSString*)theDirectory;
- (id)initWithDirectory:(NSString*)theDirectory;

@property(readonly) NSString* directory;
@property(readonly) NSSet* templates;
@property(readonly) BOOL isModifiable;

- (void)addTemplate:(IFTreeTemplate*)treeTemplate;
- (void)removeTemplate:(IFTreeTemplate*)treeTemplate;
- (BOOL)containsTemplate:(IFTreeTemplate*)treeTemplate;

@end
