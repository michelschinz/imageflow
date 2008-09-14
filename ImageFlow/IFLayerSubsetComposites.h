//
//  IFLayerSubsetComposites.h
//  ImageFlow
//
//  Created by Michel Schinz on 04.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFLayerSubset.h"

@interface IFLayerSubsetComposites : IFLayerSubset {

}

+ (id)compositeSubsetOf:(IFLayerSet*)theSet;

@end
