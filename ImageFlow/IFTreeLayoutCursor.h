//
//  IFTreeLayoutCursor.h
//  ImageFlow
//
//  Created by Michel Schinz on 16.08.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeLayoutOrnament.h"

@interface IFTreeLayoutCursor : IFTreeLayoutOrnament {
  NSBezierPath* cursorPath;
}

+ (id)layoutCursorWithBase:(IFTreeLayoutSingle*)theBase;

@end
