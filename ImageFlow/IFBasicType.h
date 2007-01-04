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

+ (IFBasicType*)imageType;
+ (IFBasicType*)maskType;
+ (IFBasicType*)colorType;
+ (IFBasicType*)rectType;
+ (IFBasicType*)sizeType;
+ (IFBasicType*)pointType;
+ (IFBasicType*)stringType;
+ (IFBasicType*)numType;
+ (IFBasicType*)intType;
+ (IFBasicType*)boolType;
+ (IFBasicType*)actionType;
+ (IFBasicType*)errorType;

+ (IFBasicType*)basicTypeWithTag:(int)theTag;
- (IFBasicType*)initWithTag:(int)theTag;

- (int)tag;

@end
