//
//  IFFilterController.h
//  ImageFlow
//
//  Created by Michel Schinz on 24.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFConfiguredFilter.h"

@interface IFFilterController : NSObject {
  IFConfiguredFilter* filter;
}

- (void)setConfiguredFilter:(IFConfiguredFilter*)newFilter;
- (IFConfiguredFilter*)configuredFilter;

@end
