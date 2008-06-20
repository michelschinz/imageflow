//
//  IFEnvironment.m
//  ImageFlow
//
//  Created by Michel Schinz on 19.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFEnvironment.h"
#import "IFExpression.h"
#import "IFConstantExpression.h"
#import "IFXMLCoder.h"

@interface IFEnvironment (Private)
- (id)initWithContentsOfDictionary:(NSDictionary*)dict;
@end

@implementation IFEnvironment

+ (id)environment;
{
  return [[[self alloc] init] autorelease];
}

- (id)init;
{
  return [self initWithContentsOfDictionary:[NSDictionary dictionary]];
}

- (void)dealloc;
{
  OBJC_RELEASE(env);
  [super dealloc];
}

- (NSString*)description;
{
  return [env description];
}

- (void)setValue:(id)value forKey:(NSString*)key field:(NSString*)field;
{
  NSValue* currValue = [env objectForKey:key];
  NSAssert2(currValue != nil, @"no current value for key '%@' (field '%@'",key,field);

  if (strcmp([currValue objCType],@encode(NSRect)) == 0) {
    NSRect newRect = [currValue rectValue];
    float newValue = [value floatValue];
    if ([field isEqualToString:@"originX"])
      newRect.origin.x = newValue;
    else if ([field isEqualToString:@"originY"])
      newRect.origin.y = newValue;
    else if ([field isEqualToString:@"width"])
      newRect.size.width = newValue;
    else if ([field isEqualToString:@"height"])
      newRect.size.height = newValue;
    else
      NSAssert1(NO, @"invalid field name '%@' for NSRect",field);
    [self setValue:[NSValue valueWithRect:newRect] forKey:key];
  } else if (strcmp([currValue objCType],@encode(NSPoint)) == 0) {
    NSPoint newPoint = [currValue pointValue];
    float newValue = [value floatValue];
    if ([field isEqualToString:@"x"])
      newPoint.x = newValue;
    else if ([field isEqualToString:@"y"])
      newPoint.y = newValue;
    else
      NSAssert1(NO, @"invalid field name '%@' for NSPoint",field);
    [self setValue:[NSValue valueWithPoint:newPoint] forKey:key];
  } else
    NSAssert1(NO, @"unknown type %@",[currValue objCType]);
}

- (void)setValue:(id)value forKey:(NSString*)key;
{
  NSRange suffixRange = [key rangeOfString:@"@"];
  if (suffixRange.location != NSNotFound) {
    NSArray* components = [key componentsSeparatedByString:@"@"];
    NSAssert1([components count] == 2, @"too many '@' in key '%@'", key);
    [self setValue:value forKey:[components objectAtIndex:0] field:[components objectAtIndex:1]];
    return;
  }
  
  [self willChangeValueForKey:key];
  BOOL containsKey = ([env objectForKey:key] != nil);
  if (value == nil) {
    if (containsKey) {
      [self willChangeValueForKey:@"keys" withSetMutation:NSKeyValueMinusSetMutation usingObjects:[NSSet setWithObject:key]];
      [env removeObjectForKey:key];
      [self didChangeValueForKey:@"keys" withSetMutation:NSKeyValueMinusSetMutation usingObjects:[NSSet setWithObject:key]];
    }
  } else {
    if (!containsKey)
      [self willChangeValueForKey:@"keys" withSetMutation:NSKeyValueUnionSetMutation usingObjects:[NSSet setWithObject:key]];
    NSMutableArray* dependentKeys = [NSMutableArray array];
    if ([value isKindOfClass:[NSValue class]]) {
      if (strcmp([value objCType],@encode(NSRect)) == 0) {
        NSRect oldValue = [[env valueForKey:key] rectValue];
        NSRect newValue = [value rectValue];
        if (NSMinX(oldValue) != NSMinX(newValue)) [dependentKeys addObject:[key stringByAppendingString:@"@originX"]];
        if (NSMinY(oldValue) != NSMinY(newValue)) [dependentKeys addObject:[key stringByAppendingString:@"@originY"]];
        if (NSWidth(oldValue) != NSWidth(newValue)) [dependentKeys addObject:[key stringByAppendingString:@"@width"]];
        if (NSHeight(oldValue) != NSHeight(newValue)) [dependentKeys addObject:[key stringByAppendingString:@"@height"]];
      } else if (strcmp([value objCType],@encode(NSPoint)) == 0) {
        NSPoint oldValue = [[env valueForKey:key] pointValue];
        NSPoint newValue = [value pointValue];
        if (oldValue.x != newValue.x) [dependentKeys addObject:[key stringByAppendingString:@"@x"]];
        if (oldValue.y != newValue.y) [dependentKeys addObject:[key stringByAppendingString:@"@y"]];
      }
    }
    [[self do] willChangeValueForKey:[dependentKeys each]];
    [env setObject:value forKey:key];
    [[self do] didChangeValueForKey:[dependentKeys each]];
    if (!containsKey)
      [self didChangeValueForKey:@"keys" withSetMutation:NSKeyValueUnionSetMutation usingObjects:[NSSet setWithObject:key]];
  }
  [self didChangeValueForKey:key];
}

- (id)valueForKey:(NSString*)key;
{
  NSRange suffixRange = [key rangeOfString:@"@"];
  if (suffixRange.location == NSNotFound)
    return [env objectForKey:key];
  else {
    NSArray* components = [key componentsSeparatedByString:@"@"];
    NSAssert1([components count] == 2, @"too many '@' in key '%@'", key);
    NSValue* value = [env objectForKey:[components objectAtIndex:0]];
    NSString* field = [components objectAtIndex:1];
    if ([field isEqualToString:@"originX"])
      return [NSNumber numberWithFloat:NSMinX([value rectValue])];
    else if ([field isEqualToString:@"originY"])
      return [NSNumber numberWithFloat:NSMinY([value rectValue])];
    else if ([field isEqualToString:@"width"])
      return [NSNumber numberWithFloat:NSWidth([value rectValue])];
    else if ([field isEqualToString:@"height"])
      return [NSNumber numberWithFloat:NSHeight([value rectValue])];
    else if ([field isEqualToString:@"x"])
      return [NSNumber numberWithFloat:[value pointValue].x];
    else if ([field isEqualToString:@"y"])
      return [NSNumber numberWithFloat:[value pointValue].y];    
    else {
      NSAssert1(NO, @"unknown field '%@'",field);
      return nil;
    }
  }
}

- (NSSet*)keys;
{
  return [NSSet setWithArray:[env allKeys]];
}

- (void)removeValueForKey:(NSString*)key;
{
  [env removeObjectForKey:key];
}

- (NSDictionary*)asDictionary;
{
  return env;
}

#pragma mark NSCoding protocol

- (id)initWithCoder:(NSCoder*)decoder;
{
  NSMutableDictionary* combinedDict = [NSMutableDictionary dictionary];
  [combinedDict addEntriesFromDictionary:[decoder decodeObjectForKey:@"generalDictionary"]];

  NSDictionary* rectsDict = [decoder decodeObjectForKey:@"rectsDictionary"];
  for (NSString* key in rectsDict)
    [combinedDict setObject:[NSValue valueWithRect:NSRectFromString([rectsDict objectForKey:key])] forKey:key];
  
  NSDictionary* pointsDict = [decoder decodeObjectForKey:@"pointsDictionary"];
  for (NSString* key in pointsDict)
    [combinedDict setObject:[NSValue valueWithPoint:NSPointFromString([pointsDict objectForKey:key])] forKey:key];

  return [self initWithContentsOfDictionary:combinedDict];
}

- (void)encodeWithCoder:(NSCoder*)encoder;
{
  NSMutableDictionary* generalDict = [NSMutableDictionary dictionary];
  NSMutableDictionary* rectsDict = [NSMutableDictionary dictionary];
  NSMutableDictionary* pointsDict = [NSMutableDictionary dictionary];

  for (NSString* key in [env keyEnumerator]) {
    id value = [env valueForKey:key];
    if ([value isKindOfClass:[NSValue class]] && ![value isKindOfClass:[NSNumber class]]) {
      const char* type = [value objCType];
      if (strcmp(type, @encode(NSPoint)) == 0)
        [pointsDict setObject:NSStringFromPoint([value pointValue]) forKey:key];
      else if (strcmp(type, @encode(NSRect)) == 0) {
        [rectsDict setObject:NSStringFromRect([value rectValue]) forKey:key];
      } else
        NSAssert1(NO, @"unexpected type during archival: %s", type);
    } else
      [generalDict setObject:value forKey:key];
  }
  [encoder encodeObject:generalDict forKey:@"generalDictionary"];
  [encoder encodeObject:rectsDict forKey:@"rectsDictionary"];
  [encoder encodeObject:pointsDict forKey:@"pointsDictionary"];
}

@end

@implementation IFEnvironment (Private)

- (id)initWithContentsOfDictionary:(NSDictionary*)dict;
{
  if (![super init])
    return nil;
  env = [[NSMutableDictionary dictionaryWithDictionary:dict] retain];
  return self;
}

@end

