//
//  IFTreeTemplate.h
//  ImageFlow
//
//  Created by Michel Schinz on 26.10.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeNode.h"

@interface IFTreeTemplate : NSObject {
  NSString* name;
  NSString* description;
  IFTreeNode* node;  
}

+ (id)templateWithName:(NSString*)theName description:(NSString*)theDescription node:(IFTreeNode*)theNode;
- (id)initWithName:(NSString*)theName description:(NSString*)theDescription node:(IFTreeNode*)theNode;

- (NSString*)name;
- (NSString*)description;
- (IFTreeNode*)node;

@end
