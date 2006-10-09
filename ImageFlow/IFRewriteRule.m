//
//  IFRewriteRule.m
//  ImageFlow
//
//  Created by Michel Schinz on 30.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFRewriteRule.h"
#import "IFExpressionMatcher.h"
#import "IFExpressionPlugger.h"
#import "IFDirectoryManager.h"

@implementation IFRewriteRule

static NSArray* allRules = nil;

+ (NSArray*)allRules;
{
  if (allRules == nil) {
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSString* rulesDir = [[IFDirectoryManager sharedDirectoryManager] rulesDirectory];
    NSArray* allFiles = (NSArray*)[[rulesDir collect] stringByAppendingPathComponent:[[fileMgr directoryContentsAtPath:rulesDir] each]];
    allRules = [(NSArray*)[[self collect] ruleWithXMLFile:[allFiles each]] retain];
  }
  return allRules;
}

+ (id)ruleWithPattern:(IFExpression*)thePattern result:(IFExpression*)theResult;
{
  return [[[self alloc] initWithPattern:thePattern result:theResult] autorelease];
}

- (id)initWithPattern:(IFExpression*)thePattern result:(IFExpression*)theResult;
{
  if (![super init])
    return nil;
  pattern = [thePattern retain];
  result = [theResult retain];
  return self;
}

- (void) dealloc;
{
  [result release];
  result = nil;
  [pattern release];
  pattern = nil;
  [super dealloc];
}

- (NSString*)description;
{
  return [NSString stringWithFormat:@"%@ => %@",pattern,result];
}

- (IFExpression*)rewriteExpression:(IFExpression*)expression;
{
  static IFExpressionMatcher* matcher = nil; // TODO not reentrent
  if (matcher == nil)
    matcher = [IFExpressionMatcher new];
  NSDictionary* matchingEnv = [matcher matchPattern:pattern withExpression:expression];
  return (matchingEnv == nil)
    ? expression
    : [IFExpressionPlugger plugValuesInExpression:result withValuesFromWildcardsEnvironment:matchingEnv];
}

#pragma mark XML input/output

+ (id)ruleWithXMLFile:(NSString*)xmlFile;
{
  NSError* outError = nil; // TODO handle errors
  NSXMLDocument* xmlDoc = [[[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:xmlFile] options:0 error:&outError] autorelease];
  NSAssert1(outError == nil, @"error: %@", outError);
  return [self ruleWithXML:[xmlDoc rootElement]];
}

+ (id)ruleWithXML:(NSXMLElement*)xmlTree;
{
  return [[[self alloc] initWithXML:xmlTree] autorelease];
}

- (id)initWithXML:(NSXMLElement*)xmlTree;
{
  return [self initWithPattern:[IFExpression expressionWithXML:(NSXMLElement*)[xmlTree childAtIndex:0]]
                        result:[IFExpression expressionWithXML:(NSXMLElement*)[xmlTree childAtIndex:1]]];
}

- (NSXMLElement*)asXML;
{
  return [NSXMLElement elementWithName:@"rule"
                              children:[NSArray arrayWithObjects:[pattern asXML],[result asXML],nil]
                            attributes:[NSArray array]];
}

@end
