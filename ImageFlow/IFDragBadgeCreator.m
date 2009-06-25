//
//  IFDragBadgeCreator.m
//  ImageFlow
//
//  Created by Michel Schinz on 19.11.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFDragBadgeCreator.h"
#import "IFLayoutParameters.h"

@implementation IFDragBadgeCreator

static IFDragBadgeCreator* sharedCreator = nil;

+ (IFDragBadgeCreator*)sharedCreator;
{
  if (sharedCreator == nil)
    sharedCreator = [[self alloc] init];
  return sharedCreator;
}

- (id)init;
{
  if (![super init])
    return nil;
  badgeImages = [[NSArray arrayWithObjects:
                  [NSImage imageNamed:@"dragBadge1-2"],
                  [NSImage imageNamed:@"dragBadge1-2"],
                  [NSImage imageNamed:@"dragBadge3"],
                  [NSImage imageNamed:@"dragBadge4"],
                  [NSImage imageNamed:@"dragBadge5"],
                  nil]
                 retain];
  return self;
}

- (void)dealloc;
{
  // should never be called...
  OBJC_RELEASE(badgeImages);
  [super dealloc];
}

- (NSImage*)addBadgeToImage:(NSImage*)baseImage count:(unsigned)count;
{
  NSString* countStr = [NSString stringWithFormat:@"%d", count];
  NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                              [IFLayoutParameters dragBadgeFont], NSFontAttributeName,
                              [NSColor whiteColor], NSForegroundColorAttributeName,
                              nil];
  NSAttributedString* countAttrStr = [[[NSAttributedString alloc] initWithString:countStr attributes:attributes] autorelease];
  
  NSImage* badgeImage = [badgeImages objectAtIndex:MIN([countStr length], [badgeImages count]) - 1];
  
  const float totalWidth = ceil(baseImage.size.width + badgeImage.size.width / 2.0);
  const float totalHeight = ceil(baseImage.size.height + badgeImage.size.height / 2.0);
  
  NSBitmapImageRep* finalImageRep = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:totalWidth pixelsHigh:totalHeight bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:0 bitsPerPixel:0] autorelease];
  NSGraphicsContext* ctx = [NSGraphicsContext graphicsContextWithBitmapImageRep:finalImageRep];
  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext:ctx];
  NSRectFillUsingOperation(NSMakeRect(0, 0, totalWidth, totalHeight), NSCompositeClear);
  NSPoint badgeOrigin = NSMakePoint(floor(baseImage.size.width - badgeImage.size.width / 2.0), floor(baseImage.size.height - badgeImage.size.height / 2.0));
  
  [baseImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
  [badgeImage drawAtPoint:badgeOrigin fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
  
  NSSize countSize = [countAttrStr size];
  NSPoint countOrigin = NSMakePoint(floor(badgeOrigin.x + ((badgeImage.size.width - countSize.width) / 2.0)), floor(badgeOrigin.y + ((badgeImage.size.height - countSize.height) / 2.0)));
  [countAttrStr drawAtPoint:countOrigin];
  
  [NSGraphicsContext restoreGraphicsState];

  NSImage* finalImage = [[[NSImage alloc] init] autorelease];
  [finalImage addRepresentation:finalImageRep];
  return finalImage;
}
  
@end
