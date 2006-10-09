//
//  IFBlendFilterController.m
//  ImageFlow
//
//  Created by Michel Schinz on 02.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFBlendFilterController.h"


@implementation IFBlendFilterController

- (void)awakeFromNib;
{
  [blendingModesController setContent:[NSArray arrayWithObjects:
    @"over",
    @"color burn",
    @"color dodge",
    @"darken",
    @"lighten",
    @"difference",
    @"exclusion",
    @"hard light",
    @"soft light",
    @"hue",
    @"saturation",
    @"color",
    @"luminosity",
    @"multiply",
    @"overlay",
    @"screen",
    nil]];
}

@end
