//
//  IFOperator.m
//  ImageFlow
//
//  Created by Michel Schinz on 18.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFOperator.h"
#import "IFXMLCoder.h"
#import "IFDirectoryManager.h"
#import "IFRewriteRule.h"

@interface IFOperator (Private)
+ (id)operatorWithXMLFile:(NSString*)xmlFile;
+ (id)operatorWithXML:(NSXMLElement*)xmlTree;
- (id)initWithName:(NSString*)theName;
@end

@implementation IFOperator

static NSArray* allOperators = nil;
static NSDictionary* allOperatorsByName;

+ (void)initialize;
{
  NSFileManager* fileMgr = [NSFileManager defaultManager];
  NSString* operatorsDir = [[IFDirectoryManager sharedDirectoryManager] operatorsDirectory];
  NSArray* allFiles = (NSArray*)[[operatorsDir collect] stringByAppendingPathComponent:[[fileMgr directoryContentsAtPath:operatorsDir] each]];
  allOperators = (NSArray*)[[self collect] operatorWithXMLFile:[allFiles each]];
  allOperatorsByName = [[NSDictionary dictionaryWithObjects:allOperators forKeys:(NSArray*)[[allOperators collect] name]] retain];
}

+ (IFOperator*)operatorForName:(NSString*)name;
{
  IFOperator* op = [allOperatorsByName objectForKey:name];
  NSAssert1(op != nil, @"unknown operator name: %@",name);
  return op;
}

- (id)copyWithZone:(NSZone *)zone;
{
  return [self retain];
}

- (NSString*)description;
{
  return name;
}

- (NSString*)name;
{
  return name;
}

@end

@implementation IFOperator (Private)

+ (id)operatorWithXMLFile:(NSString*)xmlFile;
{
  NSError* outError = nil; // TODO handle errors
  NSXMLDocument* xmlDoc = [[[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:xmlFile] options:0 error:&outError] autorelease];
  NSAssert1(outError == nil, @"error: %@", outError);
  return [self operatorWithXML:[xmlDoc rootElement]];
}

+ (id)operatorWithXML:(NSXMLElement*)xmlTree;
{
  NSString* name = @"";
  for (int i = 0; i < [xmlTree childCount]; ++i) {
    NSXMLNode* xmlChild = [xmlTree childAtIndex:i];
    NSString* xmlChildName = [xmlChild name];
    if ([xmlChildName isEqualToString:@"name"])
      name = [xmlChild stringValue];
    else
      NSLog(@"unknown XML element: %@",xmlChildName); // TODO
  }
  return [[[self alloc] initWithName:name] autorelease];
}

- (id)initWithName:(NSString*)theName;
{
  if (![super init])
    return nil;
  name = [theName copy];
  return self;
}

- (void) dealloc {
  [name release];
  name = nil;
  [super dealloc];
}

@end

