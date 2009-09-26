//
//  IFBasicType.h
//  ImageFlow
//
//  Created by Michel Schinz on 04.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFType.h"
#import "IFTypeTags.h"

@interface IFBasicType : IFType {
  IFParameterlessTypeTag tag;
}

+ (IFBasicType*)basicTypeWithTag:(int)theTag;

@property(readonly) IFParameterlessTypeTag tag;

@end
