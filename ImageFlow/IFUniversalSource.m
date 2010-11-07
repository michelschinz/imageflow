//
//  IFUniversalSource.m
//  ImageFlow
//
//  Created by Michel Schinz on 23.11.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFUniversalSource.h"
#import "IFType.h"
#import "IFExpression.h"
#import "IFImageFile.h"

static NSArray* sourceImages;

@implementation IFUniversalSource

+ (void)initialize;
{
  if (self != [IFUniversalSource class])
    return; // avoid repeated initialisation

  NSMutableArray* mutableSourceImages = [NSMutableArray array];
  for (int i = 1; /* no condition */; ++i) {
    NSURL* maybeURL = [[NSBundle mainBundle] URLForImageResource:[NSString stringWithFormat:@"surrogate_parent_%d",i]];
    if (maybeURL == nil)
      break;
    [mutableSourceImages addObject:[IFImageFile imageWithContentsOfURL:maybeURL]];
  }

  sourceImages = [mutableSourceImages retain];
}

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 0)
    return [NSArray arrayWithObjects:
            [IFType imageRGBAType],
            [IFType maskType],
            [IFType arrayTypeWithContentType:[IFType imageRGBAType]],
            [IFType arrayTypeWithContentType:[IFType maskType]],
            nil];
  else
    return [NSArray array];
}

- (IFExpression*)rawExpressionForArity:(unsigned)arity typeIndex:(unsigned)typeIndex;
{
  NSAssert(arity == 0 && typeIndex <= 3, @"invalid arity or type index");

  // TODO: use better images for masks and stacks
  unsigned imageIndex = [[settings valueForKey:@"index"] unsignedIntValue];
  IFImage* image = [sourceImages objectAtIndex:(imageIndex % [sourceImages count])];

  IFExpression* rgbaImageExpression = [IFConstantExpression imageConstantExpressionWithIFImage:image];
  IFExpression* maskImageExpression = [IFExpression primitiveWithTag:IFPrimitiveTag_ChannelToMask operands:rgbaImageExpression, [IFConstantExpression expressionWithInt:4], nil];

  switch (typeIndex) {
    case 0:
      return rgbaImageExpression;
    case 1:
      return maskImageExpression;
    case 2:
      return [IFExpression primitiveWithTag:IFPrimitiveTag_ArrayCreate operands:rgbaImageExpression, rgbaImageExpression, nil];
    case 3:
      return [IFExpression primitiveWithTag:IFPrimitiveTag_ArrayCreate operands:maskImageExpression, maskImageExpression, nil];
  }
}

@end
