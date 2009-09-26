//
//  IFArrayType.h
//  ImageFlow
//
//  Created by Michel Schinz on 04.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFType.h"

@interface IFArrayType : IFType {
  IFType* contentType;
}

- (id)initWithContentType:(IFType*)theContentType;

- (IFType*)contentType;

@end
