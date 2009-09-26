//
//  IFApplyExpression.h
//  ImageFlow
//
//  Created by Michel Schinz on 26.09.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpression.h"

@interface IFApplyExpression : IFExpression {
  IFExpression* function;
  IFExpression* argument;
}

- (id)initWithFunction:(IFExpression*)theFunction argument:(IFExpression*)theArgument;

@property(readonly) IFExpression* function;
@property(readonly) IFExpression* argument;

@end
