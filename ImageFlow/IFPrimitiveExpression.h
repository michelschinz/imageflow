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
  IFPrimitiveTag primitiveTag;
  NSArray* operands;
  NSUInteger hash;
}

- (id)initWithTag:(IFPrimitiveTag)theTag operands:(NSArray*)theOperands;
- (id)initWithXML:(NSXMLElement*)xmlTree;

@property(readonly) IFPrimitiveTag primitiveTag;
@property(readonly) NSString* name;
@property(readonly) NSArray* operands;

@end
