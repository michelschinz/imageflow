//
//  IFVariableKVO.m
//  ImageFlow
//
//  Created by Michel Schinz on 07.12.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFVariableKVO.h"


@implementation IFVariableKVO

static NSString* IFValueChangedContext = @"IFValueChangedContext";

+ (id)variableWithKVOCompliantObject:(NSObject*)theObject key:(NSString*)theKey;
{
  return [[[self alloc] initWithKVOCompliantObject:theObject key:theKey] autorelease];
}

- (id)initWithKVOCompliantObject:(NSObject*)theObject key:(NSString*)theKey;
{
  if (![super init])
    return nil;
  object = [theObject retain];
  key = [theKey retain];
  
  [super setValue:[object valueForKey:key]];
  [object addObserver:self forKeyPath:key options:0 context:IFValueChangedContext];
  
  return self;
}

- (void)dealloc;
{
  [object removeObserver:self forKeyPath:key];
  OBJC_RELEASE(key);
  OBJC_RELEASE(object);
  [super dealloc];
}

- (void)setValue:(id)newValue;
{
  // only forward request to object, but do not notify observers (this will be done only when the object changes its own value)
  [object setValue:newValue forKey:key];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)obj change:(NSDictionary*)change context:(void*)context;
{
  NSAssert(context == IFValueChangedContext, @"internal error");
  [super setValue:[object valueForKey:key]];
}

@end
