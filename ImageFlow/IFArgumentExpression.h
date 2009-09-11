//
//  IFArgumentExpression.h
//  ImageFlow
//
//  Created by Michel Schinz on 05.09.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpression.h"

@interface IFArgumentExpression : IFExpression {
  unsigned index;
}

+ (IFArgumentExpression*)argumentExpressionWithIndex:(unsigned)index;
- (IFArgumentExpression*)initWithIndex:(unsigned)index;

@property(readonly) unsigned index;

@end
