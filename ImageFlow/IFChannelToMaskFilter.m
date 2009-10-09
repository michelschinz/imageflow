//
//  IFChannelToMaskFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 16.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFChannelToMaskFilter.h"
#import "IFEnvironment.h"
#import "IFPair.h"
#import "IFType.h"
#import "IFExpression.h"

@implementation IFChannelToMaskFilter

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 1)
    return [NSArray arrayWithObject:[IFType funTypeWithArgumentType:[IFType imageRGBAType] returnType:[IFType maskType]]];
  else
    return [NSArray array];
}

- (IFExpression*)rawExpressionForArity:(unsigned)arity typeIndex:(unsigned)typeIndex;
{
  NSAssert(arity == 1 && typeIndex == 0, @"invalid arity or type index");
  return [IFExpression lambdaWithBody:
          [IFExpression primitiveWithTag:IFPrimitiveTag_ChannelToMask operands:
           [IFExpression argumentWithIndex:0],
           [IFConstantExpression expressionWithObject:[settings valueForKey:@"channel"] tag:IFExpressionTag_Int],
           nil]];
}

- (NSString*)computeLabel;
{
  char* channelInitials = "rgbal";
  return [NSString stringWithFormat:@"%c to mask", channelInitials[[[settings valueForKey:@"channel"] intValue]]];
}

- (NSArray*)channels;
{
  return [NSArray arrayWithObjects:
    [IFPair pairWithFst:@"Red" snd:[NSNumber numberWithInt:0]],
    [IFPair pairWithFst:@"Green" snd:[NSNumber numberWithInt:1]],
    [IFPair pairWithFst:@"Blue" snd:[NSNumber numberWithInt:2]],
    [IFPair pairWithFst:@"Opacity" snd:[NSNumber numberWithInt:3]],
    [IFPair pairWithFst:@"Luminosity" snd:[NSNumber numberWithInt:4]],
    nil];
}

@end
