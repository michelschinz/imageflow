//
//  IFParentExpression.h
//  ImageFlow
//
//  Created by Michel Schinz on 25.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpression.h"

@interface IFParentExpression : IFExpression {
  int index;
}

+ (id)parentExpressionWithIndex:(int)index;
- (id)initWithIndex:(int)index;

- (int)index;

@end
