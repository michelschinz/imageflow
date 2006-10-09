//
//  IFProbe.h
//  ImageFlow
//
//  Created by Michel Schinz on 17.08.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeMark.h"

@interface IFProbe : NSObject {
  IFTreeMark* mark;
}

+ (id)probeWithMark:(IFTreeMark*)mark;
- (id)initWithMark:(IFTreeMark*)mark;

- (IFTreeMark*)mark;
- (void)setMark:(IFTreeMark*)newMark;

@end
