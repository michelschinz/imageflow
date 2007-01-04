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
#import "IFPair.h"
#import "IFBlendMode.h"
#import "IFFunType.h"
#import "IFBasicType.h"

@implementation IFBlendFilterDelegate

static NSArray* parentNames = nil;

+ (void)initialize;
{
  if (self != [IFBlendFilterDelegate class])
    return; // avoid repeated initialisation

  parentNames = [[NSArray arrayWithObjects:@"background",@"foreground",nil] retain];
}

- (NSArray*)potentialTypesWithEnvironment:(IFEnvironment*)env;
{
  static NSArray* types = nil;
  if (types == nil) {
    types = [[NSArray arrayWithObject:
      [IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObjects:[IFBasicType imageType],[IFBasicType imageType],nil]
                               returnType:[IFBasicType imageType]]] retain];
  }
  return types;
}

- (NSString*)nameOfParentAtIndex:(int)index;
{
  return [parentNames objectAtIndex:index];
}

- (NSString*)labelWithEnvironment:(IFEnvironment*)env;
{
  return NSStringFromBlendMode([[env valueForKey:@"mode"] intValue]);
}

- (NSString*)toolTipWithEnvironment:(IFEnvironment*)env;
{
  NSPoint translation = [[env valueForKey:@"translation"] pointValue];
  return [NSString stringWithFormat:@"blend\nmode: %@\nforeground opacity: %d%%\nforeground translation: (%d,%d)",
    NSStringFromBlendMode([[env valueForKey:@"mode"] intValue]),
    (int)floor(100.0 * [[env valueForKey:@"alpha"] floatValue]),
    (int)translation.x, (int)translation.y];
}

- (NSArray*)editingAnnotationsForNode:(IFTreeNode*)node view:(NSView*)view;
{
  IFVariable* source = [IFBlendFilterAnnotationSource blendAnnotationSourceForNode:node];
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

- (NSArray*)modes;
{
  return [NSArray arrayWithObjects:
    [IFPair pairWithFst:NSStringFromBlendMode(IFBlendMode_SourceOver) snd:[NSNumber numberWithInt:IFBlendMode_SourceOver]],
    [IFPair pairWithFst:NSStringFromBlendMode(IFBlendMode_Color) snd:[NSNumber numberWithInt:IFBlendMode_Color]],
    [IFPair pairWithFst:NSStringFromBlendMode(IFBlendMode_ColorBurn) snd:[NSNumber numberWithInt:IFBlendMode_ColorBurn]],
    [IFPair pairWithFst:NSStringFromBlendMode(IFBlendMode_ColorDodge) snd:[NSNumber numberWithInt:IFBlendMode_ColorDodge]],
    [IFPair pairWithFst:NSStringFromBlendMode(IFBlendMode_Darken) snd:[NSNumber numberWithInt:IFBlendMode_Darken]],
    [IFPair pairWithFst:NSStringFromBlendMode(IFBlendMode_Difference) snd:[NSNumber numberWithInt:IFBlendMode_Difference]],
    [IFPair pairWithFst:NSStringFromBlendMode(IFBlendMode_Exclusion) snd:[NSNumber numberWithInt:IFBlendMode_Exclusion]],
    [IFPair pairWithFst:NSStringFromBlendMode(IFBlendMode_HardLight) snd:[NSNumber numberWithInt:IFBlendMode_HardLight]],
    [IFPair pairWithFst:NSStringFromBlendMode(IFBlendMode_Hue) snd:[NSNumber numberWithInt:IFBlendMode_Hue]],
    [IFPair pairWithFst:NSStringFromBlendMode(IFBlendMode_Lighten) snd:[NSNumber numberWithInt:IFBlendMode_Lighten]],
    [IFPair pairWithFst:NSStringFromBlendMode(IFBlendMode_Luminosity) snd:[NSNumber numberWithInt:IFBlendMode_Luminosity]],
    [IFPair pairWithFst:NSStringFromBlendMode(IFBlendMode_Multiply) snd:[NSNumber numberWithInt:IFBlendMode_Multiply]],
    [IFPair pairWithFst:NSStringFromBlendMode(IFBlendMode_Overlay) snd:[NSNumber numberWithInt:IFBlendMode_Overlay]],
    [IFPair pairWithFst:NSStringFromBlendMode(IFBlendMode_Saturation) snd:[NSNumber numberWithInt:IFBlendMode_Saturation]],
    [IFPair pairWithFst:NSStringFromBlendMode(IFBlendMode_Screen) snd:[NSNumber numberWithInt:IFBlendMode_Screen]],
    [IFPair pairWithFst:NSStringFromBlendMode(IFBlendMode_SoftLight) snd:[NSNumber numberWithInt:IFBlendMode_SoftLight]],
    nil];
}


@end
