//
//  IFTreeNodeFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 22.09.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFTreeNodeFilter.h"

#import "IFFunType.h"
#import "IFTupleType.h"

@interface IFTreeNodeFilter ()
@property(retain) IFType* type;
@property(retain) NSArray* cachedTypes;
@property(retain) NSArray* cachedVectorizationInfo;
- (void)vectorizeTypes:(NSArray*)baseTypes into:(NSMutableArray*)vectorizedTypes puttingVectorizationInfoInto:(NSMutableArray*)vectorizationInfo;
- (IFType*)vectorizeType:(IFFunType*)baseType arrayArgumentsMask:(unsigned)arrayArgumentsMask;
- (IFExpression*)vectorizeExpression:(IFExpression*)lambdaExpression withArgumentExpressions:(NSArray*)arguments arrayArgumentsMask:(unsigned)arrayArgumentsMask;
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
  cachedTypes = nil;
  cachedVectorizationInfo = nil;
  cachedTypesArity = 0;

  [self startObservingSettingsKeys:[settings keys]];
  [settings addObserver:self forKeyPath:@"keys" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:IFSettingsKeySetDidChangeContext];

  return self;
}

- (void)dealloc;
{
  [settings removeObserver:self forKeyPath:@"keys"];
  [self stopObservingSettingsKeys:[settings keys]];

  OBJC_RELEASE(cachedVectorizationInfo);
  OBJC_RELEASE(cachedTypes);
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

@synthesize type;

- (NSArray*)potentialTypesForArity:(unsigned)arity;
{
  if (cachedTypes == nil || cachedTypesArity != arity) {
    NSArray* baseTypes = [self computePotentialTypesForArity:arity];
    NSMutableArray* vectorizedTypes = [NSMutableArray array];
    NSMutableArray* vectorizationInfo = [NSMutableArray array];
    [self vectorizeTypes:baseTypes into:vectorizedTypes puttingVectorizationInfoInto:vectorizationInfo];

    self.cachedTypes = [baseTypes arrayByAddingObjectsFromArray:vectorizedTypes];
    firstVectorizedTypeIndex = [baseTypes count];
    self.cachedVectorizationInfo = vectorizationInfo;
    cachedTypesArity = arity;
  }
  return cachedTypes;
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
  if (cachedTypes == nil || altActiveTypeIndex < firstVectorizedTypeIndex) {
    IFExpression* expr = [self rawExpressionForArity:arity typeIndex:altActiveTypeIndex];

    if (arity == 0) {
      return expr;
    } else if (arity == 1) {
      return [IFExpression applyWithFunction:expr argument:[altParentExpressions objectForKey:[NSNumber numberWithUnsignedInt:0]]];
    } else {
      NSMutableArray* parentExprs = [NSMutableArray arrayWithCapacity:arity];
      for (int i = 0; i < arity; ++i)
        [parentExprs addObject:[altParentExpressions objectForKey:[NSNumber numberWithInt:i]]];
      return [IFExpression applyWithFunction:expr argument:[IFExpression tupleCreate:parentExprs]];
    }
  } else {
    NSAssert(arity > 0, @"unexpected arity for vectorized expression");
    unsigned vInfo = [(NSNumber*)[cachedVectorizationInfo objectAtIndex:altActiveTypeIndex - firstVectorizedTypeIndex] unsignedIntValue];
    unsigned baseTypeIndex = vInfo >> 24;
    unsigned arrayArgumentsMask = vInfo & 0x00FFFFFF;
    IFExpression* baseExpr = [self rawExpressionForArity:arity typeIndex:baseTypeIndex];
    NSMutableArray* parentExprs = [NSMutableArray arrayWithCapacity:arity];
    for (int i = 0; i < arity; ++i)
      [parentExprs addObject:[altParentExpressions objectForKey:[NSNumber numberWithInt:i]]];
    return [self vectorizeExpression:baseExpr withArgumentExpressions:parentExprs arrayArgumentsMask:arrayArgumentsMask];
  }
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

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (void)clearPotentialTypesCache;
{
  self.cachedTypes = nil;
  cachedTypesArity = 0;
}

- (IFExpression*)rawExpressionForArity:(unsigned)arity typeIndex:(unsigned)typeIndex;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

// MARK: -
// MARK: PRIVATE

@synthesize cachedTypes, cachedVectorizationInfo;

- (void)vectorizeTypes:(NSArray*)baseTypes into:(NSMutableArray*)vectorizedTypes puttingVectorizationInfoInto:(NSMutableArray*)vectorizationInfo;
{
  for (unsigned i = 0; i < [baseTypes count]; ++i) {
    IFType* baseType = [baseTypes objectAtIndex:i];
    if (!baseType.isFunType)
      continue;

    for (unsigned arrayMask = 1; arrayMask < (1 << baseType.arity); ++arrayMask) {
      [vectorizedTypes addObject:[self vectorizeType:(IFFunType*)baseType arrayArgumentsMask:arrayMask]];
      const unsigned vInfo = (i << 24) | arrayMask;
      [vectorizationInfo addObject:[NSNumber numberWithUnsignedInt:vInfo]];
    }
  }
}

- (IFType*)vectorizeType:(IFFunType*)baseType arrayArgumentsMask:(unsigned)arrayArgumentsMask;
{
  NSAssert(arrayArgumentsMask > 0, @"invalid argument");
  if (baseType.arity == 1) {
    NSAssert(arrayArgumentsMask == 1, @"invalid argument");
    return [IFType funTypeWithArgumentType:[IFType arrayTypeWithContentType:baseType.argumentType] returnType:[IFType arrayTypeWithContentType:baseType.returnType]];
  } else {
    NSArray* baseArgumentTypes = ((IFTupleType*)((IFFunType*)baseType).argumentType).componentTypes;
    NSMutableArray* argumentTypes = [NSMutableArray arrayWithCapacity:baseArgumentTypes.count];
    for (IFType* baseArgumentType in baseArgumentTypes) {
      if (arrayArgumentsMask & 1)
        [argumentTypes addObject:[IFType arrayTypeWithContentType:baseArgumentType]];
      else
        [argumentTypes addObject:baseArgumentType];
      arrayArgumentsMask >>= 1;
    }
    return [IFType funTypeWithArgumentType:[IFType tupleTypeWithComponentTypes:argumentTypes] returnType:[IFType arrayTypeWithContentType:baseType.returnType]];
  }
}

- (IFExpression*)vectorizeExpression:(IFExpression*)lambdaExpression withArgumentExpressions:(NSArray*)arguments arrayArgumentsMask:(unsigned)arrayArgumentsMask;
{
  NSMutableArray* arrayArguments = [NSMutableArray arrayWithCapacity:[arguments count]];
  for (IFExpression* argument in arguments) {
    if (arrayArgumentsMask & 1)
      [arrayArguments addObject:argument];
    else
      [arrayArguments addObject:[IFExpression arrayCreate:[NSArray arrayWithObject:argument]]];
    arrayArgumentsMask >>= 1;
  }
  return [IFExpression mapWithFunction:lambdaExpression array:[IFExpression primitiveWithTag:IFPrimitiveTag_PZip operandsArray:arrayArguments]];
}

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
