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
#import "IFFunType.h"
#import "IFBasicType.h"
#import "IFImageType.h"
#import "IFParentExpression.h"
#import "IFVariableExpression.h"

@implementation IFChannelToMaskFilter

- (NSArray*)potentialTypes;
{
  static NSArray* types = nil;
  if (types == nil) {
    types = [[NSArray arrayWithObject:
      [IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObject:[IFImageType imageRGBAType]]
                               returnType:[IFImageType maskType]]] retain];
  }
  return types;
}

- (NSArray*)potentialRawExpressions;
{
  static NSArray* exprs = nil;
  if (exprs == nil) {
    exprs = [[NSArray arrayWithObject:[IFOperatorExpression expressionWithOperatorNamed:@"channel-to-mask" operands:
      [IFParentExpression parentExpressionWithIndex:0],
      [IFVariableExpression expressionWithName:@"channel"],
      nil]] retain];
  }
  return exprs;
}

- (NSString*)label;
{
  char* channelInitials = "rgbal";
  return [NSString stringWithFormat:@"%c to mask", channelInitials[[[environment valueForKey:@"channel"] intValue]]];
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