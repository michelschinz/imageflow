//
//  IFPrintView.m
//  ImageFlow
//
//  Created by Michel Schinz on 18.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFPrintView.h"


@implementation IFPrintView

+ (id)printViewWithFrame:(NSRect)theFrame image:(CIImage*)theImage;
{
  return [[[self alloc] initWithFrame:theFrame image:theImage] autorelease];
}

- (id)initWithFrame:(NSRect)theFrame image:(CIImage*)theImage;
{
  if (![super initWithFrame:theFrame])
    return nil;
  image = [theImage retain];
  return self;
}

- (void) dealloc {
  OBJC_RELEASE(image);
  [super dealloc];
}

- (void)drawRect:(NSRect)rect;
{
  NSAutoreleasePool* pool = [NSAutoreleasePool new];
  
  CIContext* ciCtx = [CIContext contextWithCGContext:[[NSGraphicsContext currentContext] graphicsPort]
                                             options:[NSDictionary dictionary]];
  [ciCtx drawImage:image atPoint:CGPointZero fromRect:[image extent]];
  
  [pool release];
}

@end
