//
//  IFExpression.h
//  ImageFlow
//
//  Created by Michel Schinz on 18.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <caml/mlvalues.h>

#import "IFOperator.h"
#import "IFEnvironment.h"

@class IFExpressionVisitor;

@interface IFExpression : NSObject<NSCopying> {
  BOOL camlRepresentationIsValid;
  value camlRepresentation;
}

- (void)accept:(IFExpressionVisitor*)visitor;

- (NSUInteger)hash;
- (BOOL)isEqualAtRoot:(id)other;
- (BOOL)isEqual:(id)other;

+ (id)expressionWithXML:(NSXMLElement*)xmlTree;
- (NSXMLElement*)asXML;

- (value)asCaml;

// MARK: -
// MARK: PROTECTED

- (id)initWithXML:(NSXMLElement*)xml;
- (value)camlRepresentation;

@end
