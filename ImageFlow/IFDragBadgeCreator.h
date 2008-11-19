//
//  IFDragBadgeCreator.h
//  ImageFlow
//
//  Created by Michel Schinz on 19.11.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFDragBadgeCreator : NSObject {
  NSArray* badgeImages;
}

+ (IFDragBadgeCreator*)sharedCreator;

- (NSImage*)addBadgeToImage:(NSImage*)baseImage count:(unsigned)count;

@end
