//
//  IFTreeTemplateManager.h
//  ImageFlow
//
//  Created by Michel Schinz on 26.10.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeTemplate.h"
#import "IFTreeTemplateCollection.h"

@interface IFTreeTemplateManager : NSObject {
  NSSet* collections;
  NSSet* templates;
  IFTreeTemplateCollection* defaultModifiableCollection; // not retained
  IFTreeTemplate* loadFileTemplate; // not retained
}

+ (IFTreeTemplateManager*)sharedManager;

- (NSSet*)collections;
- (IFTreeTemplateCollection*)collectionContainingTemplate:(IFTreeTemplate*)treeTemplate;

- (NSSet*)templates;
- (void)addTemplate:(IFTreeTemplate*)treeTemplate;
- (BOOL)canMoveTemplate:(IFTreeTemplate*)treeTemplate toCollection:(IFTreeTemplateCollection*)targetCollection;
- (void)moveTemplate:(IFTreeTemplate*)treeTemplate toCollection:(IFTreeTemplateCollection*)targetCollection;

- (IFTreeTemplate*)loadFileTemplate;

@end
