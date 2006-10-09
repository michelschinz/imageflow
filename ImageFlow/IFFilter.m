//
//  IFFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 22.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFFilter.h"
#import "IFDirectoryManager.h"
#import "IFExpressionPlugger.h"
#import "IFFilterXMLDecoder.h"

@implementation IFFilter

typedef enum {
  IFDelegateHasLabelWithEnvironment   = (1 << 0),
  IFDelegateHasToolTipWithEnvironment = (1 << 1),
  IFDelegateSupportsExportation       = (1 << 2),
  IFDelegateHasEditingAnnotations     = (1 << 3),
  IFDelegateHasVariantNamesForViewing = (1 << 4),
  IFDelegateHasVariantNamesForEditing = (1 << 5),
} IFFilterDelegateCapabilities;

static NSArray* allFilters = nil;
static NSDictionary* allFiltersByName;

+ (void)initialize;
{
  NSFileManager* fileMgr = [NSFileManager defaultManager];
  NSString* filtersDir = [[IFDirectoryManager sharedDirectoryManager] filtersDirectory];
  NSArray* allFiles = (NSArray*)[[filtersDir collect] stringByAppendingPathComponent:[[fileMgr directoryContentsAtPath:filtersDir] each]];
  IFFilterXMLDecoder* decoder = [IFFilterXMLDecoder decoder];
  allFilters = [(NSArray*)[[decoder collect] filterWithXMLFile:[allFiles each]] retain];
  allFiltersByName = [[NSDictionary dictionaryWithObjects:allFilters forKeys:(NSArray*)[[allFilters collect] name]] retain];
}

+ (IFFilter*)filterForName:(NSString*)name;
{
  IFFilter* filter = [allFiltersByName objectForKey:name];
  NSAssert1(filter != nil, @"unknown filter name: %@",name); // TODO error handling
  return filter;
}

+ (id)filterWithName:(NSString*)theName
          expression:(IFExpression*)theExpression
        parentsArity:(NSRange)theParentsRange
          childArity:(NSRange)theChildRange
     settingsNibName:(NSString*)theSettingsNibName
            delegate:(NSObject<IFFilterDelegate>*)theDelegate;
{
  return [[[self alloc] initWithName:theName expression:theExpression parentsArity:theParentsRange childArity:theChildRange settingsNibName:theSettingsNibName delegate:theDelegate] autorelease];
}  

- (id)initWithName:(NSString*)theName
        expression:(IFExpression*)theExpression
      parentsArity:(NSRange)theParentsRange
        childArity:(NSRange)theChildRange
   settingsNibName:(NSString*)theSettingsNibName
          delegate:(NSObject<IFFilterDelegate>*)theDelegate;
{
  if (![super init])
    return nil;
  name = [theName copy];
  expression = [theExpression retain];
  parentsRange = theParentsRange;
  childRange = theChildRange;
  settingsNibName = [theSettingsNibName copy];
  
  delegate = theDelegate; // do not retain
  delegateCapabilities = 0
    | ([delegate respondsToSelector:@selector(labelWithEnvironment:)] ? IFDelegateHasLabelWithEnvironment : 0)
    | ([delegate respondsToSelector:@selector(toolTipWithEnvironment:)] ? IFDelegateHasToolTipWithEnvironment : 0)
    | ([delegate respondsToSelector:@selector(exporterKind:)] ? IFDelegateSupportsExportation : 0)
    | ([delegate respondsToSelector:@selector(editingAnnotationsForNode:view:)] ? IFDelegateHasEditingAnnotations : 0)
    | ([delegate respondsToSelector:@selector(variantNamesForViewing)] ? IFDelegateHasVariantNamesForViewing : 0)
    | ([delegate respondsToSelector:@selector(variantNamesForEditing)] ? IFDelegateHasVariantNamesForEditing : 0);

  return self;
}

- (void)dealloc;
{
  [delegate release];
  delegate = nil;
  [settingsNib release];
  settingsNib = nil;
  [settingsNibName release];
  settingsNibName = nil;
  [expression release];
  expression = nil;
  [name release];
  name = nil;
  [super dealloc];
}

- (NSString*)name;
{
  return name;
}

- (NSObject<IFFilterDelegate>*)delegate;
{
  return delegate;
}

- (BOOL)isGhost;
{
  return [expression isKindOfClass:[IFOperatorExpression class]] && ([expression operator] == [IFOperator operatorForName:@"nop"]);
}

- (BOOL)acceptsParents:(int)parentsCount;
{
  return NSLocationInRange(parentsCount,parentsRange);
}

- (BOOL)acceptsChildren:(int)childrenCount;
{
  return NSLocationInRange(childrenCount,childRange);
}

- (BOOL)hasSettingsNib;
{
  return settingsNibName != nil;
}

- (NSArray*)instantiateSettingsNibWithOwner:(NSObject*)owner;
{
  if (settingsNibName == nil)
    return nil;

  if (settingsNib == nil)
    settingsNib = [[NSNib alloc] initWithNibNamed:settingsNibName bundle:nil];
  
  NSArray* topLevelObjects = nil;
  BOOL nibOk = [settingsNib instantiateNibWithOwner:owner topLevelObjects:&topLevelObjects];
  NSAssert1(nibOk, @"error during nib instantiation %@", settingsNib);
  
  return topLevelObjects;
}

- (NSString*)nameOfParentAtIndex:(int)index;
{
  return delegate != nil ? [delegate nameOfParentAtIndex:index] : [NSString stringWithFormat:@"parent %d",index];
}

- (NSString*)labelWithEnvironment:(IFEnvironment*)environment;
{
  return (delegateCapabilities & IFDelegateHasLabelWithEnvironment) ? [delegate labelWithEnvironment:environment] : name;
}

- (NSString*)toolTipWithEnvironment:(IFEnvironment*)environment;
{
  return (delegateCapabilities & IFDelegateHasToolTipWithEnvironment)
  ? [delegate toolTipWithEnvironment:environment]
  : [self labelWithEnvironment:environment];
}

- (NSArray*)editingAnnotationsForNode:(IFTreeNode*)node view:(NSView*)view;
{
  return (delegateCapabilities & IFDelegateHasEditingAnnotations)
  ? [delegate editingAnnotationsForNode:node view:view]
  : [NSArray array];
}

- (NSArray*)variantNamesForViewing;
{
  return (delegateCapabilities & IFDelegateHasVariantNamesForViewing)
  ? [delegate variantNamesForViewing]
  : [NSArray arrayWithObject:@""];
}

- (NSArray*)variantNamesForEditing;
{
  return (delegateCapabilities & IFDelegateHasVariantNamesForEditing)
  ? [delegate variantNamesForEditing]
  : [NSArray arrayWithObject:@""];  
}

- (IFExpression*)variantNamed:(NSString*)variantName ofExpression:(IFExpression*)originalExpression;
{
  NSAssert([delegate respondsToSelector:@selector(variantNamed:ofExpression:)], @"invalid delegate");
  return [delegate variantNamed:variantName ofExpression:originalExpression];
}

- (NSAffineTransform*)transformForParentAtIndex:(int)index withEnvironment:(IFEnvironment*)env;
{
  return [delegate transformForParentAtIndex:index withEnvironment:env];
}

- (NSString*)exporterKind;
{
  return (delegateCapabilities & IFDelegateSupportsExportation) ? [delegate exporterKind] : nil;
}

- (void)exportImage:(IFImageConstantExpression*)imageExpr environment:(IFEnvironment*)environment document:(IFDocument*)document;
{
  NSAssert(delegateCapabilities & IFDelegateSupportsExportation, @"delegate doesn't support exportation");
  [delegate exportImage:imageExpr environment:environment document:document];
}

- (IFExpression*)expression;
{
  return expression;
}

- (IFExpression*)expressionWithEnvironment:(IFEnvironment*)environment;
{
  return [IFExpressionPlugger plugValuesInExpression:expression withValuesFromVariablesEnvironment:[environment asDictionary]];
}

@end
