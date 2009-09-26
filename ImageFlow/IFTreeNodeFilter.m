//
//  IFTreeNodeFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 22.09.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFTreeNodeFilter.h"
#import "IFExpressionPlugger.h"

@interface IFTreeNodeFilter ()
@property(retain) IFType* type;
- (void)startObservingSettingsKeys:(NSSet*)keys;
- (void)stopObservingSettingsKeys:(NSSet*)keys;
@end

@implementation IFTreeNodeFilter

static NSString* IFSettingsKeySetDidChangeContext = @"IFSettingsKeySetDidChangeContext";
static NSString* IFSettingsValueDidChangeContext = @"IFSettingsValueDidChangeContext";

+ (id)nodeWithFilterNamed:(NSString*)theFilterName settings:(IFEnvironment*)theSettings;
{
  Class cls = [[NSBundle mainBundle] classNamed:theFilterName];
  NSAssert1(cls != nil, @"cannot find class for filter named '%@'", theFilterName);
  return [[[cls alloc] initWithSettings:theSettings] autorelease];
}

- (id)initWithSettings:(IFEnvironment*)theSettings;
{
  if (![super init])
    return nil;
  settings = [theSettings retain];
  activeTypeIndex = 0;
  parentExpressions = [[NSMutableDictionary dictionary] retain];
  expression = nil;
  settingsNib = nil;

  [self startObservingSettingsKeys:[settings keys]];
  [settings addObserver:self forKeyPath:@"keys" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:IFSettingsKeySetDidChangeContext];

  return self;
}

- (void)dealloc;
{
  [settings removeObserver:self forKeyPath:@"keys"];
  [self stopObservingSettingsKeys:[settings keys]];
  
  OBJC_RELEASE(settingsNib);
  OBJC_RELEASE(type);
  OBJC_RELEASE(expression);
  OBJC_RELEASE(parentExpressions);
  OBJC_RELEASE(settings);
  [super dealloc];
}

- (IFEnvironment*)settings;
{
  return settings;
}

- (void)setParentExpression:(IFExpression*)parentExpression atIndex:(unsigned)index;
{
  [parentExpressions setObject:parentExpression forKey:[NSNumber numberWithUnsignedInt:index]];
  [self updateExpression];
}

- (void)setParentExpressions:(NSDictionary*)expressions activeTypeIndex:(unsigned)newActiveTypeIndex type:(IFType*)newType;
{
  [parentExpressions setDictionary:expressions];
  activeTypeIndex = newActiveTypeIndex;
  self.type = newType;
  [self updateExpression];
}

- (IFExpression*)expressionForSettings:(IFEnvironment*)altSettings parentExpressions:(NSDictionary*)altParentExpressions activeTypeIndex:(unsigned)altActiveTypeIndex;
{
  const unsigned arity = [altParentExpressions count];
  IFExpression* expr = [IFExpressionPlugger plugValuesInExpression:[[self potentialRawExpressionsForArity:arity] objectAtIndex:altActiveTypeIndex] withValuesFromVariablesEnvironment:[altSettings asDictionary]];
  for (unsigned i = 0; i < arity; ++i) {
    IFExpression* parentExpr = [altParentExpressions objectForKey:[NSNumber numberWithUnsignedInt:i]];
    expr = [IFExpression applyWithFunction:expr argument:parentExpr];
  }
  return expr;
}

- (IFExpression*)computeExpression;
{
  return [self expressionForSettings:settings parentExpressions:parentExpressions activeTypeIndex:activeTypeIndex];
}

// MARK: Filter settings view support

- (NSArray*)instantiateSettingsNibWithOwner:(NSObject*)owner;
{
  if (settingsNib == nil) {
    settingsNib = [[NSNib alloc] initWithNibNamed:[self className] bundle:nil];
    if (settingsNib == nil)
      return nil; // Nib file does not exist
  }
  
  NSArray* topLevelObjects = nil;
  BOOL nibOk = [settingsNib instantiateNibWithOwner:owner topLevelObjects:&topLevelObjects];
  NSAssert1(nibOk, @"error during nib instantiation %@", settingsNib);
  
  return topLevelObjects;
}

// MARK: Tree view support

- (NSString*)nameOfParentAtIndex:(int)index;
{
  return [NSString stringWithFormat:@"parent %d",index];
}

- (NSString*)toolTip;
{
  return [self label];
}

// MARK: Image view support

- (NSArray*)editingAnnotationsForView:(NSView*)view;
{
  return [NSArray array];
}

- (void)mouseDown:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
{
  // do nothing by default
}

- (void)mouseDragged:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
{
  // do nothing by default
}

- (void)mouseUp:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
{
  // do nothing by default
}

- (NSArray*)variantNamesForViewing;
{
  return [NSArray arrayWithObject:@""];
}

- (NSArray*)variantNamesForEditing;
{
  return [NSArray arrayWithObject:@""];  
}

- (IFExpression*)variantNamed:(NSString*)variantName ofExpression:(IFExpression*)originalExpression;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (NSAffineTransform*)transformForParentAtIndex:(int)index;
{
  return [NSAffineTransform transform];
}

// MARK: NSCoding protocol

- (id)initWithCoder:(NSCoder*)decoder;
{
  [super initWithCoder:decoder];
  settings = [[decoder decodeObjectForKey:@"settings"] retain];
  activeTypeIndex = 0;
  parentExpressions = [[NSMutableDictionary dictionary] retain];
  settingsNib = nil;
  
  [self startObservingSettingsKeys:[settings keys]];
  [settings addObserver:self forKeyPath:@"keys" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:IFSettingsKeySetDidChangeContext];

  return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder;
{
  [super encodeWithCoder:encoder];
  [encoder encodeObject:settings forKey:@"settings"];
}

// MARK: Debugging

- (NSString*)description;
{
  return [self label];
}

// MARK: -
// MARK: PROTECTED

- (NSArray*)potentialRawExpressionsForArity:(unsigned)arity;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  if (context == IFSettingsKeySetDidChangeContext) {
    NSSet* oldKeys = [change objectForKey:NSKeyValueChangeOldKey];
    NSSet* newKeys = [change objectForKey:NSKeyValueChangeNewKey];
    int changeKind = [(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue];
    switch (changeKind) {
      case NSKeyValueChangeInsertion:
        [self startObservingSettingsKeys:newKeys];
        break;
      case NSKeyValueChangeRemoval:
        [self stopObservingSettingsKeys:oldKeys];
        break;
      default:
        NSAssert(NO, @"unexpected change kind");
        break;
    }
  } else if (context == IFSettingsValueDidChangeContext) {
    [self updateLabel];
    [self updateExpression];
    [self clearPotentialTypesCache];
  } else
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

// MARK: -
// MARK: PRIVATE

@synthesize type;

- (void)startObservingSettingsKeys:(NSSet*)keys;
{
  for (NSString* key in keys)
    [settings addObserver:self forKeyPath:key options:0 context:IFSettingsValueDidChangeContext];
}

- (void)stopObservingSettingsKeys:(NSSet*)keys;
{
  for (NSString* key in keys)
    [settings removeObserver:self forKeyPath:key];
}

@end
