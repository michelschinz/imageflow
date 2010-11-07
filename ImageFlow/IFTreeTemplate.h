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

  NSString* dirName;
  NSString* tag;
}

+ (id)templateWithName:(NSString*)theName description:(NSString*)theDescription tree:(IFTree*)theTree;
- (id)initWithName:(NSString*)theName description:(NSString*)theDescription tree:(IFTree*)theTree;

@property(readonly) NSString* name;
@property(readonly) NSString* description;
@property(readonly) IFTree* tree;

@property(retain) NSString* dirName;
@property(retain, nonatomic) NSString* tag;

@end
