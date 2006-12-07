//
//  IFRectIVarController.m
//  ImageFlow
//
//  Created by Michel Schinz on 07.12.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFRectIVarController.h"
#import "IFUtilities.h"

@interface IFRectIVarController (Private)
- (void)updateRect;
@end

@implementation IFRectIVarController

static NSString* IFRectDidChangeContext = @"IFRectDidChangeContext";

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString*)key;
{
  return !([key isEqualToString:@"originX"]
           || [key isEqualToString:@"originY"]
           || [key isEqualToString:@"width"]
           || [key isEqualToString:@"height"]);
}

- (void)dealloc;
{
  [self setObject:nil andKey:nil];
  [super dealloc];
}

- (void)setObject:(NSObject*)newObject andKey:(NSString*)newKey;
{
  if (object != nil) {
    NSAssert(key != nil, @"internal error");
    [object removeObserver:self forKeyPath:key];
    OBJC_RELEASE(object);
    OBJC_RELEASE(key);
  }
  if (newObject != nil) {
    NSAssert(newKey != nil, @"internal error");
    object = [newObject retain];
    key = [newKey retain];
    [object addObserver:self forKeyPath:key options:0 context:IFRectDidChangeContext];
    [self updateRect];
  } else
    rect = NSZeroRect;
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)obj change:(NSDictionary*)change context:(void*)context;
{
  NSAssert(context == IFRectDidChangeContext, @"internal error");
  [self updateRect];
}

- (float)originX;
{
  return rect.origin.x;
}

- (void)setOriginX:(float)newOriginX;
{
  NSRect newRect = rect;
  newRect.origin.x = newOriginX;
  [object setValue:[NSValue valueWithRect:newRect] forKey:key];
}

- (float)originY;
{
  return rect.origin.y;
}

- (void)setOriginY:(float)newOriginY;
{
  NSRect newRect = rect;
  newRect.origin.y = newOriginY;
  [object setValue:[NSValue valueWithRect:newRect] forKey:key];
}

- (float)width;
{
  return rect.size.width;
}

- (void)setWidth:(float)newWidth;
{
  NSRect newRect = rect;
  newRect.size.width = newWidth;
  [object setValue:[NSValue valueWithRect:newRect] forKey:key];
}

- (float)height;
{
  return rect.size.height;
}

- (void)setHeight:(float)newHeight;
{
  NSRect newRect = rect;
  newRect.size.height = newHeight;
  [object setValue:[NSValue valueWithRect:newRect] forKey:key];
}

@end

@implementation IFRectIVarController (Private)

- (void)updateRect;
{
  NSRect newRect = [[object valueForKey:key] rectValue];
  
  if (newRect.origin.x != rect.origin.x) {
    [self willChangeValueForKey:@"originX"];
    rect.origin.x = newRect.origin.x;
    [self didChangeValueForKey:@"originX"];
  }
  if (newRect.origin.y != rect.origin.y) {
    [self willChangeValueForKey:@"originY"];
    rect.origin.y = newRect.origin.y;
    [self didChangeValueForKey:@"originY"];
  }
  if (newRect.size.width != rect.size.width) {
    [self willChangeValueForKey:@"width"];
    rect.size.width = newRect.size.width;
    [self didChangeValueForKey:@"width"];
  }
  if (newRect.size.height != rect.size.height) {
    [self willChangeValueForKey:@"height"];
    rect.size.height = newRect.size.height;
    [self didChangeValueForKey:@"height"];
  }
}

@end
