//
//  IFMapExpression.h
//  ImageFlow
//
//  Created by Michel Schinz on 26.09.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpression.h"

@interface IFMapExpression : IFExpression {
  IFExpression* function;
  IFExpression* array;
}

- (id)initWithFunction:(IFExpression*)theFunction array:(IFExpression*)theArray;

@property(readonly) IFExpression* function;
@property(readonly) IFExpression* array;

@end
