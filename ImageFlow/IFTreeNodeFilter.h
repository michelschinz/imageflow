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
#import "IFType.h"

@interface IFTreeNodeFilter : IFTreeNode<NSCoding> {
  IFEnvironment* settings;
  unsigned activeTypeIndex;
  NSMutableDictionary* parentExpressions;
  IFType* type;
  NSNib* settingsNib;
}

+ (id)nodeWithFilterNamed:(NSString*)theFilterName settings:(IFEnvironment*)theSettings;
- (id)initWithSettings:(IFEnvironment*)theSettings;

- (NSArray*)instantiateSettingsNibWithOwner:(NSObject*)owner;

// MARK: -
// MARK: PROTECTED

- (NSArray*)potentialRawExpressionsForArity:(unsigned)arity;

@end
