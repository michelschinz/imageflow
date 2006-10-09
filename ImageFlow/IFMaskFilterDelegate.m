//
//  IFMaskFilterDelegate.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFMaskFilterDelegate.h"

#import "IFExpression.h"
#import "IFOperatorExpression.h"
#import "IFEnvironment.h"

@implementation IFMaskFilterDelegate

static NSArray* parentNames = nil;
static NSArray* shortChannelNames = nil;
static NSArray* longChannelNames = nil;
static NSArray* variantNames = nil;

+ (void)initialize;
{
  parentNames = [[NSArray arrayWithObjects:@"image",@"mask",nil] retain];
  shortChannelNames = [[NSArray arrayWithObjects:@"R",@"G",@"B",@"A",@"lum",nil] retain];
  longChannelNames = [[NSArray arrayWithObjects:@"red",@"green",@"blue",@"opacity",@"luminosity",nil] retain];
  variantNames = [[NSArray arrayWithObjects:@"",@"Image+Mask",nil] retain];
}

- (NSString*)nameOfParentAtIndex:(int)index;
{
  return [parentNames objectAtIndex:index];
}

- (NSString*)labelWithEnvironment:(IFEnvironment*)env;
{
  return [NSString stringWithFormat:@"mask (%@)", [shortChannelNames objectAtIndex:[(NSNumber*)[env valueForKey:@"channel"] intValue]]];
}

- (NSString*)toolTipWithEnvironment:(IFEnvironment*)env;
{
  return [NSString stringWithFormat:@"mask\nchannel: %@", [longChannelNames objectAtIndex:[(NSNumber*)[env valueForKey:@"channel"] intValue]]];
}

- (NSArray*)variantNamesForViewing;
{
  return variantNames;
}

- (NSArray*)variantNamesForEditing;
{
  return variantNames;
}

- (IFExpression*)variantNamed:(NSString*)variantName ofExpression:(IFExpression*)originalExpression;
{
  NSAssert1([variantName isEqualToString:@"Image+Mask"], @"invalid variant name: <%@>", variantName);
  
  if ([originalExpression isKindOfClass:[IFOperatorExpression class]]) {
    IFOperatorExpression* originalOpExpression = (IFOperatorExpression*)originalExpression;
    NSAssert([originalOpExpression operator]  == [IFOperator operatorForName:@"mask"], @"unexpected operator");
    return [IFOperatorExpression expressionWithOperator:[IFOperator operatorForName:@"quick-mask"]
                                               operands:[originalOpExpression operands]];
  } else
    return originalExpression;
}

- (NSAffineTransform*)transformForParentAtIndex:(int)index withEnvironment:(IFEnvironment*)env;
{
  return [NSAffineTransform transform];
}

@end
