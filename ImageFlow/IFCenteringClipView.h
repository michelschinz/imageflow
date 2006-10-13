//
//  IFCenteringClipView.h
//  ImageFlow
//
//  Created by Michel Schinz on 13.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFCenteringClipView : NSClipView {
  BOOL centerHorizontally, centerVertically;
}

- (BOOL)centerHorizontally;
- (void)setCenterHorizontally:(BOOL)newValue;

- (BOOL)centerVertically;
- (void)setCenterVertically:(BOOL)newValue;

@end
