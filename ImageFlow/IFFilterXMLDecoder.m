//
//  IFFilterXMLDecoder.m
//  ImageFlow
//
//  Created by Michel Schinz on 16.01.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFFilterXMLDecoder.h"
#import "IFXMLCoder.h"

@implementation IFFilterXMLDecoder

+ (id)decoder;
{
  return [[[self alloc] init] autorelease];
}

- (IFFilter*)filterWithXMLFile:(NSString*)xmlFile;
{
  NSError* outError = nil; // TODO handle errors
  NSXMLDocument* xmlDoc = [[[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:xmlFile] options:0 error:&outError] autorelease];
  NSAssert1(outError == nil, @"error: %@", outError);
  return [self filterWithXML:[xmlDoc rootElement]];
}

- (IFFilter*)filterWithXML:(NSXMLElement*)xmlTree;
{
  NSString* name = nil;
  IFExpression* expression = nil;
  int minParents = 0, maxParents = 0, minChildren = 0, maxChildren = 1;
  NSString* settingsNibName = nil;
  id delegate = nil;

  IFXMLCoder* xmlCoder = [IFXMLCoder sharedCoder];
  for (int i = 0; i < [xmlTree childCount]; ++i) {
    NSXMLNode* child = [xmlTree childAtIndex:i];
    NSString* childName = [child name];
    if ([childName isEqualToString:@"name"])
      name = [child stringValue];
    else if ([childName isEqualToString:@"expression"])
      expression = [IFExpression expressionWithXML:(NSXMLElement*)[child childAtIndex:0]];
    else if ([childName isEqualToString:@"min_parents"])
      minParents = [(NSNumber*)[xmlCoder decodeString:[child stringValue] type:IFXMLDataTypeNumber] intValue];
    else if ([childName isEqualToString:@"max_parents"])
      maxParents = [(NSNumber*)[xmlCoder decodeString:[child stringValue] type:IFXMLDataTypeNumber] intValue];
    else if ([childName isEqualToString:@"min_children"])
      minChildren = [(NSNumber*)[xmlCoder decodeString:[child stringValue] type:IFXMLDataTypeNumber] intValue];
    else if ([childName isEqualToString:@"max_children"])
      maxChildren = [(NSNumber*)[xmlCoder decodeString:[child stringValue] type:IFXMLDataTypeNumber] intValue];
    else if ([childName isEqualToString:@"settings_nib"])
      settingsNibName = [child stringValue];
    else if ([childName isEqualToString:@"delegate_class"])
      delegate = [[[NSBundle mainBundle] classNamed:[child stringValue]] new];
    else
      NSLog(@"unknown child: %@",childName);
  }

  return [IFFilter filterWithName:name
                       expression:expression
                     parentsArity:NSMakeRange(minParents, maxParents - minParents + 1)
                       childArity:NSMakeRange(minChildren, maxChildren - minChildren + 1)
                  settingsNibName:settingsNibName
                         delegate:delegate];
}

@end
