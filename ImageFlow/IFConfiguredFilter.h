//
//  IFConfiguredFilter.h
//  ImageFlow
//
//  Created by Michel Schinz on 22.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFFilter.h"
#import "IFEnvironment.h"

@interface IFConfiguredFilter : NSObject {
  IFFilter* filter;
  IFEnvironment* filterEnvironment;
  IFExpression* expression;
}

+ (IFConfiguredFilter*)ghostFilter;
+ (id)configuredFilterWithFilter:(IFFilter*)theFilter environment:(IFEnvironment*)theEnvironment;
- (id)initWithFilter:(IFFilter*)theFilter environment:(IFEnvironment*)theEnvironment;

- (IFConfiguredFilter*)clone;

- (IFFilter*)filter;
- (IFEnvironment*)environment;

- (BOOL)isGhost;
- (NSArray*)potentialTypes;
- (BOOL)acceptsParents:(int)parentsCount;
- (BOOL)acceptsChildren:(int)childsCount;
- (IFExpression*)expression;

- (NSString*)label;
- (NSString*)toolTip;

@end
