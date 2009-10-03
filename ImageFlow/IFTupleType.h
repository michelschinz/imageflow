//
//  IFTupleType.h
//  ImageFlow
//
//  Created by Michel Schinz on 27.09.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFType.h"

@interface IFTupleType : IFType {
  NSArray* componentTypes;
}

- (id)initWithComponentTypes:(NSArray*)theContentTypes;

@property(readonly) NSArray* componentTypes;

@end
