//
//  IFPrimitiveExpression.h
//  ImageFlow
//
//  Created by Michel Schinz on 25.09.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpression.h"
#import "IFExpressionTags.h"

@interface IFPrimitiveExpression : IFExpression {
  IFPrimitiveTag tag;
  NSArray* operands;
  NSUInteger hash;
}

- (id)initWithTag:(IFPrimitiveTag)theTag operands:(NSArray*)theOperands;

@property(readonly) IFPrimitiveTag tag;
@property(readonly) NSString* name;
@property(readonly) NSArray* operands;

@end
