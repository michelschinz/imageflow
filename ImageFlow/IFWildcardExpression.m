//
//  IFWildcardExpression.m
//  ImageFlow
//
//  Created by Michel Schinz on 30.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFWildcardExpression.h"
#import "IFExpressionVisitor.h"

@implementation IFWildcardExpression

+ (id)wildcardWithName:(NSString*)theName;
{
  return [[[self alloc] initWithName:theName] autorelease];
}

- (id)initWithName:(NSString*)theName;
{
  if (![super init])
    return nil;
  name = [theName copy];
  return self;
}

- (void) dealloc {
  OBJC_RELEASE(name);
  [super dealloc];
}

- (NSString*)description;
{
  return [@"?" stringByAppendingString:name];
}

- (NSString*)name;
{
  return name;
}

- (void)accept:(IFExpressionVisitor*)visitor;
{
  [visitor caseWildcardExpression:self];
}

- (unsigned)hash;
{
  return [name hash] * 7;
}

- (BOOL)isEqualAtRoot:(id)other;
{
  return [other isKindOfClass:[IFWildcardExpression class]] && [name isEqualToString:[other name]];  
}

#pragma mark XML input/output

- (id)initWithXML:(NSXMLElement*)xmlTree;
{
  return [self initWithName:[[xmlTree attributeForName:@"name"] stringValue]];
}

- (NSXMLElement*)asXML;
{
  NSXMLElement* elem = [NSXMLElement elementWithName:@"wildcard"];
  [elem addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:name]];
  return elem;
}

@end
