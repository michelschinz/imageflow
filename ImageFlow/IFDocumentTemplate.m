//
//  IFDocumentTemplate.m
//  ImageFlow
//
//  Created by Michel Schinz on 14.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFDocumentTemplate.h"
#import "IFOperatorExpression.h"
#import "IFDocumentXMLDecoder.h"

@interface IFDocumentTemplate (Private)
- (void)extractTemplateNodesFor:(IFTreeNode*)root into:(NSMutableSet*)result;
- (void)load;
@end

@implementation IFDocumentTemplate

+ (id)templateWithFileName:(NSString*)theFileName;
{
  return [[[self alloc] initWithFileName:theFileName] autorelease];
}

- (id)initWithFileName:(NSString*)theFileName;
{
  if (![super init])
    return nil;
  fileName = [theFileName copy];
  isLoaded = NO;
  name = nil;
  comment = nil;
  node = nil;
  return self;
}

- (void) dealloc;
{
  OBJC_RELEASE(node);
  OBJC_RELEASE(comment);
  OBJC_RELEASE(name);
  OBJC_RELEASE(fileName);
  [super dealloc];
}

- (NSString*)fileName;
{
  return fileName;
}

- (NSString*)name;
{
  if (!isLoaded)
    [self load];
  return name;
}

- (NSString*)comment;
{
  if (!isLoaded)
    [self load];
  return comment;
}

- (IFTreeNode*)node;
{
  if (!isLoaded)
    [self load];
  return node;
}

- (BOOL)nodeRequiresInlining;
{
  return nodeRequiresInlining;
}

@end

@implementation IFDocumentTemplate (Private)

- (void)extractTemplateNodesFor:(IFTreeNode*)root into:(NSMutableSet*)result;
{
  if ([root isGhost])
    return;
  [result addObject:root];
  [[self do] extractTemplateNodesFor:[[root parents] each] into:result];
}

- (void)load;
{
  NSAssert(!isLoaded, @"template already loaded");

  NSError* outError = nil; // TODO handle errors
  NSXMLDocument* xmlDoc = [[NSXMLDocument alloc] initWithData:[NSData dataWithContentsOfFile:fileName]
                                                      options:NSXMLDocumentTidyXML
                                                        error:&outError];
  NSAssert1(outError == nil, @"error reading XML file: %@", outError);
  
  IFDocumentXMLDecoder* decoder = [IFDocumentXMLDecoder decoder];
  IFDocument* document = [decoder documentFromXML:xmlDoc];
  name = [[document title] copy];
  comment = [[document documentDescription] copy];
  
  NSArray* roots = [document roots];
  IFTreeNode* root;
  do {
    // TODO check if more than one root exist, and act accordingly
    root = [roots count] > 0 ? [roots objectAtIndex:0] : nil;
    roots = [root parents];
  } while (root != nil && [root isGhost]);

  if (root == nil)
    node = nil;
  else {
    NSMutableSet* nodes = [NSMutableSet new];
    [self extractTemplateNodesFor:root into:nodes];
    NSAssert([nodes count] == 1, @"cannot make templates of more than one node (TODO)");
    node = [nodes anyObject];
  }

  isLoaded = YES;
}

@end
