//
//  IFDocumentTemplate.h
//  ImageFlow
//
//  Created by Michel Schinz on 14.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeNode.h"
#import "IFDocument.h"

@interface IFDocumentTemplate : NSObject {
  NSString* fileName;
  BOOL isLoaded;
  NSString* name;
  NSString* comment;
  IFTreeNode* node;
  BOOL nodeRequiresInlining;
}

+ (id)templateWithFileName:(NSString*)theFileName;
- (id)initWithFileName:(NSString*)theFileName;

- (NSString*)fileName;
- (NSString*)name;
- (NSString*)comment;
- (IFTreeNode*)node;
- (BOOL)nodeRequiresInlining;

@end
