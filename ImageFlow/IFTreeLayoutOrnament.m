//
//  IFTreeLayoutOrnament.m
//  ImageFlow
//
//  Created by Michel Schinz on 06.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFTreeLayoutOrnament.h"


@implementation IFTreeLayoutOrnament

- (id)initWithBase:(IFTreeLayoutSingle*)theBase;
{
  if (![super initWithContainingView:[theBase containingView]])
    return nil;
  base = [theBase retain];
  return self;
}

- (void) dealloc;
{
  OBJC_RELEASE(base);
  [super dealloc];
}

- (void)setTranslation:(NSPoint)thePoint;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (NSPoint)translation;
{
  return [base translation];
}

- (void)translateBy:(NSPoint)thePoint;
{
  [self doesNotRecognizeSelector:_cmd];
}

@end
