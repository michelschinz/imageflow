//
//  IFObjectNumberer.h
//  ImageFlow
//
//  Created by Michel Schinz on 13.10.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFObjectNumberer : NSObject {
  NSMutableDictionary* objectToIndex;
  NSMutableIndexSet* freeIndices;
}

+ (id)numberer;
- (unsigned)uniqueNumberForObject:(id)object;

@end
