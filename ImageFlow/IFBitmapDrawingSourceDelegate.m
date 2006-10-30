//
//  IFBitmapDrawingSourceDelegate.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFBitmapDrawingSourceDelegate.h"

#import "IFEnvironment.h"
#import "IFConfiguredFilter.h"
#import "IFPair.h"
#import "IFBlendMode.h"

@implementation IFBitmapDrawingSourceDelegate

- (NSString*)labelWithEnvironment:(IFEnvironment*)env;
{
  return @"draw bitmap";
}

IFExpression* paintExpr(IFExpression* brushExpr, NSArray* points)
{
  return [IFOperatorExpression expressionWithOperator:[IFOperator operatorForName:@"paint"]
                                             operands:[NSArray arrayWithObjects:
                                               brushExpr,
                                               [IFConstantExpression expressionWithArray:points],
                                               nil]];
}

- (void)mouseDown:(NSEvent*)event inView:(IFImageView*)view viewFilterTransform:(NSAffineTransform*)vfTransform withEnvironment:(IFEnvironment*)env;
{
  IFExpression* curExpr = [env valueForKey:@"drawing"];
  IFExpression* brushExpr = [IFOperatorExpression expressionWithOperator:[IFOperator operatorForName:@"circle"]
                                                                operands:[NSArray arrayWithObjects:
                                                                  [IFConstantExpression expressionWithPointNS:NSZeroPoint],
                                                                  [IFConstantExpression expressionWithFloat:[[env valueForKey:@"brushSize"] floatValue]],
                                                                  [IFConstantExpression expressionWithColorNS:[env valueForKey:@"brushColor"]],
                                                                  nil]];
  IFConstantExpression* modeExpr = [IFConstantExpression expressionWithInt:[[env valueForKey:@"brushMode"] intValue]];

  NSPoint point = [vfTransform transformPoint:[view convertPoint:[event locationInWindow] fromView:nil]];
  NSMutableArray* points = [NSMutableArray arrayWithObject:[IFConstantExpression expressionWithPointNS:point]];
  [env setValue:[IFOperatorExpression blendBackground:curExpr withForeground:paintExpr(brushExpr, points) inMode:modeExpr]
         forKey:@"drawing"];

  for (;;) {
    NSEvent* event = [[view window] nextEventMatchingMask:NSLeftMouseDraggedMask|NSLeftMouseUpMask];
    
    switch ([event type]) {
      case NSLeftMouseDragged: {
        point = [vfTransform transformPoint:[view convertPoint:[event locationInWindow] fromView:nil]];
        [points addObject:[IFConstantExpression expressionWithPointNS:point]];
        [env setValue:[IFOperatorExpression blendBackground:curExpr withForeground:paintExpr(brushExpr, points) inMode:modeExpr]
               forKey:@"drawing"];        
      } break;
        
      case NSLeftMouseUp:
        return;
        
      default:
        NSAssert1(NO, @"unexpected event type (%@)",event);
        break;
    }
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
