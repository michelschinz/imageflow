//
//  IFAnnotationSourceEnvironment.m
//  ImageFlow
//
//  Created by Michel Schinz on 30.08.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFAnnotationSourceEnvironment.h"


@implementation IFAnnotationSourceEnvironment

static NSString* IFValueChangedContext = @"IFValueChangedContext";

+ (id)annotationSourceWithEnvironment:(IFEnvironment*)theEnvironment variableName:(NSString*)theVariableName;
{
  return [[[self alloc]initWithEnvironment:theEnvironment variableName:theVariableName] autorelease];
}

- (id)initWithEnvironment:(IFEnvironment*)theEnvironment variableName:(NSString*)theVariableName;
{
  if (![super init])
    return nil;
  environment = [theEnvironment retain];
  variableName = [theVariableName copy];
  
  [self setValue:[environment valueForKey:variableName]];
  [environment addObserver:self forKeyPath:variableName options:0 context:IFValueChangedContext];
  
  return self;
}

- (void)dealloc;
{
  [environment removeObserver:self forKeyPath:variableName];
  OBJC_RELEASE(environment);
  OBJC_RELEASE(variableName);
  [super dealloc];
}

- (void)updateValue:(id)newValue;
{
  [environment setValue:newValue forKey:variableName];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  [self setValue:[environment valueForKey:variableName]];
}

@end
