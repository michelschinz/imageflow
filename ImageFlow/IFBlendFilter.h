//
//  IFBlendFilter.h
//  ImageFlow
//
//  Created by Michel Schinz on 09.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeNodeFilter.h"

@interface IFBlendFilter : IFTreeNodeFilter {

}

@property(readonly) IFExpression* foregroundExpression;

@end
