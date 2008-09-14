//
//  IFLayerSubset.h
//  ImageFlow
//
//  Created by Michel Schinz on 14.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFLayerSet.h"

@interface IFLayerSubset : IFLayerSet {
  IFLayerSet* set;
}

- (id)initWithSet:(IFLayerSet*)theSet;

- (BOOL)shouldContain:(IFLayer*)layerCandidate; // abstract

@end
