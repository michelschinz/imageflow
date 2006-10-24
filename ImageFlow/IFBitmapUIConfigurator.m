//
//  IFBitmapUIConfigurator.m
//  ImageFlow
//
//  Created by Michel Schinz on 23.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFBitmapUIConfigurator.h"


@implementation IFBitmapUIConfigurator

- (void)awakeFromNib;
{
  NSNumberFormatter* formatter = [[NSNumberFormatter new] autorelease];
  [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
  [formatter setNumberStyle:NSNumberFormatterPercentStyle];
  [opacityTextField setFormatter:formatter];
}

@end
