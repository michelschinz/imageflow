//
//  IFExpressionVisitor.m
//  ImageFlow
//
//  Created by Michel Schinz on 30.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFExpressionVisitor.h"


@implementation IFExpressionVisitor

- (void)caseLambdaExpression:(IFLambdaExpression*)expression;
{
}

- (void)caseOperatorExpression:(IFOperatorExpression*)expression;
{
}

- (void)caseParentExpression:(IFParentExpression*)expression;
{
}

- (void)caseVariableExpression:(IFVariableExpression*)expression;
{
}

- (void)caseArgumentExpression:(IFArgumentExpression*)expression;
{
}

- (void)caseConstantExpression:(IFConstantExpression*)expression;
{
}

@end
