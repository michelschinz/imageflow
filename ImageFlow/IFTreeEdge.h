//
//  IFTreeEdge.h
//  ImageFlow
//
//  Created by Michel Schinz on 25.10.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFTreeEdge : NSObject {
  unsigned targetIndex;
}

+ (id)edgeWithTargetIndex:(unsigned)theTargetIndex;
- (id)initWithTargetIndex:(unsigned)theTargetIndex;

- (unsigned)targetIndex;

@end
