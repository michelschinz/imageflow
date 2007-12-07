//
//  IFTreeTemplate.h
//  ImageFlow
//
//  Created by Michel Schinz on 26.10.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTree.h"

@interface IFTreeTemplate : NSObject {
  NSString* name;
  NSString* description;
  IFTree* tree;

  NSString* fileName;
  NSString* tag;
}

+ (id)templateWithName:(NSString*)theName description:(NSString*)theDescription tree:(IFTree*)theTree;
- (id)initWithName:(NSString*)theName description:(NSString*)theDescription tree:(IFTree*)theTree;

- (NSString*)name;
- (NSString*)description;
- (IFTree*)tree;

- (NSString*)fileName;
- (void)setFileName:(NSString*)newFileName;

- (NSString*)tag;
- (void)setTag:(NSString*)theTag;

@end
