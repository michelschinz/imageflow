//
//  IFTreeLayoutMark.h
//  ImageFlow
//
//  Created by Michel Schinz on 15.08.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeLayoutOrnament.h"

@interface IFTreeLayoutMark : IFTreeLayoutOrnament {
  int markIndex;
  int position;
  NSAttributedString* tag;
  NSBezierPath* outlinePath;
}

+ (id)layoutMarkWithBase:(IFTreeLayoutSingle*)theBase position:(int)thePosition markIndex:(int)theMarkIndex;
- (id)initWithBase:(IFTreeLayoutSingle*)theBase position:(int)thePosition markIndex:(int)theMarkIndex;

- (int)markIndex;

@end
