//
//  IFAnnotationSource.h
//  ImageFlow
//
//  Created by Michel Schinz on 30.08.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFAnnotationSource : NSObject {
  id value;
}

- (id)value;

- (void)updateValue:(id)newValue;

// protected
- (void)setValue:(id)newValue;

@end
