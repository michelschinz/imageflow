//
//  IFBitmapDrawingSource.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFBitmapDrawingSource.h"

#import "IFEnvironment.h"
#import "IFPair.h"
#import "IFBlendMode.h"
#import "IFFunType.h"
#import "IFBasicType.h"
#import "IFImageType.h"
#import "IFOperatorExpression.h"
#import "IFVariableExpression.h"
#import "IFConstantExpression.h"
#import "IFImageView.h"

@implementation IFBitmapDrawingSource

- (NSArray*)potentialTypes;
{
  static NSArray* types = nil;
  if (types == nil)
    // TODO add Mask
    types = [[NSArray arrayWithObject:[IFImageType imageRGBAType]] retain];
  return types;
}

- (NSArray*)potentialRawExpressions;
{
  static NSArray* exprs = nil;
  if (exprs == nil) {
    IFExpression* bg = [IFOperatorExpression expressionWithOperatorNamed:@"constant-color" operands:
      [IFVariableExpression expressionWithName:@"defaultColor"],
      nil];
    IFExpression* fg = [IFVariableExpression expressionWithName:@"drawing"];
    exprs = [[NSArray arrayWithObject:[IFOperatorExpression blendBackground:bg withForeground:fg inMode:[IFConstantExpression expressionWithInt:IFBlendMode_SourceOver]]] retain];
  }
  return exprs;
}

- (NSString*)label;
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

- (void)mouseDown:(NSEvent*)event inView:(IFImageView*)view viewFilterTransform:(NSAffineTransform*)vfTransform;
{
  IFExpression* curExpr = [settings valueForKey:@"drawing"];
  IFExpression* brushExpr = [IFOperatorExpression expressionWithOperator:[IFOperator operatorForName:@"circle"]
                                                                operands:[NSArray arrayWithObjects:
                                                                  [IFConstantExpression expressionWithPointNS:NSZeroPoint],
                                                                  [IFConstantExpression expressionWithFloat:[[settings valueForKey:@"brushSize"] floatValue]],
                                                                  [IFConstantExpression expressionWithColorNS:[settings valueForKey:@"brushColor"]],
                                                                  nil]];
  IFConstantExpression* modeExpr = [IFConstantExpression expressionWithInt:[[settings valueForKey:@"brushMode"] intValue]];

  NSPoint point = [vfTransform transformPoint:[view convertPoint:[event locationInWindow] fromView:nil]];
  NSMutableArray* points = [NSMutableArray arrayWithObject:[IFConstantExpression expressionWithPointNS:point]];
  [settings setValue:[IFOperatorExpression blendBackground:curExpr withForeground:paintExpr(brushExpr, points) inMode:modeExpr] forKey:@"drawing"];

  for (;;) {
    NSEvent* event = [[view window] nextEventMatchingMask:NSLeftMouseDraggedMask|NSLeftMouseUpMask];
    
    switch ([event type]) {
      case NSLeftMouseDragged: {
        point = [vfTransform transformPoint:[view convertPoint:[event locationInWindow] fromView:nil]];
        [points addObject:[IFConstantExpression expressionWithPointNS:point]];
        [settings setValue:[IFOperatorExpression blendBackground:curExpr withForeground:paintExpr(brushExpr, points) inMode:modeExpr]
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
