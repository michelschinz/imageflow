//
//  IFHistogramConstantExpression.h
//  ImageFlow
//
//  Created by Michel Schinz on 28.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFConstantExpression.h"
#import "IFImageConstantExpression.h"
#import "IFHistogramData.h"

@interface IFHistogramConstantExpression : IFConstantExpression {
  IFImageConstantExpression* imageExpression;
  CGColorSpaceRef colorSpace;
}

+ (id)histogramWithImageExpression:(IFImageConstantExpression*)theImageExpression colorSpace:(CGColorSpaceRef)theColorSpace;
- (id)initWithImageExpression:(IFImageConstantExpression*)theImageExpression colorSpace:(CGColorSpaceRef)theColorSpace;

- (NSArray*)histogramValue;

// protected
- (NSArray*)force;

@end
