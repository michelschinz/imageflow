//
//  IFTreeNodeFilter.h
//  ImageFlow
//
//  Created by Michel Schinz on 22.09.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeNode.h"
#import "IFEnvironment.h"

@interface IFTreeNodeFilter : IFTreeNode<NSCoding> {
  IFEnvironment* settings;
  int activeTypeIndex;
  NSMutableDictionary* parentExpressions;
  NSNib* settingsNib;
}

+ (id)nodeWithFilterNamed:(NSString*)theFilterName settings:(IFEnvironment*)theSettings;
- (id)initWithSettings:(IFEnvironment*)theSettings;

- (NSArray*)instantiateSettingsNibWithOwner:(NSObject*)owner;

#pragma mark -
#pragma mark protected
- (NSArray*)potentialRawExpressions;

@end
