//
//  IFBlendFilterDelegate.m
//  ImageFlow
//
//  Created by Michel Schinz on 09.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFBlendFilterDelegate.h"

#import "IFTreeNode.h"
#import "IFEnvironment.h"
#import "IFBlendFilterAnnotationSource.h"
#import "IFAnnotationRect.h"

@implementation IFBlendFilterDelegate

static NSArray* parentNames = nil;

+ (void)initialize;
{
  parentNames = [[NSArray arrayWithObjects:@"background",@"foreground",nil] retain];
}

- (NSString*)nameOfParentAtIndex:(int)index;
{
  return [parentNames objectAtIndex:index];
}

- (NSString*)labelWithEnvironment:(IFEnvironment*)env;
{
  return [env valueForKey:@"mode"];
}

- (NSString*)toolTipWithEnvironment:(IFEnvironment*)env;
{
  NSPoint translation = [[env valueForKey:@"translation"] pointValue];
  return [NSString stringWithFormat:@"blend\nmode: %@\nforeground opacity: %d%%\nforeground translation: (%d,%d)",
    [env valueForKey:@"mode"],
    (int)floor(100.0 * [[env valueForKey:@"alpha"] floatValue]),
    (int)translation.x, (int)translation.y];
}

- (NSArray*)editingAnnotationsForNode:(IFTreeNode*)node view:(NSView*)view;
{
  IFAnnotationSource* source = [IFBlendFilterAnnotationSource blendAnnotationSourceForNode:node];
  return [NSArray arrayWithObject:[IFAnnotationRect annotationRectWithView:view source:source]];
}

- (NSAffineTransform*)transformForParentAtIndex:(int)index withEnvironment:(IFEnvironment*)env;
{
  switch (index) {
    case 0:
      return [NSAffineTransform transform];
    case 1: {
      NSPoint translation = [[env valueForKey:@"translation"] pointValue];
      NSAffineTransform* transform = [NSAffineTransform transform];
      [transform translateXBy:translation.x yBy:translation.y];
      return transform;
    }
    default:
      NSAssert1(NO, @"invalid parent index %d",index);
      return nil;
  }
}

@end
