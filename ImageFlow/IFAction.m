//
//  IFAction.m
//  ImageFlow
//
//  Created by Michel Schinz on 15.11.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import "IFAction.h"


@implementation IFAction

- (void)execute;
{
  [self doesNotRecognizeSelector:_cmd];
}

@end
