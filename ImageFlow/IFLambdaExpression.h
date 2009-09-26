//
//  IFLambdaExpression.h
//  ImageFlow
//
//  Created by Michel Schinz on 05.09.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpression.h"

@interface IFLambdaExpression : IFExpression {
  IFExpression* body;
  NSUInteger hash;
}

- (IFLambdaExpression*)initWithBody:(IFExpression*)theBody;

@property(readonly) IFExpression* body;

@end
