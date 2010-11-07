//
//  IFExpressionContentsLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 30.08.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import "IFExpressionContentsLayer.h"


@implementation IFExpressionContentsLayer

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString*)key;
{
  if ([key isEqualToString:@"expression"] || [key isEqualToString:@"reversedPath"])
    return YES;
  else
    return [super automaticallyNotifiesObserversForKey:key];
}

- (IFExpressionContentsLayer*)initWithLayoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
{
  if (![super init])
    return nil;
  layoutParameters = [theLayoutParameters retain];
  canvasBoundsVar = [theCanvasBoundsVar retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(expression);
  OBJC_RELEASE(reversedPath);

  OBJC_RELEASE(canvasBoundsVar);
  OBJC_RELEASE(layoutParameters);
  [super dealloc];
}

@synthesize expression, reversedPath;

- (NSArray*)thumbnailLayers;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

@end
