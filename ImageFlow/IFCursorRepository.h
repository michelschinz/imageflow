//
//  IFCursorRepository.h
//  ImageFlow
//
//  Created by Michel Schinz on 15.09.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFCursorRepository : NSObject {
  NSCursor* moveCursor;
}

+ (id)sharedRepository;

- (NSCursor*)moveCursor;

@end
