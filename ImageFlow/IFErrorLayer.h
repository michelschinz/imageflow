//
//  IFErrorLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 04.12.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFNodeLayer.h"

@interface IFErrorLayer : CALayer<IFExpressionContentsLayer> {

}

+ (id)layer;

- (void)setExpression:(IFConstantExpression*)newExpression;

@end
