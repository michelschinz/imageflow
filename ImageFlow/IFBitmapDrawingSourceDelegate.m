//
//  IFBitmapDrawingSourceDelegate.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFBitmapDrawingSourceDelegate.h"

#import "IFEnvironment.h"
#import "IFConfiguredFilter.h"

@implementation IFBitmapDrawingSourceDelegate

- (NSString*)labelWithEnvironment:(IFEnvironment*)env;
{
  return @"draw bitmap";
}

- (void)mouseDown:(NSEvent*)event atPoint:(NSPoint)point withEnvironment:(IFEnvironment*)env;
{
  IFExpression* curExpr = [env valueForKey:@"drawing"];
  IFExpression* brushExpr = [IFOperatorExpression expressionWithOperator:[IFOperator operatorForName:@"circle"]
                                                                operands:[NSArray arrayWithObjects:
                                                                  [IFConstantExpression expressionWithPointNS:NSZeroPoint],
                                                                  [IFConstantExpression expressionWithFloat:[[env valueForKey:@"brushSize"] floatValue]],
                                                                  [IFConstantExpression expressionWithColorNS:[env valueForKey:@"brushColor"]],
                                                                  nil]];
  IFExpression* pointExpr = [IFConstantExpression expressionWithArray:[NSArray arrayWithObject:[IFConstantExpression expressionWithPointNS:point]]];  
  IFExpression* paintExpr = [IFOperatorExpression expressionWithOperator:[IFOperator operatorForName:@"paint"]
                                                                operands:[NSArray arrayWithObjects:brushExpr,pointExpr,nil]];
  IFExpression* newExpr = [IFOperatorExpression blendBackground:curExpr
                                                 withForeground:paintExpr
                                                         inMode:@"over"];
  [env setValue:newExpr forKey:@"drawing"];
}

- (void)mouseDragged:(NSEvent*)event atPoint:(NSPoint)point withEnvironment:(IFEnvironment*)env;
{
  IFOperatorExpression* curBlendExpr = (IFOperatorExpression*)[env valueForKey:@"drawing"];
  NSAssert1([curBlendExpr isKindOfClass:[IFOperatorExpression class]]
            && [(IFOperatorExpression*)curBlendExpr operator] == [IFOperator operatorForName:@"blend"],
            @"unexpected expression:", curBlendExpr);

  IFOperatorExpression* curPaintExpr = (IFOperatorExpression*)[[curBlendExpr operands] objectAtIndex:1];
  NSAssert1([curPaintExpr isKindOfClass:[IFOperatorExpression class]]
            && [(IFOperatorExpression*)curPaintExpr operator] == [IFOperator operatorForName:@"paint"],
            @"unexpected expression:", curPaintExpr);

  IFExpression* brush = [[curPaintExpr operands] objectAtIndex:0];
  NSArray* curPoints = [[[curPaintExpr operands] objectAtIndex:1] arrayValue];

  IFExpression* pointExpr = [IFConstantExpression expressionWithPointNS:point];
  NSArray* newPoints = [IFConstantExpression expressionWithArray:[curPoints arrayByAddingObject:pointExpr]];
  IFOperatorExpression* newPaintExpr = [IFOperatorExpression expressionWithOperator:[IFOperator operatorForName:@"paint"]
                                                                           operands:[NSArray arrayWithObjects:brush,newPoints,nil]];
  IFOperatorExpression* newBlendExpr = [IFOperatorExpression expressionWithOperator:[IFOperator operatorForName:@"blend"]
                                                                           operands:[NSArray arrayWithObjects:
                                                                             [[curBlendExpr operands] objectAtIndex:0],
                                                                             newPaintExpr,
                                                                             [[curBlendExpr operands] objectAtIndex:2],
                                                                             nil]];
  [env setValue:newBlendExpr forKey:@"drawing"];
}

@end
