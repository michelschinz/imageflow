//
//  IFRewriteRule.h
//  ImageFlow
//
//  Created by Michel Schinz on 30.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpression.h"

@interface IFRewriteRule : NSObject {
  IFExpression* pattern;
  IFExpression* result;
}

+ (NSArray*)allRules;

+ (id)ruleWithPattern:(IFExpression*)thePattern result:(IFExpression*)theResult;
- (id)initWithPattern:(IFExpression*)thePattern result:(IFExpression*)theResult;

- (IFExpression*)rewriteExpression:(IFExpression*)expression;

+ (id)ruleWithXMLFile:(NSString*)xmlFile;
+ (id)ruleWithXML:(NSXMLElement*)xmlTree;
- (id)initWithXML:(NSXMLElement*)xmlTree;
- (NSXMLElement*)asXML;

@end
