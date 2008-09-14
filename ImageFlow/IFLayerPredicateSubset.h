//
//  IFLayerPredicateSubset.h
//  ImageFlow
//
//  Created by Michel Schinz on 12.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFLayerSubset.h"

@interface IFLayerPredicateSubset : IFLayerSubset {
  NSPredicate* predicate;
}

+ (id)subsetOf:(IFLayerSet*)theSet predicate:(NSPredicate*)thePredicate;

- (id)initWithSet:(IFLayerSet*)theSet predicate:(NSPredicate*)thePredicate;

@end
