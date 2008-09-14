//
//  IFCompositeLayoutManager.h
//  ImageFlow
//
//  Created by Michel Schinz on 17.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeLayoutParameters.h"

@interface IFCompositeLayoutManager : NSObject {
  IFTreeLayoutParameters* layoutParameters;
}

+ (id)compositeLayoutManagerWithLayoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;

- (void)layoutSublayersOfLayer:(CALayer*)layer;

@end
