//
//  IFStackingView.h
//  ImageFlow
//
//  Created by Michel Schinz on 20.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
  IFStackingViewLayoutHorizontal,
  IFStackingViewLayoutVertical
} IFStackingViewLayout;

@interface IFStackingView : NSView {
  IFStackingViewLayout layout;
}

@end
